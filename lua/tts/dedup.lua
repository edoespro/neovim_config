-- lua/a11y/tts/dedup.lua
-- Responsabilidad: evitar verbalizar el mismo mensaje consecutivamente
-- dentro de una ventana de tiempo configurable

local M = {}

local state = {
  last_text    = nil,
  last_time    = 0,
}

-- Ventana de tiempo en ms para considerar un mensaje como repetido
M.window_ms = 1000

-- Devuelve true si el texto debe verbalizarse
-- Devuelve false si es repetición dentro de la ventana de tiempo
function M.should_speak(text)
  local now = vim.loop.now()

  if text ~= state.last_text then
    state.last_text = text
    state.last_time = now
    return true
  end

  if now - state.last_time > M.window_ms then
    state.last_time = now
    return true
  end

  return false
end

-- Resetea el estado interno
function M.reset()
  state.last_text = nil
  state.last_time = 0
end

return M
