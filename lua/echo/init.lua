local M = {}

tts = require("tts")
keyboard = require("keyboard")
 
keyboard.add_handler("SIMPLE", function(key_info)

tts.speak(key_info.key)

end)


return M
