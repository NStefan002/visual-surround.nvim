local Config = require("visual-surround.config")
local Util = require("visual-surround.util")

local Surround = {}

---@param char string
---@return string, string
function Surround._get_char(char)
    if char == "(" or char == ")" then
        return "(", ")"
    elseif char == "[" or char == "]" then
        return "[", "]"
    elseif char == "{" or char == "}" then
        return "{", "}"
    elseif char == "<" or char == ">" then
        return "<", ">"
    end
    return char, char
end

function Surround._set_keymaps()
    local keys = Config.opts.surround_chars
    for _, key in ipairs(keys) do
        vim.keymap.set("v", key, function()
            Surround.surround(key)
        end, { desc = "[visual-surround] Surround selection with " .. key })
    end
end

---@param char string
function Surround.surround(char)
    local opening_char, closing_char = Surround._get_char(char)
    local mode = vim.api.nvim_get_mode().mode
    local bounds = Util.get_bounds(mode)
    if mode == "v" or mode == "V" then
        local lines = vim.api.nvim_buf_get_text(
            0,
            bounds.vline_start - 1,
            bounds.vcol_start - 1,
            bounds.vline_end - 1,
            bounds.vcol_end,
            {}
        )
        lines[1] = string.rep(" ", Util.num_of_leading_whitespaces(lines[1]), "")
            .. opening_char
            .. Util.trim(lines[1])
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
            local trimmed_line = Util.trim(line_mid)
            if trimmed_line ~= "" then
                line_mid = string.rep(" ", Util.num_of_leading_whitespaces(line_mid), "")
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
    if Config.opts.exit_visual_mode then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
    end
end

---@param user_opts? table
function Surround.setup(user_opts)
    Config.override_config(user_opts)
    if Config.opts.use_default_keymaps then
        Surround._set_keymaps()
    end
end

return Surround
