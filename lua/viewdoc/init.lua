local utils = require("viewdoc.utils")
local log = utils.log
_VIEWDOC_CFG = { debug = true }

local function setup(cfg)
  cfg = cfg or {}
  _VIEWDOC_CFG = vim.tbl_extend("force", _VIEWDOC_CFG, cfg)
  vim.cmd([[command! -nargs=* Viewdoc lua require"viewdoc".view(<f-args>)]])
end

local guihua_term = utils.load_plugin("guihua.lua", "guihua.floating")
if not guihua_term then
  utils.warn("guihua not installed, please install ray-x/guihua.lua for GUI functions")
end

-- local function preview_uri(opts) -- uri, width, line, col, offset_x, offset_y
--   -- local handle = vim.loop.new_async(vim.schedule_wrap(function()
--   local line_beg = 1
--   local loc = { uri = opts.uri, range = { start = { line = line_beg } } }
--
--   -- TODO: preview height
--   loc.range["end"] = { line = opts.lnum + opts.preview_height or 30 }
--   opts.location = loc
--
--   utils.log("uri", opts.uri, opts.lnum, opts.location.range.start.line, opts.location.range["end"].line)
--   return require("guihua.gui")._preview_location(opts)
-- end

local term = require("guihua.floating").gui_term

local runtimepath = vim.split(vim.o.runtimepath, ",")
local view = function(path)
  local pwd = {}
  if path ~= nil then
    for _, p in pairs(runtimepath) do
      if p:find(path) then
        table.insert(pwd, p)
      end
    end
  else
    pwd = { vim.fn.getcwd() }
  end

  if _VIEWDOC_CFG.paths then
    pwd = vim.list_extend(pwd, _VIEWDOC_CFG.paths)
  end
  local readmes = {}
  local width = 90

  utils.log(pwd)

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
            return term({ cmd = "glow " .. readme_chosen, term_name = "readme_floaterm", autoclose = false })
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
    -- local listview = gui.new_list_view({
    --   items = display_items,
    --   loc = "top_center",
    --   -- height = #display_items + 2,
    --   -- width_ratio = 0.8,
    --   -- preview_height = 30,
    --   border = "single",
    --   rawdata = true,
    --   ft = "markdown",
    --   data = readmes,
    --   -- rect = { height = 5, width = width, pos_x = 0, pos_y = 0 },
    --   on_confirm = function(item)
    --     for i = 1, #display_items do
    --       if display_items[i] == item then
    --         local readme_chosen = readmes[i]
    --         utils.log(readme_chosen)
    --         return term({ cmd = "glow " .. readme_chosen, term_name = "readme_floaterm", autoclose = false })
    --       end
    --     end
    --   end,
    --   on_move = function(item)
    --     local readme_chosen
    --     for i = 1, #display_items do
    --       if display_items[i] == item then
    --         readme_chosen = readmes[i]
    --         utils.log(readme_chosen)
    --       end
    --     end
    --     local opts = {
    --       uri = "file:///" .. readme_chosen,
    --       lnum = 1,
    --       preview_height = 60,
    --       -- width_ratio = 0.5,
    --       offset_x = 0,
    --       offset_y = r + #display_items + 1,
    --       range = { start = {} },
    --     }
    --     preview_uri(opts)
    --   end,
    -- })
  else
    term({ cmd = "glow ", autoclose = true })
  end
end

view("git")
return { view = view, setup = setup }
