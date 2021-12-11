# Viewdoc

Flexible viewer for any documentation source (help/man/markdow/etc.) inside Vim runtime path (vim plugins) or pre-configured paths.
You can preview the documents and view the selected document with glow in floating window

## Install

```vim
Plug 'ray-x/guihua.lua' --float term, gui support

Plug 'ray-x/go.nvim'

```

## Dependencies

- fd
- glow

## setup

```lua
require 'viewdoc'.setup({
  paths = {'myproject_path1', 'myproject_path2'}
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
