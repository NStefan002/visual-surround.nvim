local api = vim.api

local M = {}

---notify user of an error
---@param msg string
function M.error(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.ERROR, { title = "visual-surround.nvim" })
    error(msg)
end

---@param msg string
function M.info(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.INFO, { title = "visual-surround.nvim" })
end

---@param char string
---@return string, string
function M.get_char_pair(char)
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

---@param mode string
---@return visual-surround.bounds
function M.get_bounds(mode)
    local vline_start = vim.fn.line("v")
    local vcol_start = vim.fn.col("v")
    local vline_end = vim.fn.line(".")
    local vcol_end = vim.fn.col(".")

    if mode == "V" then
        vcol_start = 1
        vcol_end = vim.fn.col("$") - 1
    end

    if vline_start > vline_end then
        vline_start, vline_end = vline_end, vline_start
        if mode == "V" then
            api.nvim_feedkeys(api.nvim_replace_termcodes("o", true, false, true), "x", true)
            vcol_start = 1
            vcol_end = vim.fn.col("$") - 1
            api.nvim_feedkeys(api.nvim_replace_termcodes("o", true, false, true), "x", true)
        else
            vcol_start, vcol_end = vcol_end, vcol_start
        end
    end
    if vcol_start > vcol_end then
        vcol_start, vcol_end = vcol_end, vcol_start
    end

    -- ajust the end column if the cursor is one character after the end of the line (visual mode enables this)
    if vcol_end == vim.fn.col("$") then
        vcol_end = vcol_end - 1
    end

    return {
        vline_start = vline_start,
        vcol_start = vcol_start,
        vline_end = vline_end,
        vcol_end = vcol_end,
    }
end

--- HACK: compare two floats
---@param a number
---@param b number
---@return boolean
function M.equals(a, b)
    return tostring(a) == tostring(b)
end

---Returns leading whitespace, text, trailing whitespace
---@param str string
---@return string before, string trimmed, string after
function M.trim(str)
    local before = str:match("^%s*")
    local trimmed = str:gsub("^%s+", ""):gsub("%s+$", "")
    local after = trimmed == "" and "" or str:match("%s*$")

    return before, trimmed, after
end

---Simulates the user pressing a `<Esc>` key
function M.esc()
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
end

---Updates the visual selection
---@param bounds visual-surround.bounds
---@param mode string
function M.update_visual_selection(bounds, mode)
    if mode == "V" then
        return
    end
    M.esc()
    api.nvim_win_set_cursor(0, { bounds.vline_start, bounds.vcol_start })
    api.nvim_feedkeys(api.nvim_replace_termcodes(mode, true, false, true), "x", true)
    api.nvim_win_set_cursor(0, { bounds.vline_end, bounds.vcol_end })
end

return M
