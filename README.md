# visual-surround.nvim

Visual surround is a lightweight and flexible Neovim plugin designed to
simplify text manipulation using surround elements. Inspired by popular
surrounding plugins, it enables users to easily add or remove surrounding
characters like parentheses, brackets, quotes, and custom strings. All within a
visual selection.

Since this plugin only works in visual mode, by default, all keymaps are
one character long. So for example, to surround a selection with parentheses,
you would press `(` or `)` in visual mode and it's done. Of course, the mappings
can be customized to your liking.

> [!NOTE]
> If you want a more feature-rich plugin, check out
> [nvim-surround](https://github.com/kylechui/nvim-surround) or
> [mini.surround](https://github.com/echasnovski/mini.surround),
> but if you only using these plugins in visual mode, this plugin is for you.

## 📺 Showcase

<https://github.com/user-attachments/assets/faaa7bd6-0a94-4b4c-af7c-1ae43ef750af>

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/visual-surround.nvim",
    config = function()
        require("visual-surround").setup({
            -- your config
        })
        -- [optional] custom keymaps
    end,
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use({
    "NStefan002/visual-surround.nvim",
    config = function()
        require("visual-surround").setup({
            -- your config
        })
        -- [optional] custom keymaps
    end,
})
```

## ⚙ Configuration

```lua
{
    -- if set to false, the user must manually add keymaps
    use_default_keymaps = true,
    -- will be ignored if use_default_keymaps is set to false
    surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"', "`", "<", ">" },
    -- delete surroundings when the selection block starts and ends with surroundings
    enable_wrapped_deletion = false,
    -- whether to exit visual mode after adding surround
    exit_visual_mode = true,
}
```

> [!NOTE]
> `<` and `>` only work in visual (`v`) and visual-block mode
(`CTRL-V`) to avoid conflicts with the default `<` / `>` in visual-line mode (`V`).
You can change this by defining a mapping yourself (see **Tips**).

## ⚒️ API

This plugin exposes the `surround` function that should be used in visual mode to surround the selected text.
The function receives two parameters:

1. `opening` (`string`) -> String that should be placed at the beginning of the selection.
2. `[optional]` `closing` (`string`) -> String that should be placed at the end
   of the selection. Do not provide this parameter if you want the `opening`
   string to be placed at the end as well. (If the `opening` string is any of
   the characters from `surround_chars`, this function will correctly determine
   `closing` string.)

### 👀 Tips

<details>
<summary>Set some additional keymaps</summary>

```lua
require("visual-surround").setup({
    use_default_keymaps = true, -- to enable default keymaps
})

vim.keymap.set("x", "sd", function()
    require("visual-surround").surround("<div>", "</div>")
end, { desc = "Wrap selection in a div" })
```

Also, take a look at
[this](https://github.com/NStefan002/nvim_config/blob/main/after/ftplugin/markdown.lua#L22-L28)
example in my config.

</details>

<details>
<summary>Set new keymaps</summary>

```lua
require("visual-surround").setup({
    use_default_keymaps = false,
})

local prefix = "s" -- optional, just an idea if you prefer it this way
local surround_chars = { "{", "[", "(", "'", '"', "<" }
local surround = require("visual-surround").surround
for _, key in pairs(surround_chars) do
    vim.keymap.set("x", prefix .. key, function()
        surround(key)
    end, { desc = "[visual-surround] Surround selection with " .. key })
end
```

</details>

<details>
<summary>Prompt for a custom surround string</summary>

```lua
vim.keymap.set("x", "ss", function()
    local opening = vim.fn.input("Opening: ")
    local closing = vim.fn.input("Closing: ") -- leave empty if you want to use opening string for both
    require("visual-surround").surround(opening, closing)
end, { desc = "[visual-surround] Surround selection with custom string" })
```

</details>
