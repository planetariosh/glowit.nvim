local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')

local glowit = require('glowit')
local helpers = require('helpers')

local calls = {}
local original = vim.notify
vim.notify = function(msg, level, _)
  table.insert(calls, { msg = msg, level = level })
end

local fake = root .. '/tests/bin/fake-glow'

local source = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(source, 0, -1, false, { '# Title', 'body' })

local buffers = #vim.api.nvim_list_bufs()
local win = vim.api.nvim_get_current_win()

local function assert_attempt(n, level, prefix, needle)
  assert(helpers.float_count() == 0, 'a floating window was left open')
  assert(#vim.api.nvim_list_bufs() == buffers, 'a buffer was left behind')
  assert(vim.api.nvim_get_current_win() == win, 'focus moved away from the source window')
  assert(not glowit.is_open(), 'is_open() is true after a failed open()')

  assert(#calls == n, 'expected ' .. n .. ' notification(s), got ' .. #calls)
  local call = calls[n]
  assert(call.level == level, 'unexpected level ' .. tostring(call.level) .. ' for: ' .. call.msg)
  assert(string.find(call.msg, prefix, 1, true) == 1, 'unexpected message: ' .. call.msg)
  if needle then
    assert(string.find(call.msg, needle, 1, true), 'message lacks "' .. needle .. '": ' .. call.msg)
  end
end

-- glow is not installed
glowit.setup({ glow = { command = 'no-glow-here' } })
glowit.open()
assert_attempt(1, vim.log.levels.WARN, 'glowit.nvim: glow not found')

-- glow runs but fails (Review Focus 3)
glowit.setup({ glow = { command = fake } })
vim.env.GLOWIT_FAKE_FAIL = '1'
glowit.open()
vim.env.GLOWIT_FAKE_FAIL = nil
assert_attempt(2, vim.log.levels.ERROR, 'glowit.nvim: ', 'bad style')

-- a failure leaves glowit usable
glowit.open()
assert(helpers.float_count() == 1, 'preview did not open after earlier failures')
assert(#calls == 2, 'unexpected notification: ' .. tostring(calls[#calls].msg))

vim.notify = original
print 'glowit.nvim errors test passed'
vim.cmd 'qa!'
