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
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("o", true, false, true), "x", true)
            vcol_start = 1
            vcol_end = vim.fn.col("$") - 1
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("o", true, false, true), "x", true)
        else
            vcol_start, vcol_end = vcol_end, vcol_start
        end
    elseif vline_start == vline_end and vcol_start > vcol_end then
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

---@param str string
function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

---@param str string
---@param sep? string
function M.split(str, sep)
    sep = sep or "%s" -- whitespace by default
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

---@param str string
---@return integer
function M.num_of_leading_whitespaces(str)
    for i = 1, #str do
        if str:sub(i, i) ~= " " then
            return i - 1
        end
    end
    return #str
end

return M
