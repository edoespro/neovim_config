local M = {}

local tts = require("tts")
local keyboard = require("keyboard")

keyboard.add_handlers({"i", "n"}, function(key_info) 

	if key_info.source == "<PageUp>" then
		tts.speak("Página arriba")
	elseif key_info.source == "<PageDown>" then
		tts.speak("Página abajo")
	elseif key_info.source == "<C-Home>" then
	tts.speak("Inicio de archivo")
	elseif key_info.source == "<C-End>" then
	tts.speak("Fin de archivo")
end

end)


return M
