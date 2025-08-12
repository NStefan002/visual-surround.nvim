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

---@param config visual-surround.config.full
---@return boolean, string?
function M.validate_config(config)
    local errors = {}
    local ok, err = pcall(vim.validate, "config", config, "table", false, "table")
    if not ok then
        table.insert(errors, err)
    end

    ok, err = pcall(
        vim.validate,
        "config.use_default_keymaps",
        config.use_default_keymaps,
        "boolean",
        false,
        "boolean"
    )
    if not ok then
        table.insert(errors, err)
    end

    ok, err = pcall(
        vim.validate,
        "config.surround_chars",
        config.surround_chars,
        "table",
        false,
        "string[]"
    )
    if not ok then
        table.insert(errors, err)
    end

    ok, err = pcall(
        vim.validate,
        "config.enable_wrapped_deletion",
        config.enable_wrapped_deletion,
        "boolean",
        false,
        "boolean"
    )
    if not ok then
        table.insert(errors, err)
    end

    ok, err = pcall(
        vim.validate,
        "config.exit_visual_mode",
        config.exit_visual_mode,
        "boolean",
        false,
        "boolean"
    )
    if not ok then
        table.insert(errors, err)
    end

    if #errors > 0 then
        return false, table.concat(errors, "\n")
    end
    return true, nil
end

---@param opts? visual-surround.config
function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_deep_extend("force", M.defaults, opts)
    local ok, _ = M.validate_config(M.opts)
    if not ok then
        vim.api.nvim_echo({
            { " visual-surround ", "DiagnosticVirtualTextError" },
            { " Invalid configuration, run " },
            { " :checkhealth visual-surround ", "DiagnosticVirtualTextInfo" },
            { " for more info" },
        }, true, { verbose = false })
    end
end

return M
