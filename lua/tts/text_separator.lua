local M = {}

-- =============================================================================
-- UTILERÍAS DE CLASIFICACIÓN CON SOPORTE MULTIBYTE (UTF-8)
-- =============================================================================

local function es_alfanumerico(c)
    -- Incluye letras estándar, números, guiones y un rango amplio de caracteres 
    -- multibyte latinos (letras con acento en español, diéresis y la eñe)
    return c:match("[%w_-%a]") ~= nil or c:match("[áéíóúÁÉÍÓÚñÑüÜ]") ~= nil
end

local function es_espacio(c)
    return c:match("%s") ~= nil
end

-- =============================================================================
-- API PÚBLICA: ESCÁNER LINEAL CON ARRAY DE CARACTERES UTF-8
-- =============================================================================

function M.separate(large_text)
    if not large_text or large_text == "" then
        return {}
    end

    -- FASE 1: DESCOMPOSICIÓN SEGURA EN CARACTERES UTF-8 (Evita pérdida de palabras)
    -- Traduce el string de bytes a una lista lineal de glifos reales independientes.
    local caracteres = {}
    -- El patrón "[%z\1-\127\194-\244][\128-\191]*" captura glifos UTF-8 válidos en Lua
    for c in large_text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(caracteres, c)
    end

    local tokens = {}
    local total_caracteres = #caracteres
    local i = 1

    -- FASE 2: ESCÁNER LINEAL CONTINUO
    while i <= total_caracteres do
        local c = caracteres[i]

        if es_espacio(c) then
            i = i + 1

        elseif c == '"' or c == "'" then
            -- REGLA DE INSEPARABILIDAD DE TEXTO ENTRE COMILLAS
            local delimitador = c
            local inicio = i
            i = i + 1
            
            while i <= total_caracteres and caracteres[i] ~= delimitador do
                if caracteres[i] == "\\" then
                    i = i + 2 -- Saltar carácter escapado
                else
                    i = i + 1
                end
            end
            
            -- Reconstruir el string de la comilla unificada
            local t = {}
            for k = inicio, math.min(i, total_caracteres) do
                table.insert(t, caracteres[k])
            end
            table.insert(tokens, table.concat(t))
            i = i + 1

        elseif es_alfanumerico(c) then
            -- REGLA DE INTEGRIDAD DE PALABRAS Y NÚMEROS
            local inicio = i
            while i <= total_caracteres and es_alfanumerico(caracteres[i]) do
                i = i + 1
            end
            
            -- Reconstruir la palabra alfanumérica
            local t = {}
            for k = inicio, i - 1 do
                table.insert(t, caracteres[k])
            end
            local palabra_completa = table.concat(t)
            
            -- REGLA DE ADHERENCIA POSTERIOR (Paréntesis pegados como 'main()')
            if i <= total_caracteres and caracteres[i] == "(" and caracteres[i+1] == ")" then
                palabra_completa = palabra_completa .. "()"
                i = i + 2
            end
            
            table.insert(tokens, palabra_completa)

        else
            -- REGLA DE SEPARACIÓN INDIVIDUAL DE SÍMBOLOS Y RÁFAGAS
            if i < total_caracteres then
                local dos_caracteres = c .. caracteres[i+1]
                if dos_caracteres == "==" or dos_caracteres == "!=" or 
                   dos_caracteres == "<=" or dos_caracteres == ">=" then
                    table.insert(tokens, dos_caracteres)
                    i = i + 2
                else
                    table.insert(tokens, c)
                    i = i + 1
                end
            else
                table.insert(tokens, c)
                i = i + 1
            end
        end
    end

    return tokens
end

return M

