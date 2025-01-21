---@class (strict) visual-surround.config.full
---@field use_default_keymaps boolean if set to false, the user must manually add keymaps
---@field surround_chars string[] will be ignored if use_default_keymaps is set to false
---@field enable_wrapped_deletion boolean delete surroundings when selection block starts and ends with surroundings
---@field exit_visual_mode boolean whether to exit visual mode after adding surround

---@class (strict) visual-surround.config : visual-surround.config.full, {}

---@class visual-surround.bounds
---@field vline_start integer
---@field vcol_start integer
---@field vline_end integer
---@field vcol_end integer
