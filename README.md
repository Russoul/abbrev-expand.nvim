# abbrev-expand.nvim

## Preview

<img src="demo.gif" width="450em"/>

## Setup

Setup used in the demo (press `<C-]>` at the end of an abbreviation in insert mode, on its last character in normal mode, or with it selected in visual mode to expand):

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

vim.keymap.set('i', '<C-]>', function() return '<Left><C-o>' .. require('abbrev-expand').expand_repeatable() .. '<Right>' end,
               {expr = true})
vim.keymap.set('n', '<C-]>', require('abbrev-expand').expand_repeatable, {expr = true})
vim.keymap.set('x', '<C-]>', function() return '<Esc>`>' .. require('abbrev-expand').expand_repeatable() end,
               {expr = true})

```

Expansions can be repeated with `.`: after expanding one abbreviation, put the cursor on the last character of another and press `.` to expand it too. For an insert-mode expansion, this works when you leave insert mode right after `<C-]>`; if you type more text first, `.` repeats that text instead, as usual in Vim.
