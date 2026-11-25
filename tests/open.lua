local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')

local glowit = require('glowit')
local helpers = require('helpers')

local function join(buf)
  return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end

local source_win
local preview_win
local preview_buf
local preview_config

local calls = {}
local original = vim.notify
vim.notify = function(msg, level, _)
  table.insert(calls, { msg = msg, level = level })
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
preview_win = vim.api.nvim_get_current_win()
preview_buf = vim.api.nvim_win_get_buf(preview_win)
preview_config = vim.api.nvim_win_get_config(preview_win)

assert(source_win ~= preview_win, 'preview did not open in a new window')
assert(helpers.float_count() == 1, 'preview did not open in a floating window')
assert(helpers.term_count() == 1, 'preview did not open a terminal')
assert(preview_config.title[1][1] == 'README.md', 'preview title was not set')
assert(preview_config.width == 60, 'preview width was not set')

assert(
  vim.wait(1000, function() return string.find(join(preview_buf), '# Title', 1, true) end),
  'preview did not render the markdown'
)

assert(vim.api.nvim_get_mode().mode == 'nt', 'preview did not open terminal in normal mode')
assert(vim.api.nvim_win_get_cursor(preview_win)[1] == 1, 'preview did not start at the top')
assert(string.find(join(preview_buf), '-w 60', 1, true), 'glow did not get window\'s width')

vim.api.nvim_set_current_win(source_win)
glowit.open()
assert(helpers.float_count() == 1, 'preview did not open in a new floating window')

vim.api.nvim_set_current_win(source_win)
vim.api.nvim_win_set_buf(source_win, vim.api.nvim_create_buf(true, false))
glowit.open()
preview_win = vim.api.nvim_get_current_win()
preview_config = vim.api.nvim_win_get_config(preview_win)
assert(preview_config.title[1][1] == 'glowit', 'empty buffer preview should be titled glowit')
assert(#calls == 0, 'empty buffer should not notify')

vim.o.columns = 24
vim.api.nvim_set_current_win(source_win)
glowit.open()
preview_win = vim.api.nvim_get_current_win()
preview_buf = vim.api.nvim_win_get_buf(preview_win)
preview_config = vim.api.nvim_win_get_config(preview_win)
assert(
  vim.wait(1000, function() return string.find(join(preview_buf), '-w 20', 1, true) end),
  'glow width went below the 20 minimum'
)
assert(preview_config.width == 20, 'preview width went below the 20 minimum')

vim.notify = original
print 'glowit.nvim open test passed'
vim.cmd 'qa!'
