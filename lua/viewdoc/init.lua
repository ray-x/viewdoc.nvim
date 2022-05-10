local utils = require("viewdoc.utils")
local log = utils.log
_VIEWDOC_CFG = { debug = true, md_viewer = "glow" }

local guihua_term = utils.load_plugin("guihua.lua", "guihua.floating")
if not guihua_term then
  utils.warn("guihua not installed, please install ray-x/guihua.lua for GUI functions")
end
local function setup(cfg)
  cfg = cfg or {}
  _VIEWDOC_CFG = vim.tbl_extend("force", _VIEWDOC_CFG, cfg)
  vim.cmd([[command! -nargs=* Viewdoc lua require"viewdoc".view(<f-args>)]])
  local installed = require("guihua.helper").is_installed
  if not installed("fd") then
    print("please install fd, e.g. `brew install fd`")
  end

  if not installed("glow") and not installed("mdcat") then
    print("please install glow or mdcat, e.g. `brew install glow`")
  end
end

local term = require("guihua.floating").gui_term

local runtimepath = vim.split(vim.o.runtimepath, ",")
local view = function(path)
  local pwd = {}
  local filemode = false
  if path == nil then
    if vim.o.ft == "md" then
      filemode = true
      path = vim.fn.expand("%:p")
    else
      for _, p in pairs(runtimepath) do
        if p:find("md") or p:find("txt") or p:find("org") then
          table.insert(pwd, p)
        end
      end
    end
  else
    if vim.fn.isdirectory(path) == 1 then
      table.insert(pwd, path)
    elseif vim.fn.filereadable(path) == 1 then
      filemode = true
    else
      for _, p in pairs(runtimepath) do
        if p:find(path) then
          table.insert(pwd, p)
        end
      end
    end
  end

  if _VIEWDOC_CFG.paths then
    pwd = vim.list_extend(pwd, _VIEWDOC_CFG.paths)
  end
  local readmes = {}
  local width = 90

  utils.log("args", pwd, path, filemode)
  if filemode then
    term({ cmd = _VIEWDOC_CFG.md_viewer .. " " .. path, autoclose = false })
    return
  end

  -- if true then
  --   return
  -- end

  for _, p in pairs(pwd) do
    -- fd -L -p  'gitsigns\.nvim.*\.(md|txt)$'
    local cmd = "fd -e md -e txt -e norg . " .. p

    utils.log(cmd)
    local readme_files = vim.fn.system(cmd)
    readme_files = vim.split(readme_files, "\n")

    utils.log(readme_files)
    for _, r in pairs(readme_files) do
      if #r > 1 then
        table.insert(readmes, r)
      end
    end
  end
  local display_items = { unpack(readmes) }

  local home = vim.fn.expand("$HOME")
  for i = 1, #display_items do
    local homepos = string.find(display_items[i], home)
    if homepos == 1 then
      local shortpath = string.sub(display_items[i], #home + 1)
      shortpath = "~" .. shortpath
      display_items[i] = shortpath
    end
    if #display_items[i] > 80 then
      display_items[i] = vim.fn.pathshorten(display_items[i])
    end
  end
  utils.log(readmes)

  local top_center = require("guihua.location").top_center
  local r, _ = top_center(#readmes, width)

  if #readmes == 1 then
    term({ cmd = _VIEWDOC_CFG.md_viewer .. " " .. readmes[1], autoclose = true })
  end
  if #readmes > 1 then
    local gui = require("guihua.gui")

    gui.new_list_view({
      items = display_items,
      prompt = true,
      rawdata = true,
      loc = "top_center",
      data = readmes,
      width_ratio = 0.7,
      ft = "markdown",
      api = " ",
      border = "single",

      on_confirm = function(item)
        for i = 1, #display_items do
          if display_items[i] == item then
            local readme_chosen = readmes[i]
            utils.log(readme_chosen)
            return term({
              cmd = _VIEWDOC_CFG.md_viewer .. " " .. readme_chosen,
              term_name = "readme_floaterm",
              autoclose = false,
            })
          end
        end
      end,
      on_move = function(item)
        local readme_chosen
        for i = 1, #display_items do
          if display_items[i] == item then
            readme_chosen = readmes[i]
            utils.log(readme_chosen)
          end
        end
        local opts = {
          uri = "file:///" .. readme_chosen,
          lnum = 1,
          preview_height = 60,
          width_ratio = 0.7,
          offset_x = 0,
          offset_y = r + #display_items + 1,
          range = { start = {} },
        }
        gui.preview_uri(opts)
      end,
    })
  end
end

-- view("git")
return { view = view, setup = setup }
