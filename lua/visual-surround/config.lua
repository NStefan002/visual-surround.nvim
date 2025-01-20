local M = {}

---@type visual-surround.config.full
M.defaults = {
    use_default_keymaps = true,
    surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"', "`", "<", ">" },
    enable_wrapped_deletion = false,
    exit_visual_mode = true,
}

---@type visual-surround.config.full
M.opts = M.defaults

---@param opts? visual-surround.config
function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_deep_extend("force", M.defaults, opts)
end

return M
