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

-- eta<C-]>   ==> η
-- \eta<C-]>  ==> η
-- Theta<C-]>  ==> ϴ
-- Th\eta<C-]> ==> Thη
function M.expand(expr)
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

function M.setup(params)
  M.delim = params.delim or "\\"
  M.map = params.map or {}
end

return M
