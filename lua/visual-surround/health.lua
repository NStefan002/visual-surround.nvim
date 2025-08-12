local M = {}

function M.check()
    local config = require("visual-surround.config")
    vim.health.start("visual-surround.nvim")
    local ok, err = config.validate_config(config.opts)
    if ok then
        vim.health.ok("Everything looks good!")
    else
        vim.health.error(("Configuration error:\n%s"):format(err))
    end
end

return M
