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
            vim.keymap.set("x", key, function()
                M.surround(key)
            end, { desc = "[visual-surround] Surround selection with " .. key })
        end
    end
end

---@param bounds visual-surround.bounds
---@param mode string
---@param opening string
---@param closing string
local function add_surr(bounds, mode, opening, closing)
    local new_bounds = vim.deepcopy(bounds)

    bounds.vline_start = bounds.vline_start - 1
    bounds.vcol_start = bounds.vcol_start - 1
    bounds.vline_end = bounds.vline_end - 1
    bounds.vcol_end = bounds.vcol_end

    if mode == "v" or mode == "V" then
        -- insert closing first so that the column indices don't change
        api.nvim_buf_set_text(
            0,
            bounds.vline_end,
            bounds.vcol_end,
            bounds.vline_end,
            bounds.vcol_end,
            { closing }
        )

        -- insert opening
        api.nvim_buf_set_text(
            0,
            bounds.vline_start,
            bounds.vcol_start,
            bounds.vline_start,
            bounds.vcol_start,
            { opening }
        )
    else
        for line = bounds.vline_start, bounds.vline_end do
            -- skip empty (or whitespace-only) lines
            local line_text = api.nvim_buf_get_lines(0, line, line + 1, true)[1]
            local _, text, _ = util.trim(line_text:sub(bounds.vcol_start + 1, bounds.vcol_end))

            if text ~= "" then
                -- insert closing first so that the column indices don't change
                api.nvim_buf_set_text(0, line, bounds.vcol_end, line, bounds.vcol_end, { closing })

                -- insert opening
                api.nvim_buf_set_text(
                    0,
                    line,
                    bounds.vcol_start,
                    line,
                    bounds.vcol_start,
                    { opening }
                )
            end
        end
    end

    new_bounds.vcol_start = math.max(new_bounds.vcol_start - 1, 0)
    new_bounds.vcol_end = new_bounds.vcol_end + #closing
    if
        bounds.vline_start ~= bounds.vline_end
        and mode ~= api.nvim_replace_termcodes("<c-v>", true, false, true)
    then
        new_bounds.vcol_end = new_bounds.vcol_end - 1
    else
        new_bounds.vcol_end = new_bounds.vcol_end + #opening - 1
    end
    util.update_visual_selection(new_bounds, mode)
end

---@param bounds visual-surround.bounds
---@param mode string
---@param opening string
---@param closing string
local function remove_surr(bounds, mode, opening, closing)
    local new_bounds = vim.deepcopy(bounds)

    bounds.vline_start = bounds.vline_start - 1
    bounds.vcol_start = bounds.vcol_start - 1
    bounds.vline_end = bounds.vline_end - 1
    bounds.vcol_end = bounds.vcol_end

    if mode == "v" or mode == "V" then
        api.nvim_buf_set_text(
            0,
            bounds.vline_end,
            bounds.vcol_end - #closing,
            bounds.vline_end,
            bounds.vcol_end,
            {}
        )

        api.nvim_buf_set_text(
            0,
            bounds.vline_start,
            bounds.vcol_start,
            bounds.vline_start,
            bounds.vcol_start + #opening,
            {}
        )
    else
        for line = bounds.vline_start, bounds.vline_end do
            -- skip empty (or whitespace-only) lines
            local line_text = api.nvim_buf_get_lines(0, line, line + 1, true)[1]
            local _, text, _ = util.trim(line_text:sub(bounds.vcol_start + 1, bounds.vcol_end))

            if text ~= "" then
                api.nvim_buf_set_text(
                    0,
                    line,
                    bounds.vcol_end - #closing,
                    line,
                    bounds.vcol_end,
                    {}
                )

                api.nvim_buf_set_text(
                    0,
                    line,
                    bounds.vcol_start,
                    line,
                    bounds.vcol_start + #opening,
                    {}
                )
            end
        end
    end

    new_bounds.vcol_start = new_bounds.vcol_start - 1
    new_bounds.vcol_end = new_bounds.vcol_end - #closing
    if
        bounds.vline_start ~= bounds.vline_end
        and mode ~= api.nvim_replace_termcodes("<c-v>", true, false, true)
    then
        new_bounds.vcol_end = new_bounds.vcol_end - 1
    else
        new_bounds.vcol_end = new_bounds.vcol_end - #opening - 1
    end

    new_bounds.vcol_start = math.max(new_bounds.vcol_start, 0)
    new_bounds.vcol_end = math.max(new_bounds.vcol_end, 0)

    util.update_visual_selection(new_bounds, mode)
end

---@param opening string
---@param closing? string
function M.surround(opening, closing)
    if closing == nil or closing == "" then
        opening, closing = util.get_char_pair(opening)
    end
    local mode = api.nvim_get_mode().mode
    util.esc() -- exit visual mode to avoid issues with getting bounds
    local bounds = util.get_bounds(mode)

    if not config.opts.enable_wrapped_deletion then
        add_surr(bounds, mode, opening, closing)

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
        local _, opening_surround, _ = util.trim(lines[1])
        opening_surround = opening_surround:sub(1, #opening)

        local _, closing_surround, _ = util.trim(lines[#lines])
        closing_surround = closing_surround:sub(-#closing)

        delete_surr = opening_surround == opening and closing_surround == closing
    else
        local lines = api.nvim_buf_get_lines(0, bounds.vline_start - 1, bounds.vline_end, true)
        for _, line in ipairs(lines) do
            local _, text, _ = util.trim(line:sub(bounds.vcol_start, bounds.vcol_end))
            if text ~= "" then
                local opening_surround =
                    line:sub(bounds.vcol_start, bounds.vcol_start + #opening - 1)
                local closing_surround = line:sub(bounds.vcol_end - #closing + 1, bounds.vcol_end)
                delete_surr = delete_surr
                    and opening_surround == opening
                    and closing_surround == closing
            end
        end
    end

    if delete_surr then
        remove_surr(bounds, mode, opening, closing)
    else
        add_surr(bounds, mode, opening, closing)
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
