local M = {}

-- =============================================================================
-- EXCEPCIONES ANGLOSAJONAS CRÍTICAS (Alineación de Tiempos TTS)
-- =============================================================================
-- Palabras en inglés comunes en código cuyo conteo gráfico difiere totalmente
-- del esfuerzo silábico real que ejecuta el motor de Google TTS.
local EXCEPCIONES_INGLES = {
    ["queue"] = "ki u",       -- Google TTS pronuncia "kiu" (2 impulsos fonéticos)
    ["false"] = "fols",       -- Evita que cuente la 'e' muda final
    ["true"] = "tru",         -- Evita que cuente la 'e' muda final
    ["file"] = "fa il",       -- Traduce a sus impulsos fonéticos reales en español
    ["while"] = "gua il",
    ["code"] = "co ud"
}

-- =============================================================================
-- API PÚBLICA: MOTOR DE IMPULSOS CON TRATAMIENTO DE HIATOS Y EXCEPCIONES
-- =============================================================================

function M.divide(phonetic_text)
    if not phonetic_text or phonetic_text == "" then
        return {}
    end

    local syllable_list = {}

    -- Procesamos palabra por palabra separada por espacios
    for palabra in phonetic_text:gmatch("%S+") do
        local p_lower = palabra:lower()

        -- 1. CAPA DE CORRECCIÓN: Tratamiento de palabras en inglés rebeldes
        if EXCEPCIONES_INGLES[p_lower] then
            palabra = EXCEPCIONES_INGLES[p_lower]
        else
            -- 2. CAPA DE CORRECCIÓN: Ruptura de Hiatos de Vocales Fuertes en Español
            -- Inyectamos un espacio intermedio artificial para romper la codicia del patrón
            local fuertes = {
                "a e", "a o", "e a", "e o", "o a", "o e",
                "á e", "á o", "é a", "é o", "ó a", "ó e",
                "a é", "a ó", "e á", "e ó", "o á", "o é"
            }
            for _, par in ipairs(fuertes) do
                local buscar = par:gsub("%s", "")
                palabra = palabra:gsub(buscar, par)
                -- También para variantes con mayúsculas mezcladas
                local buscar_cap = buscar:sub(1,1):upper() .. buscar:sub(2,2)
                palabra = palabra:gsub(buscar_cap, par:sub(1,1):upper() .. " " .. par:sub(3,3))
            end

            -- Ruptura de Hiatos por Acento (Vocal débil tónica pegada a fuerte)
            local hiatos_acento = {
                "í a", "í e", "í o", "ú a", "ú e", "ú o",
                "a í", "e í", "o í", "a ú", "e ú", "o ú"
            }
            for _, par in ipairs(hiatos_acento) do
                local buscar = par:gsub("%s", "")
                palabra = palabra:gsub(buscar, par)
            end
        end

        -- 3. SUB-BUCLE: Procesar los fragmentos resultantes tras la inyección de espacios
        for sub_palabra in palabra:gmatch("%S+") do
            if #sub_palabra <= 3 then
                table.insert(syllable_list, sub_palabra)
            else
                -- Expresión regular nativa que captura el impulso consonante-vocal-consonante
                local patron_silaba = "[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]*[aeiouáéíóúüAEIOUÁÉÍÓÚÜ]+[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]*"
                
                local encontro_silabas = false
                for silaba in sub_palabra:gmatch(patron_silaba) do
                    table.insert(syllable_list, silaba)
                    encontro_silabas = true
                end
                
                if not encontro_silabas then
                    table.insert(syllable_list, sub_palabra)
                end
            end
        end
    end

    return syllable_list
end

return M

