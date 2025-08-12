local api = vim.api
local vs = require("visual-surround")
local util = require("visual-surround.util")
local eq = assert.are.same

describe("visual-surround", function()
    before_each(function()
        vim.cmd("enew!") -- new buffer
        api.nvim_buf_set_lines(0, 0, -1, false, {
            "foo bar",
            "baz qux",
        })
        api.nvim_win_set_cursor(0, { 1, 0 })
    end)

    after_each(function()
        vs.setup() -- reset to defaults
    end)

    describe("surround functionality", function()
        before_each(function()
            vs.setup({ exit_visual_mode = false, enable_wrapped_deletion = true })
        end)

        it("add and remove surround in visual mode", function()
            -- simulate visual selection
            vim.cmd("normal! viw")
            -- surround with ()
            vs.surround("(")
            local line = api.nvim_get_current_line()
            eq("(foo) bar", line)
            -- remove surround
            vs.surround("(")
            line = api.nvim_get_current_line()
            eq("foo bar", line)
        end)

        it("add and remove surround in visual block mode", function()
            -- simulate visual selection
            vim.cmd("normal! Vj")
            -- surround with ()
            vs.surround("(")
            local lines = api.nvim_buf_get_lines(0, 0, -1, false)
            eq({ "(foo bar", "baz qux)" }, lines)
            -- move one line up
            vim.cmd("normal! k")
            -- surround with ()
            vs.surround("(")
            lines = api.nvim_buf_get_lines(0, 0, -1, false)
            eq({ "((foo bar)", "baz qux)" }, lines)
            -- move one line down
            vim.cmd("normal! j")
            -- remove surround
            vs.surround("(")
            lines = api.nvim_buf_get_lines(0, 0, -1, false)
            eq({ "(foo bar)", "baz qux" }, lines)
        end)

        it("add and remove surround in visual line mode", function()
            -- simulate visual selection
            vim.cmd(("normal! %sjl"):format(api.nvim_replace_termcodes("<c-v>", true, false, true)))
            -- surround with ()
            vs.surround("(")
            local lines = api.nvim_buf_get_lines(0, 0, -1, false)
            eq({ "(fo)o bar", "(ba)z qux" }, lines)
            -- remove surround
            vs.surround("(")
            lines = api.nvim_buf_get_lines(0, 0, -1, false)
            eq({ "foo bar", "baz qux" }, lines)
        end)
    end)

    describe("util", function()
        it("get_char_pair returns correct pairs", function()
            eq({ "(", ")" }, { util.get_char_pair("(") })
            eq({ "[", "]" }, { util.get_char_pair("[") })
            eq({ "{", "}" }, { util.get_char_pair("{") })
            eq({ "<", ">" }, { util.get_char_pair("<") })
            eq({ "'", "'" }, { util.get_char_pair("'") })
            eq({ '"', '"' }, { util.get_char_pair('"') })
            eq({ "x", "x" }, { util.get_char_pair("x") })
        end)

        it("trim splits whitespace correctly", function()
            local before, trimmed, after = util.trim("   foo bar   ")
            eq("   ", before)
            eq("foo bar", trimmed)
            eq("   ", after)
        end)
    end)
end)
