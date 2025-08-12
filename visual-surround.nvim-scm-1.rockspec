rockspec_format = "3.0"
package = "visual-surround.nvim"
version = "scm-1"

local user = "NStefan002"

source = {
    url = "git+https://github.com/" .. user .. "/" .. package,
}
description = {
    homepage = "https://github.com/" .. user .. "/" .. package,
    labels = { "neovim", "neovim-plugin", "lua" },
    license = "MIT",
    summary = "Simple as select, '(', done.",
}
dependencies = {}
test_dependencies = {
    "nlua",
}
build = {
    type = "builtin",
    copy_directories = {
        "plugin",
    },
}
