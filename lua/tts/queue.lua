-- lua/a11y/tts/queue.lua
-- Responsabilidad: gestionar el orden y tipo de inserción de mensajes
-- Tipos de inserción:
--   "queue"     → espera su turno respetando prioridad
--   "interrupt" → cancela el mensaje actual y habla inmediatamente
--   "flush"     → vacía la cola completa antes de encolar

local engine = require("tts.backend.termux")
local speed = require("tts.speed")
local M = {}

-- Estado interno
local state = {
  queue       = {},   -- lista de items pendientes
  is_speaking = false,
  current_job = nil,
}

-- ─────────────────────────────────────────
-- API pública
-- ─────────────────────────────────────────

function M.add(item)
  -- item = { text, priority, insert_type }
  item.priority    = item.priority    or 3
  item.insert_type = item.insert_type or "queue"

  if item.insert_type == "interrupt" then
    M._interrupt(item)

  elseif item.insert_type == "flush" then
    M._flush(item)

  else
    M._enqueue(item)
  end
end

function M.clear()
  M._cancel_current()
  state.queue       = {}
  state.is_speaking = false
end

function M.is_speaking()
  return state.is_speaking
end

-- ─────────────────────────────────────────
-- Tipos de inserción
-- ─────────────────────────────────────────

function M._interrupt(item)
  M._cancel_current()
  table.insert(state.queue, 1, item)
  --M._process_next()
end

function M._flush(item)
  M._cancel_current()
  state.queue = {}
  table.insert(state.queue, item)
  --M._process_next()
end

function M._enqueue(item)
  -- Insertar respetando prioridad (menor número = mayor prioridad)
  local inserted = false
  for i, queued in ipairs(state.queue) do
    if item.priority < queued.priority then
      table.insert(state.queue, i, item)
      inserted = true
      break
    end
  end

  if not inserted then
    table.insert(state.queue, item)
  end

  ---if not state.is_speaking then
    --M._process_next()
  --end
end

-- ─────────────────────────────────────────
-- Procesamiento interno
-- ─────────────────────────────────────────

function M._process_next()
  local timer = vim.loop.new_timer()
-- El temporizador ejecuta la función cada cierto tiempo (ej. cada 1000 milisegundos)
timer:start(0,1, vim.schedule_wrap(function()
    -- Tus instrucciones van aquí.
    if #state.queue == 0 then
    state.is_speaking = false
    state.current_job = nil
   -- return
  --end
  else

  --state.is_speaking = true
  local item        = table.remove(state.queue, 1)
  speed.on_move(item)
  --state.current_job = engine.speak(item.text, function()
    --state.is_speaking = false
    --state.current_job = nil
    --M._process_next()
  --end)
  end
  end))
end

function M._cancel_current()
    --engine.stop()
    --print("aaaaaaaaa")
    --if state.current_job then
    --print("bbbbbbbbb")
    engine.cancel(state.current_job)
    state.current_job = nil
    state.is_speaking = false
  --end
end

function M.on_stop(verbosity)
  state.is_speaking = true
  --local item        = table.remove(state.queue, 1)
   state.current_job = engine.speak(verbosity.item.text, function()
    state.is_speaking = false
    state.current_job = nil
    --M._process_next()
  end)
	end
speed.on_stop(M.on_stop)

return M
