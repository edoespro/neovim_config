-- lua/a11y/tts/debouncer.lua
-- Responsabilidad: controlar la frecuencia de ejecución de funciones
-- debounce → espera que dejen de llegar eventos antes de ejecutar
-- throttle → ejecuta inmediatamente y bloquea llamadas durante el delay

local M = {}

local timers = {}

-- Retrasa la ejecución de fn hasta que pasen delay_ms
-- sin nuevas llamadas del mismo id
function M.debounce(id, delay_ms, fn)
  if timers[id] then
    timers[id]:stop()
    timers[id]:close()
    timers[id] = nil
  end

  local timer = vim.loop.new_timer()
  timers[id]  = timer

  timer:start(delay_ms, 0, vim.schedule_wrap(function()
    timers[id] = nil
    fn()
  end))
end

-- Ejecuta fn inmediatamente y bloquea nuevas llamadas
-- del mismo id durante delay_ms
function M.throttle(id, delay_ms, fn)
  if timers[id] then return end

  fn()

  local timer = vim.loop.new_timer()
  timers[id]  = timer

  timer:start(delay_ms, 0, vim.schedule_wrap(function()
    timers[id] = nil
  end))
end

-- Cancela un timer activo por id
function M.cancel(id)
  if timers[id] then
    timers[id]:stop()
    timers[id]:close()
    timers[id] = nil
  end
end

return M
