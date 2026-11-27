local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')

local glowit = require('glowit')

local function create_buffer(filetype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = filetype
end

local function is_mapped(key, mode)
  return not vim.tbl_isempty(vim.fn.maparg(key, mode, false, true))
end

local function is_not_mapped(key, mode)
  return not is_mapped(key, mode)
end

local function is_buffer_local(key, mode)
  return vim.fn.maparg(key, mode, false, true).buffer == 1
end

glowit.setup({})
create_buffer('markdown')
assert(is_buffer_local('<M-g>', 'n'), 'markdown buffer has no local <M-g> map')

create_buffer('lua')
assert(is_not_mapped('<M-g>', 'n'), 'lua buffer has a <M-g> map in normal mode')
assert(is_not_mapped('<M-g>', 't'), 'lua buffer has a <M-g> map in terminal mode')

glowit.setup({ keymaps = { toggle = '<leader>p' } })
create_buffer('markdown')
assert(is_mapped('<leader>p', 'n'), 'markdown buffer has no local <leader>p map')
assert(is_not_mapped('<M-g>', 'n'), 'markdown buffer has local <M-g> map')

glowit.setup({ keymaps = { toggle = false } })
create_buffer('markdown')
assert(is_not_mapped('<M-g>', 'n'), 'markdown buffer has local <M-g> map')
assert(is_not_mapped('<leader>p', 'n'), 'markdown buffer has local <leader>p map')

glowit.setup()
glowit.setup()
assert(#vim.api.nvim_get_autocmds({ group = 'glowit' }) == 1, 'multiple autocmds were created')

print 'glowit.nvim keymap test passed'
vim.cmd 'qa!'
