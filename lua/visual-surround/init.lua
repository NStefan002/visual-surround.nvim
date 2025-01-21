local api = vim.api
local config = require("visual-surround.config")
local util = require("visual-surround.util")

local M = {}

local function set_keymaps()
    local keys = config.opts.surround_chars
    for _, key in ipairs(keys) do
        if key == "<" or key == ">" then
            vim.keymap.set("x", key, function()
                local mode = api.nvim_get_mode().mode
                -- do not change the default behavior of '<' and '>' in visual-line mode
                if mode == "V" then
                    return key
                else
                    vim.schedule(function()
                        M.surround(key)
                    end)
                    return "<ignore>"
                end
            end, {
                desc = "[visual-surround] Surround selection with "
                    .. key
                    .. " (visual mode and visual block mode)",
                expr = true,
            })
        else
            vim.keymap.set("v", key, function()
                M.surround(key)
            end, { desc = "[visual-surround] Surround selection with " .. key })
        end
    end
end

---@param bounds visual-surround.bounds
---@param mode string
---@param opening_char string
---@param closing_char string
local function add_surround_char(bounds, mode, opening_char, closing_char)
    local new_bounds = vim.deepcopy(bounds)
    if mode == "v" or mode == "V" then
        local lines = api.nvim_buf_get_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            {}
        )

        local leading_spaces, text, trailing_spaces = util.trim(lines[1])
        lines[1] = leading_spaces .. opening_char .. text .. trailing_spaces

        new_bounds.vcol_start = bounds.vcol_start + api.nvim_strwidth(leading_spaces) - 1

        leading_spaces, text, trailing_spaces = util.trim(lines[#lines])
        lines[#lines] = leading_spaces .. text .. closing_char .. trailing_spaces

        if #lines > 1 then
            new_bounds.vcol_end = api.nvim_strwidth(leading_spaces .. text)
        else
            new_bounds.vcol_end = bounds.vcol_start + api.nvim_strwidth(leading_spaces .. text) - 1
        end

        api.nvim_buf_set_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            lines
        )
    else
        local lines = api.nvim_buf_get_lines(0, bounds.vline_start - 1, bounds.vline_end, true)
        for i, line in ipairs(lines) do
            local line_mid = line:sub(bounds.vcol_start, bounds.vcol_end)
            local leading_spaces, text, _ = util.trim(line_mid)
            if text ~= "" then
                line_mid = leading_spaces .. opening_char .. text
                line_mid = line_mid .. closing_char

                -- line = start mid end
                lines[i] = line:sub(1, bounds.vcol_start - 1)
                    .. line_mid
                    .. line:sub(bounds.vcol_end + 1)

                new_bounds.vcol_start = api.nvim_strwidth(line:sub(1, bounds.vcol_start - 1))
                new_bounds.vcol_end = api.nvim_strwidth(
                    line:sub(1, bounds.vcol_start - 1) .. line_mid
                ) - 1
            end
        end

        api.nvim_buf_set_lines(0, bounds.vline_start - 1, bounds.vline_end, true, lines)
    end

    util.update_visual_selection(new_bounds, mode)
end

---@param bounds visual-surround.bounds
---@param mode string
local function delete_surround_char(bounds, mode)
    local new_bounds = vim.deepcopy(bounds)
    if mode == "v" or mode == "V" then
        local lines = api.nvim_buf_get_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            {}
        )

        local leading_spaces, text, trailing_spaces = util.trim(lines[1])
        lines[1] = leading_spaces .. text:sub(2) .. trailing_spaces

        leading_spaces, text, trailing_spaces = util.trim(lines[#lines])
        lines[#lines] = leading_spaces .. text:sub(1, -2) .. trailing_spaces

        new_bounds.vcol_start = bounds.vcol_start - 1
        if #lines > 1 then
            new_bounds.vcol_end = bounds.vcol_end - 2
        else
            new_bounds.vcol_end = bounds.vcol_end - 3
        end

        api.nvim_buf_set_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            lines
        )
    else
        local lines = api.nvim_buf_get_lines(0, bounds.vline_start - 1, bounds.vline_end, true)
        for i, line in ipairs(lines) do
            local line_mid = line:sub(bounds.vcol_start, bounds.vcol_end)
            local leading_spaces, text, trailing_spaces = util.trim(line_mid)
            if text ~= "" then
                line_mid = leading_spaces .. text:sub(2)
                line_mid = line_mid:sub(1, -2) .. trailing_spaces

                -- line = start .. mid .. end
                lines[i] = line:sub(1, bounds.vcol_start - 1)
                    .. line_mid
                    .. line:sub(bounds.vcol_end + 1)
            end
        end
        new_bounds.vcol_start = bounds.vcol_start - 1
        new_bounds.vcol_end = bounds.vcol_end - 3
        api.nvim_buf_set_lines(0, bounds.vline_start - 1, bounds.vline_end, true, lines)
    end

    util.update_visual_selection(new_bounds, mode)
end

---@param char string
function M.surround(char)
    local opening_char, closing_char = util.get_char_pair(char)
    local mode = api.nvim_get_mode().mode
    local bounds = util.get_bounds(mode)

    if not config.opts.enable_wrapped_deletion then
        add_surround_char(bounds, mode, opening_char, closing_char)

        if config.opts.exit_visual_mode then
            util.esc()
        end

        return
    end

    local delete_surr = true
    if mode == "v" or mode == "V" then
        local lines = api.nvim_buf_get_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            {}
        )
        local _, first_char, _ = util.trim(lines[1])
        first_char = first_char:sub(1, 1)

        local _, last_char, _ = util.trim(lines[#lines])
        last_char = last_char:sub(-1, -1)

        delete_surr = first_char == opening_char and last_char == closing_char
    else
        local lines = api.nvim_buf_get_lines(0, bounds.vline_start - 1, bounds.vline_end, true)
        for _, line in ipairs(lines) do
            local _, text, _ = util.trim(line:sub(bounds.vcol_start, bounds.vcol_end))
            if text ~= "" then
                local first_char = line:sub(bounds.vcol_start, bounds.vcol_start)
                local last_char = line:sub(bounds.vcol_end, bounds.vcol_end)
                delete_surr = delete_surr
                    and first_char == opening_char
                    and last_char == closing_char
            end
        end
    end

    if delete_surr then
        delete_surround_char(bounds, mode)
    else
        add_surround_char(bounds, mode, opening_char, closing_char)
    end

    if config.opts.exit_visual_mode then
        util.esc()
    end
end

---@param opts? visual-surround.config
function M.setup(opts)
    config.setup(opts)
    if config.opts.use_default_keymaps then
        set_keymaps()
    end
end

return M
