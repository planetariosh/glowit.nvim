local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')

local glowit = require('glowit')
local helpers = require('helpers')

local source_win
local function assert_closed(how)
  assert(helpers.float_count() == 0, 'float left open after ' .. how)
  assert(helpers.term_count() == 0, 'term left open after ' .. how)
  assert(vim.api.nvim_get_current_win() == source_win, 'focus did not come back after ' .. how)
  assert(glowit.is_open() == false, 'glowit is still open after ' .. how)
end

glowit.setup({
  glow = {
    command = root .. '/tests/bin/fake-glow'
  }
})

vim.api.nvim_buf_set_name(0, 'README.md')
vim.api.nvim_buf_set_lines(0, 0, -1, false, { '# Title', 'body' })
source_win = vim.api.nvim_get_current_win()

glowit.open()
glowit.close()
assert_closed('close()')

for _, key in ipairs({'q', '<Esc>', '<M-g>'}) do
  glowit.open()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'x', false)
  assert_closed(key)
end

glowit.open()
vim.cmd 'close'
assert_closed(':close')

glowit.open()
assert(helpers.float_count() == 1, 'float was not created after open()')
assert(glowit.is_open(), 'preview is not open after open()')
glowit.close()

glowit.toggle()
assert(helpers.float_count() == 1, 'float was not created after toggle()')
assert(glowit.is_open(), 'preview is not open after toggle()')
glowit.toggle()
assert_closed('toggle()')

print 'glowit.nvim close test passed'
vim.cmd 'qa!'

