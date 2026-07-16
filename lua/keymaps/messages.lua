local M = {}

local tts = require("tts")

-- MAPEO DE TECLAS MANUAL (Silencioso)
-- Presiona <Leader>m en modo Normal para leer los mensajes actuales
--vim.keymap.set('n', '<Leader>s', function()
--    tts.speak(vim.v.statusmsg)
    --M.check_statusmsg()
--end, { 
--    desc = "TTS: Leer mensajes actuales silenciosamente",
--    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
--})

--vim.keymap.set('n', '<Leader>e', function()
--    tts.speak(vim.v.errmsg)
    --M.check_statusmsg()
--end, { 
--    desc = "TTS: Leer mensajes actuales silenciosamente",
--    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
--})

vim.keymap.set('n', '<Leader>m', function()

local last_message = vim.fn.execute('1messages')
if last_message == "" then
	last_message = "No hay mensajes"
end
--local messages = vim.api.nvim_exec2('messages', {output = true})
tts.speak(last_message)
end, { 
    desc = "TTS: Leer mensajes actuales silenciosamente",
    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
})



function M.check_statusmsg()

local statusmsg = vim.v.statusmsg
if statusmsg and statusmsg ~= "" then
tts.speak("mensaje de estado: " .. statusmsg)
--last_statusmsg = statusmsg
--vim.v.statusmsg = ""
return true
end
return false
end

function M.check_errmsg()
local errmsg = vim.v.errmsg
if errmsg and errmsg ~= "" then
tts.speak("Mensaje de error: " .. errmsg)
--last_errmsg = errmsg
--vim.v.errmsg = ""
return true
end
return false
end

function M.check_messages()
	
local messages = vim.v.messages
if messages then
tts.speak("Si hay mensajes en v.messages")
return true
end
return false
end

return M
