
--- @module datafile.openers.config
-- datafile module for Unix config files
-- datafile.open("foo/bar.cfg", "r", "config") will try /etc/foo/bar.cfg and $HOME/.foo/bar.cfg
local unix_config = {}

local util = require("datafile.util")

local home = os.getenv("HOME")

function unix_config.opener(file, mode, context)
   local dirs = {}
   local level, source = util.stacklevel()
   if level and source:match("^@") then
      source = source:sub(2)
      -- Start with a reasonable guess if it's a well-installed module...
      local prefix, luaver, modpath = source:match("(.*)/[^/]+/lua/([^/]+)/.*")
      if prefix and luaver and modpath then
         if context == "config" then
            table.insert(dirs, prefix .. "/etc")
         else
            table.insert(dirs, prefix .. "/share/lua/" .. luaver)
            table.insert(dirs, prefix .. "/lib/lua/" .. luaver)
            table.insert(dirs, prefix .. "/share")
            table.insert(dirs, prefix .. "/lib")
         end
      end
   end
   if context == "config" then
      table.insert(dirs, home.."/.config")
      table.insert(dirs, home.."/.|") -- the pipe marker tells not to add a trailing slash
      table.insert(dirs, "/etc/")
   elseif context == "cache" then
      table.insert(dirs, home.."/.cache")
      table.insert(dirs, "/var/cache")
      table.insert(dirs, "/var/run")
      table.insert(dirs, "/var/lib")
   else
      table.insert(dirs, "/usr/share")
      table.insert(dirs, "/usr/lib")
   end
   return util.try_dirs(dirs, file, mode)
end

return unix_config
