-- lua/a11y/tts/init.lua
-- Interfaz pública de la utilería TTS
-- Integra queue, dedup y speed para voz controlada y no saturada

local queue     = require("tts.queue")
local dedup     = require("tts.dedup")
local speed     = require("tts.speed")

local M = {}

-- ─────────────────────────────────────────
-- Listeners de eventos de monitoreo
-- ─────────────────────────────────────────

local listeners = {}

function M.on(event, handler)
  if not listeners[event] then
    listeners[event] = {}
  end
  table.insert(listeners[event], handler)
end

local function dispatch(event, data)
  if not listeners[event] then return end
  for _, handler in ipairs(listeners[event]) do
    handler(data)
  end
end

-- ─────────────────────────────────────────
-- Configuración pública
-- ─────────────────────────────────────────

queue._process_next()
-- Permite configurar dedup y speed desde fuera
function M.setup(opts)
  opts = opts or {}

  if opts.dedup_window_ms then
    dedup.window_ms = opts.dedup_window_ms
  end

  if opts.speed then
    if opts.speed.fast_threshold then
      speed.config.fast_threshold = opts.speed.fast_threshold
    end
    if opts.speed.window_ms then
      speed.config.window_ms = opts.speed.window_ms
    end
    if opts.speed.stop_delay_ms then
      speed.config.stop_delay_ms = opts.speed.stop_delay_ms
    end
  end
end

-- ─────────────────────────────────────────
-- Interfaz pública
-- ─────────────────────────────────────────

function M.speak(text, opts)
  opts = opts or {}

  -- Filtro de deduplicación
  --if not dedup.should_speak(text) then return end

  --print("speak speak speak")
  dispatch("start", { text = text })

  queue.add({
    text        = text,
    priority    = opts.priority    or 3,
    insert_type = opts.insert_type or "queue",
  })
end

function M.interrupt(text)
  --print("interrupt interrupt interrupt")
	--dedup.reset()
  dispatch("cancel", {})
  queue.add({
    text        = text,
    priority    = 1,
    insert_type = "interrupt",
  })
end

function M.flush(text)
  --print("flush flush flush")
	--dedup.reset()
  dispatch("cancel", {})
  queue.add({
    text        = text,
    priority    = 2,
    insert_type = "flush",
  })
end

function M.stop()
  queue.clear()
  dedup.reset()
  speed.reset()
  dispatch("cancel", {})
end

function M.is_speaking()
  return queue.is_speaking()
end

-- Expone speed para que los modos puedan
-- notificar movimientos y consultar verbosidad
function M.on_move()
  speed.on_move()
end

function M.verbosity()
  return speed.verbosity()
end

function M.on_stop(handler)
  speed.on_stop(handler)
end

return M
