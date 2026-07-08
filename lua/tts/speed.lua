-- lua/a11y/tts/speed.lua
-- Responsabilidad: detectar la velocidad de navegación del usuario
-- y ajustar dinámicamente el nivel de verbosidad
-- Verbosidad:
--   "minimal" → moviéndose rápido, leer lo menos posible
--   "normal"  → velocidad moderada, leer carácter o línea
--   "full"    → detenido, leer más contexto

local debouncer = require("tts.debouncer")

local M = {}

-- Configuración
M.config = {
  fast_threshold = 3,    -- movimientos en la ventana para considerar rápido
  window_ms      = 500,  -- ventana de tiempo para medir velocidad
  stop_delay_ms  = 300,  -- tiempo sin moverse para considerar detenido
}

-- Estado interno
local state = {
  move_count     = 0,
  last_move_time = 0,
  verbosity      = "normal",
}

-- Listeners para el evento "stopped"
local listeners = {}

-- Registra un handler para cuando el usuario se detiene
function M.on_stop(handler)
  table.insert(listeners, handler)
end

-- Despacha el evento stopped a todos los handlers
local function dispatch_stop(item)
  for _, handler in ipairs(listeners) do
    handler({ verbosity = "full", item = item })
  end
end

-- Llamar cada vez que ocurre un movimiento de navegación
function M.on_move(item)
  local now = vim.loop.now()

  -- Resetear contador si pasó la ventana de tiempo
  if now - state.last_move_time > M.config.window_ms then
    state.move_count = 0
  end

  state.move_count     = state.move_count + 1
  state.last_move_time = now

  -- Ajustar verbosidad según velocidad
  if state.move_count > M.config.fast_threshold then
    state.verbosity = "minimal"
  else
    state.verbosity = "normal"
  end

  -- Detectar pausa en la navegación
  debouncer.debounce("speed_stop", M.config.stop_delay_ms, function()
    state.move_count = 0
    state.verbosity  = "full"
    dispatch_stop(item)
  end)
end

-- Devuelve el nivel de verbosidad actual
function M.verbosity()
  return state.verbosity
end

-- Resetea el estado interno
function M.reset()
  state.move_count     = 0
  state.last_move_time = 0
  state.verbosity      = "normal"
  debouncer.cancel("speed_stop")
end

return M
