local M = {}

-- =============================================================================
-- VALORES POR DEFECTO (Constantes Lingüísticas Base)
-- =============================================================================
-- Tasa de velocidad por defecto de termux-tts-speak (-r 1.0)
local DEFAULT_RATE = 1.0

-- Sílabas por minuto base en español/TTS a velocidad normal (275 SPM)
local DEFAULT_SPM = 275

-- Variables de estado internas del módulo
local current_rate = DEFAULT_RATE
local current_spm = DEFAULT_SPM

-- =============================================================================
-- API CONFIGURATIVA (Setters)
-- =============================================================================

--- Redefine la tasa de velocidad (speech rate) de termux-tts-speak de forma dinámica.
--- @param rate number Factor de velocidad (ej: 1.0, 1.5, 2.0)
function M.set_rate(rate)
    if type(rate) == "number" and rate > 0 then
        current_rate = rate
    end
end

--- Redefine las sílabas por minuto base estimadas para el motor TTS.
--- @param spm number Cantidad de sílabas por minuto (ej: 250, 275, 300)
function M.set_spm(spm)
    if type(spm) == "number" and spm > 0 then
        current_spm = spm
    end
end

-- =============================================================================
-- API PÚBLICA: CÓMPUTO MATEMÁTICO DE TIEMPO
-- =============================================================================

--- Recibe la lista secuencial de sílabas y calcula el tiempo de espera en milisegundos.
--- @param syllable_list table Tabla lineal indexada con las sílabas a medir.
--- @return number time_estimated Tiempo total de bloqueo calculado en milisegundos.
function M.estimate(syllable_list)
    if not syllable_list or #syllable_list == 0 then
        return 0
    end

    -- 1. Calcular el tiempo que consume emitir UNA SÍLABA a velocidad normal (-r 1.0)
    -- 60,000 milisegundos divididos entre las Sílabas Por Minuto (SPM)
    local tiempo_base_por_silaba = 60000 / current_spm

    -- 2. Ajustar el peso de la sílaba aplicando el factor de aceleración actual (rate)
    local tiempo_ajustado_por_silaba = tiempo_base_por_silaba / current_rate

    -- 3. Contar la cantidad de sílabas efectivas en la lista
    local total_silabas = #syllable_list

    -- 4. Computar el tiempo total de la verbalización
    -- Redondeamos matemáticamente al entero más cercano usando math.floor + 0.5
    local time_estimated = math.floor((total_silabas * tiempo_ajustado_por_silaba) + 0.5)

    return time_estimated
end

return M

