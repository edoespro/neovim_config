local M = {}

local tts = require("tts")
local keyboard = require("keyboard")

_speak_line = false

keyboard.add_handler("ESPECIAL", function(key_info) 

	if key_info.source == "<Down>" or key_info.source == "<Up>" then
		_speak_line = true
	end
end)

local my_cursor_group = vim.api.nvim_create_augroup("CustomCursorTracker", { clear = true })

-- 1. DETECTAR EN MODO COMANDO (:)
vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = my_cursor_group,
    pattern = "*",
    callback = function()
        if _speak_line then
	    local cursor_pos = vim.fn.getcmdpos()
        local current_cmd = vim.fn.getcmdline()
        -- Tu lógica aquí
        tts.speak(current_cmd .. " " .. cursor_pos)
	_speak_line = false
end
end,
})

--vim.keymap.set('c', '<Up>', function()
--  tts.speak( vim.fn.getcmdline())
  --return '<Up>'
--end, { expr = true })



return M
