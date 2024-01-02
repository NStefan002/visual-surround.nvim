local Config = require("visual-surround.config")
local Util = require("visual-surround.util")

local Surround = {}

---@param char string
---@return string
function Surround._get_opening_char(char)
    if char == "'" then
        return "'"
    end
    if char == '"' then
        return '"'
    end
    if char == "(" or char == ")" then
        return "("
    end
    if char == "[" or char == "]" then
        return "["
    end
    if char == "{" or char == "}" then
        return "{"
    end
    if char == "<" or char == ">" then
        return "<"
    end
    return char
end

---@param char string
---@return string
function Surround._get_closing_char(char)
    if char == "'" then
        return "'"
    end
    if char == '"' then
        return '"'
    end
    if char == "(" or char == ")" then
        return ")"
    end
    if char == "[" or char == "]" then
        return "]"
    end
    if char == "{" or char == "}" then
        return "}"
    end
    if char == "<" or char == ">" then
        return ">"
    end
    return char
end

function Surround._set_keymaps()
    local default_keys = { "{", "}", "[", "]", "(", ")", "<", ">", "'", '"' }
    for _, key in ipairs(default_keys) do
        vim.keymap.set("v", key, function()
            Surround.surround(key)
        end, { desc = "[visual-surround] Surround selection with " .. key })
    end
end

---@param char string
function Surround.surround(char)
    local opening_char = Surround._get_opening_char(char)
    local closing_char = Surround._get_closing_char(char)
    local bounds = Util.get_bounds()
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
