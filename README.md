# Viewdoc

Flexible viewer for any documentation source (help/man/markdow/etc.). Search and filter inside Vim runtime path (vim plugins) or pre-configured paths.
You can preview the documents with nvim and view the selected document with glow or mdcat(with embedded image support) in floating window

## Install

```vim
Plug 'ray-x/guihua.lua' "float term, gui support

Plug 'ray-x/go.nvim'

```

## Dependencies

- [fd](https://github.com/sharkdp/fd)
- [glow](https://github.com/charmbracelet/glow)
- [mdcat](https://codeberg.org/flausch/mdcat/) preview markdown with embedded image support

## setup

```lua
require 'viewdoc'.setup({
  paths = {'myproject_path1', 'myproject_path2'}
    md_viewer = 'glow', -- or 'mdcat'
})


```

## usage

- Check gitsigns document

```
:Viewdoc gitsigns
```

- Check sarama (a go kafka) document

```lua
:Viewdoc sarama
```

- Check document in current project

```lua
:Viewdoc
```

## Screenshots

![select](https://user-images.githubusercontent.com/1681295/145674599-44f4f701-9090-4ba7-a6c0-558f16d28b6e.jpg)
![glow](https://user-images.githubusercontent.com/1681295/145674603-991e2ac7-e8eb-4269-afbd-da8bb7678302.jpg)
