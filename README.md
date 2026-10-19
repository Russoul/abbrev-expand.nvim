# abbrev-expand.nvim

## Preview

<img src="demo.gif" width="450em"/>

## Setup

Setup used in the demo (press `<C-]>` at the end of an abbreviation in insert, command-line or terminal mode, or anywhere in visual mode to expand):

```lua
require('abbrev-expand').setup {
  map = {
    {"hooray", "🥳"},
    {"eta", "η"},
    {"Theta", "theta"},
    {"[", "⟦"},
    {"]", "⟧"},
    {"union", "∪"},
    {"iff", "⇔"},
    {"and", "∧"},
    {"elem", "∈"}
 }
}

vim.keymap.set({'i', 'c', 't'}, '<C-]>', function() require("abbrev-expand").expand() end)
vim.api.nvim_set_keymap('x', '<C-]>', ':lua require("abbrev-expand").expand("\'>")<CR>',
                        {noremap = true, silent = true})

```

In insert and command-line modes, the abbreviation is erased with backspaces and the expansion is typed in its place, so undo and `.` treat it as part of what you typed.

In terminal buffers (shells, REPLs, fzf prompts, ...), the text before the terminal cursor is read off the screen, and the abbreviation is replaced by sending backspaces followed by the expansion to the running program, so this works with any program that treats `DEL` as backspace.
