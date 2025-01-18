local M = {}

M.defaults = {
    -- if set to true, the user must manually add keymaps
    use_default_keymaps = true,
    -- will be ignored if use_default_keymaps is set to false
    surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"', "`" },
    -- whether to exit visual mode after adding surround
    exit_visual_mode = true,
}

M.opts = M.defaults

---@param opts? table
function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_deep_extend("force", M.defaults, opts)
end

return M
