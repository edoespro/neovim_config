local M = {}

local text_separator = require("tts.text_separator")
local phonetic_translator = require("tts.phonetic_translator")
local syllable_divider = require("tts.syllable_divider")
local time_estimator = require("tts.time_estimator")
local tts = require("tts.backend.termux")
local speed = require("tts.speed")

-- =============================================================================
-- VARIABLES DE ÁMBITO GLOBAL DEL MÓDULO (Persisten entre llamadas a on_speak)
-- =============================================================================
local manejador_temporizador = nil   -- Guardará el ÚNICO objeto temporizador activo
local cola_fonetica_actual = {}      -- Lista de palabras pendientes de leer
local cola_tokens_actual = {}
local indice_lectura = 1             -- Posición actual dentro de la cola
local tts_stop = false
-- Calibración empírica establecida por tus pruebas
time_estimator.set_spm(500)
time_estimator.set_rate(1.0)

-- =============================================================================
-- FUNCIÓN INTERNA: DESPACHADOR DE GOTEO (El motor recurrente)
-- =============================================================================
local function despachar_siguiente_palabra()
    -- Si ya no hay más palabras en la cola, apagamos el temporizador pacíficamente
    if indice_lectura > #cola_fonetica_actual then
        if manejador_temporizador then
            manejador_temporizador:stop()
            manejador_temporizador:close()
            manejador_temporizador = nil
        end
        return
    end

    -- 1. Tomamos la palabra fonética que toca leer
    --local phonetic_text = cola_fonetica_actual[indice_lectura]
    local fragment_text = cola_fragmentos_actual[indice_lectura]
    -- 2. La enviamos inmediatamente al FIFO para que Android la verbalice
if not tts_stop then
    tts.speak(fragment_text)
else
    tts.speak("stop")
end

    -- 3. Calculamos cuántos milisegundos va a tardar el TTS en pronunciarla
    local phonetic_text = cola_fonetica_actual[indice_lectura]
    local silabas = syllable_divider.divide(phonetic_text)
    local tiempo_estimado = time_estimator.estimate(silabas) + 500

    -- 4. Avanzamos el índice para la próxima iteración
    indice_lectura = indice_lectura + 1

    -- 5. RECURSIVIDAD CONTROLADA POR TIEMPO:
    -- Reprogramamos el MISMO temporizador para que despierte justo cuando termine la palabra actual
    if manejador_temporizador then
        manejador_temporizador:stop() -- Detiene el ciclo actual
        manejador_temporizador:start(tiempo_estimado, 0, vim.schedule_wrap(despachar_siguiente_palabra))
    end
end

-- =============================================================================
-- FUNCIÓN PRINCIPAL: ON_SPEAK (Invocada al mover el cursor)
-- =============================================================================
function M.on_speak(large_text)
    -- -------------------------------------------------------------------------
    -- PASO 1: DETENCIÓN ABSOLUTA DEL PASADO (Destrucción del proceso anterior)
    -- -------------------------------------------------------------------------
    if manejador_temporizador then
        manejador_temporizador:stop()  -- Detiene el reloj de Neovim de forma fulminante
        manejador_temporizador:close() -- Libera la memoria del objeto temporizador
        manejador_temporizador = nil   -- Limpia la referencia
    end

    -- Limpiamos la cola anterior para que no quede residuo flotando en memoria
    cola_fragmentos_actual = {}
    cola_fonetica_actual = {}
    indice_lectura = 1

    if not large_text or large_text == "" then
        return
    end

    -- -------------------------------------------------------------------------
    -- PASO 2: PREPARACIÓN DE LA NUEVA LÍNEA
    -- -------------------------------------------------------------------------
    cola_fragmentos_actual = text_separator.separate(large_text)
    cola_fonetica_actual = phonetic_translator.translate(cola_fragmentos_actual)

    if #cola_fonetica_actual == 0 then
        return
    end

    -- -------------------------------------------------------------------------
    -- PASO 3: INICIALIZACIÓN DEL TEMPORIZADOR ÚNICO
    -- -------------------------------------------------------------------------
    -- Creamos un temporizador limpio en el bucle de eventos de Neovim (Libuv)
    manejador_temporizador = vim.loop.new_timer()

    -- Disparamos la primera palabra inmediatamente (0 ms de retraso inicial)
    -- vim.schedule_wrap asegura que la ejecución corra de forma segura en el hilo de Neovim
    manejador_temporizador:start(0, 0, vim.schedule_wrap(despachar_siguiente_palabra))
end



vim.keymap.set('n', '<Leader>s', function()

if not tts_stop then
tts_stop = true
else
tts_stop = false
end
end, {
    desc = "TTS: Leer mensajes actuales silenciosamente",
    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
})

return M

