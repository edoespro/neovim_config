local M = {}

local tts = require("tts")
local keyboard = require("keyboard")
local cmds = require('modes.normal_cmds')

keyboard.add_handler("n", function(key_info) 
tts.speak(cmds[key_info.source])
end)


--vim.on_key(function(_, typed)
--  local nor = vim.fn.keytrans(typed) -- "<C-R>" , "," , "<LT>" , " "
--  local name = M[nor]
---  if name then
--    -- ya tienes cmd_nor -> cmd_name sin buscar
--    vim.api.nvim_echo({{nor.." -> "..name, "MoreMsg"}}, false, {})
--  end
--end, vim.api.nvim_create_namespace("map"))

return M
