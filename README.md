# abbrev-expand.nvim

## Preview

<img src="demo.gif" width="450em"/>

## Setup

Setup used in the demo (press `<C-]>` at the end of an abbreviation in insert mode and anywhere in visual mode to expand):

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

vim.api.nvim_set_keymap('i', '<C-]>', '<Left><C-o>:lua require("abbrev-expand").expand(".")<CR><Right>',
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('x', '<C-]>', ':lua require("abbrev-expand").expand("\'>")<CR>',
                        {noremap = true, silent = true})

```

To also expand in terminal buffers (shells, REPLs, fzf prompts, ...), map `<C-]>` in terminal mode:

```lua
vim.keymap.set('t', '<C-]>', function() require("abbrev-expand").expand_term() end)
```

The text before the terminal cursor is read off the screen, and the abbreviation is replaced by sending backspaces followed by the expansion to the running program, so this works with any program that treats `DEL` as backspace.
