local Config = {}

function Config.get_default_config()
    return {
        -- if set to true, the user must manually add keymaps
        use_default_keymaps = true,
        -- will be ignored if use_default_keymaps is set to false
        --
        -- By default, surrounding for "<" and ">" fallbacks to indentation logic for line-visual mode.
        surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"', "`", "<", ">" },
        -- surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"', "`" },
        -- whether to exit visual mode after adding surround
        exit_visual_mode = true,
    }
end

Config.opts = Config.get_default_config()

---@param user_config? table
function Config.override_config(user_config)
    user_config = user_config or {}
    Config.opts = vim.tbl_deep_extend("force", Config.get_default_config(), user_config)
end

return Config
