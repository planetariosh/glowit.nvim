local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)

local glowit = require('glowit')

vim.o.background = 'light'
glowit.setup({
  glow = {
    command = root .. '/tests/bin/fake-glow'
  }
})

local out, err = glowit.render({ '# Title', 'body' }, 60)
assert(err == nil, 'rendering valid markdown with light background should not return an error, got: ' .. tostring(err))
assert(out and string.find(out, 'args: -s light -w 60 -' , 1, true), 'render with light background failed, got: ' .. tostring(out))
assert(out and string.find(out, 'CLICOLOR_FORCE=1', 1, true), 'render with light background failed')

vim.o.background = 'dark'
glowit.setup({
  glow = {
    command = root .. '/tests/bin/fake-glow'
  }
})

out, err = glowit.render({ '# Title', 'body' }, 60)
assert(err == nil, 'rendering valid markdown with dark background should not return an error, got: ' .. tostring(err))
assert(out and string.find(out, 'args: -s dark -w 60 -' , 1, true), 'render with dark background failed, got: ' .. tostring(out))
assert(out and string.find(out, 'CLICOLOR_FORCE=1', 1, true), 'render with dark background failed')
assert(out and string.find(out, 'Title\nbody', 1, true), 'render did not output expected new lines')

vim.env.GLOWIT_FAKE_FAIL = '1'
out, err = glowit.render({ '# Title', 'body' }, 60)
assert(err and string.find(err, 'bad style', 1, true), 'glow failure should return an error')
assert(out == nil, 'glow failure should return nil')
vim.env.GLOWIT_FAKE_FAIL = nil

print 'glowit.nvim render test passed'
vim.cmd 'qa!'
