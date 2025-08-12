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
    end)

    describe("surround functionality", function()
        it("add and remove surround in visual mode", function()
            vs.setup({ exit_visual_mode = false, enable_wrapped_deletion = true })
            -- simulate visual selection
            api.nvim_win_set_cursor(0, { 1, 1 })
            vim.cmd("normal viw")
            -- surround with ()
            vs.surround("(")
            local line = api.nvim_get_current_line()
            eq("(foo) bar", line)
            -- remove surround
            vs.surround("(")
            line = api.nvim_get_current_line()
            eq("foo bar", line)
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
