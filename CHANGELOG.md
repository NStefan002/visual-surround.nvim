# Changelog

## 1.0.0 (2025-08-12)


### ⚠ BREAKING CHANGES

* support only Neovim 0.11 and later

### Features

* add types ([30b48da](https://github.com/NStefan002/visual-surround.nvim/commit/30b48da9930176408f2e4d16356dee68e4d31e59))
* basic functionalities ([231d978](https://github.com/NStefan002/visual-surround.nvim/commit/231d978ef394c60a74856892227492107162dff5))
* **config:** add health check and config validation ([b6976f2](https://github.com/NStefan002/visual-surround.nvim/commit/b6976f2b8298fe958c63e9d266402fc735d5d122))
* enable surrounding selection with custom text ([620e300](https://github.com/NStefan002/visual-surround.nvim/commit/620e300078399caa02f7061ad31ea0d7e414cb77))
* introduce `enable_wrapped_deletion` (see [#9](https://github.com/NStefan002/visual-surround.nvim/issues/9)) ([df4a5c3](https://github.com/NStefan002/visual-surround.nvim/commit/df4a5c30611c3c2ad5f906208a3d5202b74bd1ea))
* move default keys to config ([89a3ed9](https://github.com/NStefan002/visual-surround.nvim/commit/89a3ed99a95de2e4c6ec32b5ba95559c3a777ce7))
* slightly change default values ([c566f22](https://github.com/NStefan002/visual-surround.nvim/commit/c566f22460b9f32942703a5ea1b705bdcd57f313))
* support "`" by default, solves [#1](https://github.com/NStefan002/visual-surround.nvim/issues/1) ([81c5000](https://github.com/NStefan002/visual-surround.nvim/commit/81c50007db8eb18cefd4392dd039152bbe9011fd))
* support only Neovim 0.11 and later ([de5dbee](https://github.com/NStefan002/visual-surround.nvim/commit/de5dbeeffd7cef2e49b9830e9db7a9880b0be0cd))
* **surround_chars:** `&lt;` and `&gt;` are now enabled by default ([e36454f](https://github.com/NStefan002/visual-surround.nvim/commit/e36454f9807cfe13c5a145cf4b65d60c86a0c5b2)), closes [#9](https://github.com/NStefan002/visual-surround.nvim/issues/9) [#10](https://github.com/NStefan002/visual-surround.nvim/issues/10)
* update visual selection after surround ([2be3823](https://github.com/NStefan002/visual-surround.nvim/commit/2be38235580670fd212bf26deaf20d0993a6fa5e))


### Bug Fixes

* **bounds:** cursor column is one character after the line end ([918fc3a](https://github.com/NStefan002/visual-surround.nvim/commit/918fc3a584aa3cf76b8b1937e0728842d4bf63fb))
* **bounds:** edge-cases ([73a3a21](https://github.com/NStefan002/visual-surround.nvim/commit/73a3a2134f16b0af54400bcd87fc57e41aa4ca9b))
* **bounds:** rework bounds normalization ([a23b81e](https://github.com/NStefan002/visual-surround.nvim/commit/a23b81eb201ef6988cced7ad835c5e797041c18e))
* map in `x` mode to not interfere with `select-mode` ([78faad0](https://github.com/NStefan002/visual-surround.nvim/commit/78faad02f1ec36a4243f108a715b1372fcdcc0b1))
* **Readme:** showcase video ([13b37b8](https://github.com/NStefan002/visual-surround.nvim/commit/13b37b8c20b849f6e9a5125f3f2b1892defb413d))
* start_col must be less than end_col ([#4](https://github.com/NStefan002/visual-surround.nvim/issues/4)) ([273fc7e](https://github.com/NStefan002/visual-surround.nvim/commit/273fc7e6e141e30fffed29a7127d239f1de87cd4))
* **util:** copy-paste mistake... ([aeddf14](https://github.com/NStefan002/visual-surround.nvim/commit/aeddf14828f56c1d33e365449ee5bcc4249850d1))
* **util:** edge-case ([b34f08f](https://github.com/NStefan002/visual-surround.nvim/commit/b34f08f2d5a2a8ac6d062e9f9426a2af496ec348))
* **util:** fix visual bounds ([0ac614d](https://github.com/NStefan002/visual-surround.nvim/commit/0ac614da9c83d55d5b524912985baa91d6084517))
* **util:** visual bounds logic ([f24befb](https://github.com/NStefan002/visual-surround.nvim/commit/f24befbc0e9651461f16a83afc22cccef57a7a92))
