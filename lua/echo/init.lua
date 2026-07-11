local M = {}

tts = require("tts")
keyboard = require("keyboard")
 
keyboard.add_handlers({"i", "c"}, function(key_info)
if key_info.type == "SIMPLE" then
tts.speak(key_info.key)
end
end)


return M


