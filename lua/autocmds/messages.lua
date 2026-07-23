
  local tts = require("tts")

-- Sobrescribir vim.notify para capturar casi todos los mensajes
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- Aquí hablas o logueas
  tts.speak("Notify: " .. msg)

  -- Llamas al original para que siga funcionando normalmente
  original_notify(msg, level, opts)
end


