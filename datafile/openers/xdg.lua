
--- @module datafile.openers.xdg
-- datafile module following the freedesktop.org XDG Base Directory Specification
-- http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
local xdg = {}

local util = require("datafile.util")

local function split(var)
   local list = {}
   for entry in var:gmatch("([^:]+)") do
      list[#list+1] = entry
   end
   return list
end

local HOME = os.getenv("HOME")
local XDG_DATA_HOME   = os.getenv("XDG_DATA_HOME")   or HOME.."/.local/share"
local XDG_CONFIG_HOME = os.getenv("XDG_CONFIG_HOME") or HOME.."/.config"
local XDG_CACHE_HOME  = os.getenv("XDG_CACHE_HOME")  or HOME.."/.cache"
local XDG_RUNTIME_DIR = os.getenv("XDG_RUNTIME_DIR")

local XDG_DATA_DIRS = split(os.getenv("XDG_DATA_DIRS") or "/usr/local/share:/usr/share")
table.insert(XDG_DATA_DIRS, 1, XDG_DATA_HOME)
table.insert(XDG_DATA_DIRS, XDG_RUNTIME_DIR)

local XDG_CONFIG_DIRS = split(os.getenv("XDG_CONFIG_DIRS") or "/etc/xdg")
table.insert(XDG_CONFIG_DIRS, 1, XDG_CONFIG_HOME)

local XDG_CACHE_DIRS = { XDG_CACHE_HOME, XDG_RUNTIME_DIR }

function xdg.opener(file, mode, context)
   if not file then
      return nil, "missing argument"
   end
   mode = mode or "r"
   local dirs = XDG_DATA_DIRS
   if context == "config" then
      dirs = XDG_CONFIG_DIRS
   elseif context == "cache" then
      dirs = XDG_CACHE_DIRS
   end
   return util.try_dirs(dirs, file, mode)
end

return xdg
