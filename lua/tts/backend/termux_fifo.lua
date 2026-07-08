-- Responsabilidad: Escribir caracteres/palabras en la cola central de audio (FIFO).
-- Compatible con múltiples instancias simultáneas de Neovim.

local M = {}
local fifo_path = vim.fn.expand("~/.tts_queue")

function M.is_available()
  -- Verifica que la tubería FIFO exista en el sistema
  return vim.fn.filereadable(fifo_path) == 1
end

function M.speak(text)
  if not M.is_available() then
    return
  end

  -- Abrimos la tubería en modo "append" (añadir)
  local file = io.open(fifo_path, "a")
  if file then
    -- Escribimos el texto y forzamos el volcado inmediato
    file:write(text .. "\n")
    file:flush()
    file:close()
  end
end

function M.shutdown()
  -- No requiere limpieza ya que el ciclo de vida del proceso lo maneja Termux
end

return M

