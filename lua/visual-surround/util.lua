local Util = {}
---notify user of an error
---@param msg string
function Util.error(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.ERROR, { title = "Speedtyper" })
    error(msg)
end

---@param msg string
function Util.info(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.INFO, { title = "Speedtyper" })
end

---@param mode string
---@return { vline_start: integer, vcol_start: integer, vline_end: integer, vcol_end: integer }
function Util.get_bounds(mode)
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
function Util.equals(a, b)
    return tostring(a) == tostring(b)
end

---@param str string
function Util.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

---@param str string
---@param sep? string
function Util.split(str, sep)
    sep = sep or "%s" -- whitespace by default
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

---@param str string
---@return integer
function Util.num_of_leading_whitespaces(str)
    for i = 1, #str do
        if str:sub(i, i) ~= " " then
            return i - 1
        end
    end
    return #str
end

return Util
