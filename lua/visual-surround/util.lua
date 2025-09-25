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
    local start_pos = api.nvim_buf_get_mark(0, "<")
    local end_pos = api.nvim_buf_get_mark(0, ">")
    local vline_start, vcol_start = start_pos[1], start_pos[2]
    local vline_end, vcol_end = end_pos[1], end_pos[2]

    if vline_start > vline_end then
        vline_start, vline_end = vline_end, vline_start
        vcol_start, vcol_end = vcol_end, vcol_start
    end

    if vline_start == vline_end and vcol_start > vcol_end then
        vcol_start, vcol_end = vcol_end, vcol_start
    end

    local last_line = vim.fn.getline(vline_end)
    if mode == "V" then
        local _, whitespaces = vim.fn.getline(vline_start):find("^%s*")
        vcol_start = whitespaces or 1
        whitespaces = last_line:find("%s*$") or #last_line
        vcol_end = whitespaces - 2
    elseif mode == api.nvim_replace_termcodes("<c-v>", true, false, true) then
        vcol_start, vcol_end = math.min(vcol_start, vcol_end), math.max(vcol_start, vcol_end)
    end

    vcol_start, vcol_end = vcol_start + 1, vcol_end + 1

    vcol_end =
        vim.str_byteindex(last_line, vim.str_utfindex(last_line, math.min(vcol_end, #last_line)))

    return {
        vline_start = vline_start,
        vcol_start = vcol_start,
        vline_end = vline_end,
        vcol_end = vcol_end,
    }
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
    api.nvim_win_set_cursor(0, { bounds.vline_start, bounds.vcol_start })
    api.nvim_feedkeys(api.nvim_replace_termcodes(mode, true, false, true), "x", true)
    api.nvim_win_set_cursor(0, { bounds.vline_end, bounds.vcol_end })
end

---Get the character at the given index in a utf-8 string
---@param str string
---@param idx integer if negative, index from the end of the string (-1 is the last character)
---@return string
function M.utf_char_at(str, idx)
    local utf_indices = vim.str_utf_pos(str)
    if idx == 0 or idx > #utf_indices then
        return ""
    end
    if idx < 0 then
        idx = #utf_indices + idx + 1
    end
    return str:sub(utf_indices[idx], idx < #utf_indices and utf_indices[idx + 1] - 1 or -1)
end

---get a substring of a utf-8 string
---@param str string
---@param start integer index of the first character of the substring (indicies are the positions of utf-8 characters, not bytes as in default lua strings)
---@param stop? integer if nil, the substring will be from `start` to the end of the string
---@return string
function M.utf_sub(str, start, stop)
    local utf_indices = vim.str_utf_pos(str)

    if start > #utf_indices then
        return ""
    end
    if start < 0 then
        start = #utf_indices + start + 1
    end
    local start_idx = utf_indices[start] or 1

    stop = stop or #utf_indices
    if stop < 0 then
        stop = #utf_indices + stop + 1
    end
    local stop_idx = (utf_indices[stop + 1] or 0) - 1

    return str:sub(start_idx, stop_idx)
end

return M
