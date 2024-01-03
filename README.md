# Visual-surround.nvim

**Why another surround plugin?**

The answer is simple: because I only ever used the 'surround visual selection' feature of (btw incredible) plugins such as
[nvim-surround](https://github.com/kylechui/nvim-surround) or [mini.surround](https://github.com/echasnovski/mini.surround).
I wanted to create the plugin that does a similar thing to that one vsc\*\*e's feature - highlight text that you want to surround
with parentheses and just press the `(` or `)` key.

If you want additional functionalities, such as deleting surrounding characters, changing surrounding characters, or some other
advanced features, check out two of the plugins mentioned above.

## 📋 Installation

**NOTE:** `visual-surround` works out of the box, you don't have to call `setup()` function if you don't want to change any settings.
It can be lazy-loaded (use something like `event = "BufEnter"`).

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/visual-surround.nvim",
    config = function()
        require("visual-surround").setup({
            -- your config
        })
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
    end,
})
```

## ⚙ Configuration

<details>
<summary>Default config</summary>

```lua
{
    -- if set to true, the user must manually add keymaps
    use_default_keymaps = true,
    -- will be ignored if use_default_keymaps is set to false
    surround_chars = { "{", "}", "[", "]", "(", ")", "'", '"' },
    -- whether to exit visual mode after adding surround
    exit_visual_mode = true,
}
```

</details>

### 👀 Tips

<details>
<summary>set some additional keymaps</summary>

```lua
vim.keymap.set("v", "s<", function()
    -- surround selected text with "<>"
    require("visual-surround").surround("<") -- it's enough to supply only opening or closing char
end)
```

</details>

<details>
<summary>set new keymaps</summary>

```lua
require("visual-surround").setup({
    use_default_keymaps = false,
})

local preffered_mapping_prefix = "s"
local surround_chars = { "{", "[", "(", "'", '"', "<" }
for _, key in pairs(surround_chars) do
    vim.keymap.set("v", preffered_mapping_prefix .. key, function()
        Surround.surround(key)
    end, { desc = "[visual-surround] Surround selection with " .. key })
end
```

</details>
