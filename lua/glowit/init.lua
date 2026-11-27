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
  },
}

local config = vim.deepcopy(defaults)
local state = {
  buf = nil,
  win = nil,
}

local function width()
  return math.max(20, math.floor(vim.o.columns * config.window.width))
end

local function height()
  return math.floor(vim.o.lines * config.window.height)
end

local function cols()
  return math.floor((vim.o.columns - width()) / 2)
end

local function rows()
  return math.floor((vim.o.lines - height()) / 2)
end

local function title()
  local buffer_title = vim.fn.expand('%:t')
  if buffer_title ~= '' then
    return buffer_title
  end

  return 'glowit'
end

local function preview_config()
  return {
    relative = 'editor',
    style = 'minimal',
    width = width(),
    height = height(),
    col = cols(),
    row = rows(),
    border = 'rounded',
    title = title(),
    title_pos = 'center',
  }
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

local function open_float(buf)
  return vim.api.nvim_open_win(buf, true, preview_config())
end

function M.open()
  if vim.fn.executable(config.glow.command) ~= 1 then
    vim.notify('glowit.nvim: glow not found: ' .. config.glow.command, vim.log.levels.WARN)
    return
  end

  M.close()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local out, err = M.render(lines, width())

  if out == nil then
    if err ~= nil then
      vim.notify('glowit.nvim: failed to render: ' .. vim.trim(err), vim.log.levels.ERROR)
    end

    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = 'wipe'
  state.win = open_float(state.buf)

  local chan = vim.api.nvim_open_term(state.buf, {})
  local parsed, _ = string.gsub(out, '\n', '\r\n')
  vim.api.nvim_chan_send(chan, parsed)
  vim.api.nvim_win_set_cursor(state.win, { 1, 0 })

  vim.keymap.set('n', 'q', M.close, { buffer = state.buf })
  vim.keymap.set('n', '<Esc>', M.close, { buffer = state.buf })
  if config.keymaps.toggle then
    vim.keymap.set('n', config.keymaps.toggle, M.toggle, { buffer = state.buf })
  end

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = state.buf,
    callback = function()
      state.win = nil
      state.buf = nil
    end,
    desc = 'Wipe Glowit state',
  })
end

function M.close()
  if M.is_open() then
    vim.api.nvim_win_close(state.win, true)
  end
end

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.render(lines, w)
  local result = vim.system(
    {
      config.glow.command,
      '-s', vim.o.background,
      '-w', tostring(w),
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

  local group = vim.api.nvim_create_augroup('glowit', { clear = true })
  if config.keymaps.toggle then
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'markdown',
      callback = function(args)
        vim.keymap.set({ 'n' }, config.keymaps.toggle, M.toggle, {
          buffer = args.buf,
          desc = 'Markdown preview',
        })
      end,
    })
  end
end

return M
