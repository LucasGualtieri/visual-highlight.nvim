# visual-highlight.nvim

<!-- ![Demo](https://media.giphy.com/media/your-demo-gif-here.gif) *(You should add a demo gif later)* -->

Highlight all matches of your visual selection in real-time - like VSCode's match highlighting

## Features

- Real-time highlighting as you select text in visual mode
- Supports character-wise, line-wise, and block-wise visual modes
- Customizable highlight colors
- Lightweight and performant

## Installation

Using [Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "LucasGualtieri/visual-highlight.nvim",
    config = function()
        require('visual-highlight').setup({
            -- Custom configuration (optional)
            highlight_color = "#3a3a3a",  -- Default highlight color
        })
    end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'LucasGualtieri/visual-highlight.nvim',
    config = function()
        require('visual-highlight').setup()
    end
}
```

## Default configuration:
```lua
{
    highlight_group = "VisualMatches",  -- Name of the highlight group
    highlight_color = "#3a3a3a",       -- Default highlight color
    enable_in_visual = true,           -- Enable in character-wise visual mode
    enable_in_line = true,             -- Enable in line-wise visual mode
    enable_in_block = true,            -- Enable in block-wise visual mode
}
```

## Roadmap
- Implement Boyer-Moore algorithm for faster matching
- Add option to limit highlighting to visible range
- Add option to disable for large files
- Add toggle command

## Contributing
Pull requests are welcome! Please follow the existing code style and add tests for new features.


## Current Status: v1.0.0 (Stable)

First stable release featuring:
- Basic brute-force matching
- Core visual mode support
- Simple configuration
