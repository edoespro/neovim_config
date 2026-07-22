-- lua/a11y/tts/queue.lua
-- Responsabilidad: gestionar el orden y tipo de inserción de mensajes
-- Tipos de inserción:
--   "queue"     →  espera turno respetando prioridad
--   "interrupt" → cancela el mensaje actual y habla inmediatamente
--   "flush"     → vacía la cola completa antes de encolar

local engine = require("tts.backend.termux")
local speed = require("tts.speed")
local text_separator = require("tts.text_separator")
local phonetic_translator = require("tts.phonetic_translator")
local syllable_divider = require("tts.syllable_divider")
local time_estimator = require("tts.time_estimator")
local timer_reader = require("tts.timer_reader")
local M = {}

local last_statusmsg = "" 
local last errmsg = ""
local last_event = ""
local tts_stop = false
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
  speed.on_move(item)
end

function M._flush(item)
  M._cancel_current()
  state.queue = {}
  table.insert(state.queue, item)
  --M._process_next()
speed.on_move(item)
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

    speed.on_move(item)
  --if not state.is_speaking then
    --M._process_next()
  --end
end

-- ─────────────────────────────────────────
-- Procesamiento interno
-- ─────────────────────────────────────────

function M._process_next()
 if #state.queue == 0 then
    state.is_speaking = false
    state.current_job = nil
   return
  end

    local item = table.remove(state.queue, 1)
    speed.on_move(item)
  M.check_errmsg()
end

function M.on_stop(verbosity)
timer_reader.on_speak(verbosity.item.text)
--state.current_job = engine.speak(verbosity.item.text, function()
--  end)
M.check_errmsg()
end

function M._process_text()
  local timer = vim.loop.new_timer()
-- El temporizador ejecuta la función cada cierto tiempo (ej. cada 1000 milisegundos)
timer:start(0,1, vim.schedule_wrap(function()
    -- Tus instrucciones van aquí.
  end))
end

function M.on_stop3(verbosity)
  state.is_speaking = true
  --local item        = table.remove(state.queue, 1)
local lista_fragmentos = text_separator.separate(verbosity.item.text)
local lista_fonetica = phonetic_translator.translate(lista_fragmentos)
local retraso_acumulado = 0
    time_estimator.set_spm(500)
for i, fragmento in ipairs(lista_fragmentos) do

    -- Mandamos cada trozo directamente a tu sistema actual para validar la fonética
    --print(fragmento)
    
    local lista_silabas = syllable_divider.divide(lista_fonetica[i])
    local tiempo_estimado = time_estimator.estimate(lista_silabas)
    --local info = "fonetico: " .. fragmento .. "   / silabas: " .. vim.inspect(lista_silabas) .. "   / count: " .. #lista_silabas .. " /time: " .. tiempo_estimado
    vim.defer_fn(function()
    if not tts_stop then
	    state.current_job = engine.speak(fragmento, function()
    --state.current_job = engine.speak(verbosity.item.text, function()
    --state.is_speaking = false
    --state.current_job = nil
    --M._process_next()
  end)
    --retraso_acumulado = retraso_acumulado + tiempo_estimado + 5000
    else
	state.current_job = engine.speak("stop", function()
  end)
end
    end, retraso_acumulado)
  -- Acumulamos el tiempo para que el siguiente fragmento espere a que este termine
    retraso_acumulado = retraso_acumulado + tiempo_estimado  + 500

end
	end

speed.on_stop(M.on_stop)


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

function M.attach()

local ns = vim.api.nvim_create_namespace('tts_messages')

vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
    if event == "msg_show" then
        local args = {...}
         --Aquí puedes procesar el contenido del mensaje recibido en tiempo real
--print("evento: " .. event)
	 --speed.on_move({text = "Se recibio mensaje" .. event, priority = 3, insert_type = "queue" })
	 last_event = event
        --vim.notify("asdf", vim.log.levels.INFO, {title = "Capturado"})
	--print("asdf")
end
end)
end
--M.attach()

function M.check_errmsg()

--local statusmsg = vim.v.statusmsg
--if statusmsg and statusmsg ~= "" then
--speed.on_move({text = "mensaje de estado: " .. statusmsg, priority = 3, insert_type = "queue"})
--last_statusmsg = statusmsg
--vim.v.statusmsg = ""
--return true
--end
local errmsg = vim.v.errmsg
if errmsg and errmsg ~= "" then
local head_errmsg = M.get_head_errmsg(errmsg)
speed.on_move({text = " Mensaje de error: " .. head_errmsg, priority = 3, insert_type = "queue"})
last_errmsg = errmsg
vim.v.errmsg = ""
return true
end
--local messages = vim.v.messages
--if messages then
--speed.on_move({text = "Si hay mensajes en v.messages", priority = 3, insert_type = "queue"})
--return true
--end
--speed.on_move({text = "asdf", priority = 3, insert_type = "queue"})
--print("status: " .. statusmsg .. " error: " .. errmsg)
return false
end


--M.check_messages()

function M.attach3()
-- 1. Crear un namespace
local ns = vim.api.nvim_create_namespace('MiPluginUI')

-- 2. Adjuntar la interfaz de usuario
local ui_id = vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
    local args = {...}
   speed.on_move({text = event, priority = 3, insert_type = "queue"}) 
    -- 3. Manejar los eventos
    if event == 'msg_show' then
        local kind, content, replace = args[1], args[2], args[3]

        -- 'content' es una tabla de tablas. Necesitamos iterar para obtener el texto.
        local message_text = ""
        for _, chunk in ipairs(content) do
            -- chunk[2] contiene el texto real
            message_text = message_text .. chunk[2]
        end

        -- SOLUCIÓN: Volver a mostrar el mensaje usando vim.notify
        -- Esto permite que Neovim maneje la visualización (o plugins como nvim-notify)
        if message_text ~= "" then
            vim.schedule(function()
                vim.notify(message_text, vim.log.levels.INFO, {title = "Capturado"})
            end)
        end
    end
end)

-- NOTA: Para liberar la UI cuando termines:
-- vim.ui_detach(ui_id)

end

--M.attach()
function M.get_head_errmsg(errmsg)
-- Texto de entrada (tu variable errmsg)
local errtext = errmsg

-- 1. Buscamos la posición donde inicia "stack traceback" (sin importar mayúsculas/minúsculas)
local inicio_traceback = string.find(errtext:lower(), "stack traceback")

-- Variables para guardar las dos partes
local cabecera_error = errtext
local traza_error = ""

-- 2. Si se encuentra la palabra clave, cortamos el string en dos secciones
if inicio_traceback then
    -- Extrae desde el inicio hasta justo antes de "stack traceback"
    cabecera_error = string.sub(errtext, 1, inicio_traceback - 1)
    
    -- Extrae desde "stack traceback" hasta el final del texto
    traza_error = string.sub(errtext, inicio_traceback)
    
    -- (Opcional) Limpiamos espacios o saltos de línea sobrantes al final e inicio de cada parte
    cabecera_error = vim.trim(cabecera_error)
    traza_error = vim.trim(traza_error)
end
return cabecera_error

end

--vim.keymap.set('n', '<Leader>s', function()

--if not tts_stop then
--tts_stop = true
--else
--tts_stop = false
--end

--end, {
--    desc = "TTS: Leer mensajes actuales silenciosamente",
--    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
--})












return M



