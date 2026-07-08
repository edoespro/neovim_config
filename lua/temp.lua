tts = require("reader.tts")
local M = {}

function M.start_temp ()
-- 1. Pre-instrucción
tts.speak("Iniciando proceso...")

-- 2. Bucle en segundo plano con temporizador (libuv)
-- Creamos un temporizador que no bloquea la interfaz
local timer = vim.loop.new_timer()


-- El temporizador ejecuta la función cada cierto tiempo (ej. cada 1000 milisegundos)
timer:start(0, 300, vim.schedule_wrap(function()
    -- Tus instrucciones van aquí.
    -- Esto reemplaza al 'while true' sin congelar Neovim.
    --tts.speak("Ejecutando instrucciones en segundo plano...")
end))

-- 3. Post-instrucción
tts.speak("Post-instrucción ejecutada.")

-- Nota: Para detener el bucle cuando ya no lo necesites, usa: timer:stop()
end

return M
