local M = {}

local defaults = {
  glow = {
    command = 'glow',
  },
  keymaps = {
    toggle = '<M-g>',
  },
  window = {
    width = 0.75,
    height = 0.75,
    border = 'rounded',
  },
}

local config = vim.deepcopy(defaults)

function M.toggle()
  print 'toggling markdown preview!'
end

function M.render(lines, width)
  local result = vim.system(
    {
      config.glow.command,
      '-s', vim.o.background,
      '-w', tostring(width),
      '-'
    },
    {
      stdin = lines,
      env = { CLICOLOR_FORCE = '1' },
      text = true
    }
  ):wait()

  if result.code ~= 0 then
    return nil, result.stderr
  end

  return result.stdout
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})

  if config.keymaps.toggle then
    vim.keymap.set({ 'n', 't' }, config.keymaps.toggle, M.toggle, {
      desc = 'Markdown preview',
    })
  end
end

return M
