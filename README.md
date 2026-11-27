# glowit.nvim

**Markdown, rendered, one key away.**

A small Neovim plugin that shows the markdown buffer you are editing in a centered floating window,
rendered by [glow](https://github.com/charmbracelet/glow).

## Requirements

- Neovim 0.12 or newer
- [glow](https://github.com/charmbracelet/glow) on your `$PATH`

## Installation

### `vim.pack`

```lua
vim.pack.add { 'https://github.com/planetariosh/glowit.nvim' }

require('glowit').setup()
```

### lazy.nvim

```lua
{
  'planetariosh/glowit.nvim',
  config = function()
    require('glowit').setup()
  end,
}
```

`setup()` is required: it is what maps the key in markdown buffers.

## Configuration

`setup()` takes a table that is merged with the defaults. These are the
defaults:

```lua
require('glowit').setup {
  glow = {
    command = 'glow',
  },
  keymaps = {
    toggle = '<M-g>',
  },
  window = {
    width = 0.75,  -- fraction of the editor width
    height = 0.75, -- fraction of the editor height
  },
}
```

## Default keymaps

| Keys | Where | What it does |
| --- | --- | --- |
| `<M-g>` | normal mode, markdown buffers | Open the preview |
| `q`, `<Esc>`, `<M-g>` | the preview | Close it |

The preview is a terminal buffer in normal mode, so the usual motions
and searches work. The toggle key is mapped in normal mode only, and
only in markdown buffers.

## Behavior

- **It renders the buffer, not the file.** Unsaved edits show up.
- **It is a snapshot.** The preview does not follow your edits; toggle
  it again to refresh.

## Lua API

```lua
local glowit = require 'glowit'

glowit.open()     -- preview the current buffer
glowit.close()
glowit.toggle()
glowit.is_open()  -- true while a preview is shown
```

## Testing

The tests run in headless Neovim with no user config. They use a fake
glow (`tests/bin/fake-glow`), so glow does not need to be installed:

```sh
make test                                      # all tests
nvim --headless -u NONE -l tests/render.lua    # one test
```

## License

MIT. See [LICENSE](LICENSE).
