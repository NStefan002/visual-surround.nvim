local config = require("visual-surround.config")
local util = require("visual-surround.util")

local M = {}

local function set_keymaps()
    local keys = config.opts.surround_chars
    for _, key in ipairs(keys) do
        vim.keymap.set("v", key, function()
            M.surround(key)
        end, { desc = "[visual-surround] Surround selection with " .. key })
    end
end

---@param char string
function M.surround(char)
    local opening_char, closing_char = util.get_char_pair(char)
    local mode = vim.api.nvim_get_mode().mode
    local bounds = util.get_bounds(mode)
    if mode == "v" or mode == "V" then
        local lines = vim.api.nvim_buf_get_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            {}
        )
        lines[1] = string.rep(" ", util.num_of_leading_whitespaces(lines[1]), "")
            .. opening_char
            .. util.trim(lines[1])
        lines[#lines] = lines[#lines] .. closing_char
        vim.api.nvim_buf_set_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            lines
        )
    else
        local lines = vim.api.nvim_buf_get_lines(0, bounds.vline_start - 1, bounds.vline_end, true)
        -- Make sure we're normalized if in V-Block mode.
        if bounds.vcol_end < bounds.vcol_start then
            bounds.vcol_start, bounds.vcol_end = bounds.vcol_end, bounds.vcol_start
        end
        for n = 1, #lines do
            local line_mid = string.sub(lines[n], bounds.vcol_start, bounds.vcol_end)
            local trimmed_line = util.trim(line_mid)
            if trimmed_line ~= "" then
                line_mid = string.rep(" ", util.num_of_leading_whitespaces(line_mid), "")
                    .. opening_char
                    .. trimmed_line
                line_mid = line_mid .. closing_char

                -- line = start mid end
                lines[n] = string.sub(lines[n], 1, bounds.vcol_start - 1)
                    .. line_mid
                    .. string.sub(lines[n], bounds.vcol_end + 1, #lines[n])
            end
        end
        vim.api.nvim_buf_set_lines(0, bounds.vline_start - 1, bounds.vline_end, true, lines)
    end
    if config.opts.exit_visual_mode then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
    end
end

---@param opts? table
function M.setup(opts)
    config.setup(opts)
    if config.opts.use_default_keymaps then
        set_keymaps()
    end
end

return M
