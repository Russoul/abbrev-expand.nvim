local M = {}

local function esc(x)
   return (x:gsub('%%', '%%%%')
            :gsub('^%^', '%%^')
            :gsub('%$$', '%%$')
            :gsub('%(', '%%(')
            :gsub('%)', '%%)')
            :gsub('%.', '%%.')
            :gsub('%[', '%%[')
            :gsub('%]', '%%]')
            :gsub('%*', '%%*')
            :gsub('%+', '%%+')
            :gsub('%-', '%%-')
            :gsub('%?', '%%?'))
end

-- Small test suite:
-- assuming M.map = {{"eta", "η"}, {"Theta", "ϴ"}}
--          M.delim = "\\"
-- find_longest_match("Greek capital Theta") = 5, "ϴ"
-- find_longest_match("Greek small eta") = 3, "η"
-- find_longest_match("Greek small \eta") = 4, "η"
-- find_longest_match("Greek small beta") = nil
local function find_longest_match(txt)
  local longest_length = 0
  local the_key = ""
  local to_subst = ""
  for _, abbrev in ipairs(M.map) do
    local key = abbrev[1]
    local subst = abbrev[2]
    local m = txt:match(esc(key) .. '$')
    if m and #m > longest_length then
      longest_length = #m
      to_subst = subst
      the_key = key
    end
  end
  if to_subst ~= "" then
    local to_remove_len = #the_key
    local up_to_match = txt:sub(0, -(longest_length + 1))
    if up_to_match:sub(#up_to_match, #up_to_match) == M.delim then
      to_remove_len = to_remove_len + 1
    end
    return to_remove_len, to_subst
  else
    return nil
  end
end

-- Expands the abbreviation ending at position `expr` (see `getpos()`) by
-- editing the buffer directly
local function expand_at(expr)
  local line_txt = vim.fn.getline(expr)
  local buf = vim.fn.getpos(expr)[1]
  local line = vim.fn.getpos(expr)[2]
  local col = vim.fn.getpos(expr)[3]
  local offset = vim.fn.getpos(expr)[4]
  if not line_txt or not col then
    vim.fn.echom("Can't expand: getline | getpos returned nil")
  else
    local up_to_cursor = line_txt:sub(0, col)
    local to_remove_len, subst = find_longest_match(up_to_cursor)
    if to_remove_len then
      vim.api.nvim_buf_set_text(buf, line - 1, col - to_remove_len, line - 1, col, {subst})
      vim.fn.setpos('.', {buf, line, col - to_remove_len + #subst, offset})
    end
  end
end

-- Expands the abbreviation at the end of `up_to_cursor` the way the user would:
-- by erasing it with backspaces and typing the substitution in its place.
-- That keeps the expansion a part of the insertion for undo and `.`.
local function retype(up_to_cursor)
  local to_remove_len, subst = find_longest_match(up_to_cursor)
  if to_remove_len then
    -- Backspace erases characters, not bytes
    local n_chars = vim.fn.strchars(up_to_cursor:sub(-to_remove_len))
    -- With the 'i' flag, each call puts its keys in front of the pending input,
    -- so the backspaces, fed last, come first. The substitution is escaped: its
    -- UTF-8 bytes may include 0x80, which Neovim would read as a key code.
    vim.api.nvim_feedkeys(subst, 'in', true)
    vim.api.nvim_feedkeys(vim.keycode('<BS>'):rep(n_chars), 'in', false)
  end
end

-- Expands the abbreviation before the cursor in insert, command-line and
-- terminal modes. If `expr` is given, expands the abbreviation ending at that
-- position (see `getpos()`) instead, e.g. "'>" for the end of the visual selection.
--
-- eta<C-]>   ==> η
-- \eta<C-]>  ==> η
-- Theta<C-]>  ==> ϴ
-- Th\eta<C-]> ==> Thη
function M.expand(expr)
  if expr then
    expand_at(expr)
    return
  end
  local mode = vim.api.nvim_get_mode().mode
  if mode == 't' then
    M.expand_term()
  elseif mode:sub(1, 1) == 'c' then
    retype(vim.fn.getcmdline():sub(1, vim.fn.getcmdpos() - 1))
  elseif mode:sub(1, 1) == 'i' then
    local col = vim.api.nvim_win_get_cursor(0)[2]
    retype(vim.api.nvim_get_current_line():sub(1, col))
  end
end

-- Same as `expand`, but for the current terminal buffer in terminal mode.
-- A terminal buffer only mirrors the screen of the program running in it, so
-- instead of editing the buffer, the abbreviation is erased by sending
-- backspaces to the program and the substitution is typed in its place.
function M.expand_term()
  local chan = vim.bo.channel
  if chan == 0 then
    return
  end
  -- In terminal mode the window cursor tracks the terminal cursor
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line_txt = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  local up_to_cursor = line_txt:sub(1, col)
  local to_remove_len, subst = find_longest_match(up_to_cursor)
  if to_remove_len then
    -- The program erases characters, not bytes
    local n_chars = vim.fn.strchars(up_to_cursor:sub(-to_remove_len))
    vim.api.nvim_chan_send(chan, string.rep("\127", n_chars) .. subst)
  end
end

function M.setup(params)
  M.delim = params.delim or "\\"
  M.map = params.map or {}
end

return M
