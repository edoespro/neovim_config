local M = {}

-- =============================================================================
-- DICCIONARIOS FONÉTICOS DE CONTROL EXTRA-PRECISO
-- =============================================================================

local SIMBOLOS = {
    ["_"] = "barra baja",    ["+"] = "mas",          ["-"] = "guion",
    ["*"] = "asterisco",    ["/"] = "diagonal",     ["="] = "igual a",
    ["~"] = "tilde",        ["@"] = "arroba",       ["#"] = "numeral",
    ["$"] = "dolar",        ["%"] = "por ciento",   ["^"] = "acento circunflejo",
    ["&"] = "y",            ["!"] = "exclamacion",  ["?"] = "interrogacion",
    ["|"] = "pleca",        [":"] = "dos puntos",   [";"] = "punto y coma",
    ["{"] = "llave abre",   ["}"] = "llave cierra", ["["] = "corchete abre",
    ["]"] = "corchete cierra", ["\\"] = "diagonal inversa", ["."] = "punto",
    ["("] = "parentesis abre", [")"] = "parentesis cierra", [","] = "coma",
    ["<"] = "menor que",    [">"] = "mayor que",
    ["=="] = "igual igual", ["!="] = "diferente de",
    ["<="] = "menor o igual", [">="] = "mayor o igual"
}

local CONSONANTES = {
    ["b"]="be", ["c"]="ce", ["d"]="de", ["f"]="efe", ["g"]="ge", ["h"]="hache",
    ["j"]="jota", ["k"]="ka", ["l"]="ele", ["m"]="eme", ["n"]="ene", ["p"]="pe",
    ["q"]="cu", ["r"]="erre", ["s"]="ese", ["t"]="te", ["v"]="ve", ["w"]="doble u",
    ["x"]="equis", ["y"]="y", ["z"]="zeta"
}

local DIGITOS_INDIVIDUALES = {
    ["0"]="cero", ["1"]="uno", ["2"]="dos", ["3"]="tres", ["4"]="cuatro",
    ["5"]="cinco", ["6"]="seis", ["7"]="siete", ["8"]="ocho", ["9"]="nueve"
}

-- Diccionario de abreviaturas de programación que Google TTS lee completas
local ABREVIATURAS = {
    ["fn"] = "funcion", ["buf"] = "buffer", ["win"] = "ventana",
    ["err"] = "error", ["msg"] = "mensaje", ["init"] = "inicio",
    ["config"] = "configuracion", ["nvim"] = "neovim", ["lua"] = "lua",
    ["tts"] = "te te ese" -- Forzado explícito basándonos en tus siglas de control
}

-- =============================================================================
-- TRADUCTOR MATEMÁTICO DE NÚMEROS A TEXTO (Hasta 5 dígitos: 0 - 99999)
-- =============================================================================

local unidades = {"uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve"}
local especiales = {
    ["10"]="diez", ["11"]="once", ["12"]="doce", ["13"]="trece", ["14"]="catorce", ["15"]="quince",
    ["16"]="dieciseis", ["17"]="diecisiete", ["18"]="dieciocho", ["19"]="diecinueve",
    ["20"]="veinte", ["21"]="veintiuno", ["22"]="veintidos", ["23"]="veintitres", ["24"]="veinticuatro",
    ["25"]="veinticinco", ["26"]="veintiseis", ["27"]="veintilisiete", ["28"]="veintiocho", ["29"]="veintinueve"
}
local decenas = {"diez", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa"}
local centenas = {"ciento", "doscientos", "trescientos", "cuatrocientos", "quinientos", "seiscientos", "setecientos", "ochocientos", "novecientos"}

local function numero_a_letras(num)
    if num == 0 then return "cero" end
    if especiales[tostring(num)] then return especiales[tostring(num)] end

    local resultado = ""
    
    -- Miles (Hasta 99)
    if num >= 1000 then
        local miles = math.floor(num / 1000)
        num = num % 1000
        if miles == 1 then
            resultado = "mil "
        else
            resultado = numero_a_letras(miles) .. " mil "
        end
    end

    -- Centenas
    if num >= 100 then
        local c = math.floor(num / 100)
        num = num % 100
        if c == 1 and num == 0 then
            resultado = resultado .. "cien"
            return resultado
        else
            resultado = resultado .. centenas[c] .. " "
        end
    end

    -- Decenas y Unidades residuales
    if num > 0 then
        if especiales[tostring(num)] then
            resultado = resultado .. especiales[tostring(num)]
        else
            local d = math.floor(num / 10)
            local u = num % 10
            if d > 0 then
                resultado = resultado .. decenas[d]
                if u > 0 then
                    resultado = resultado .. " y " .. unidades[u]
                end
            elseif u > 0 then
                resultado = resultado .. unidades[u]
            end
        end
    end

    return resultado:gsub("%s+$", "")
end

-- =============================================================================
-- FUNCIONES PRIVADAS DE ANÁLISIS MORFOLÓGICO Y TEXTUAL
-- =============================================================================

--- Determina si una cadena es una secuencia pura de consonantes sin vocales
local function es_sigla_o_consonantes(word)
    -- Si contiene alguna vocal (mayúscula o minúscula o acentuada), no es una sigla pura
    if word:match("[aeiouAEIOUáéíóúÁÉÍÓÚ]") then
        return false
    end
    -- Debe ser puramente alfabética
    return word:match("^%a+$") ~= nil
end

--- Traduce secuencias de letras sin vocales a su deletreo hablado
--- Traduce secuencias de letras sin vocales a su deletreo hablado
local function expandir_consonantes(word)
    local t = {}
    for c in word:gmatch(".") do
        -- CORRECCIÓN: Se usa :lower() que es el método nativo y válido en Lua
        local lc = c:lower()
        table.insert(t, CONSONANTES[lc] or c)
    end
    return table.concat(t, " ")
end








--- Procesa un token alfanumérico mixto para expandir sus elementos fonéticos
local function expandir_palabra_tecnica(token)
    -- Si es una abreviatura exacta en minúsculas, se retorna su expansión completa
    local t_lower = token:lower()
    if ABREVIATURAS[t_lower] then
        return ABREVIATURAS[t_lower]
    end

    -- Si es una sigla o ráfaga de consonantes puras (ej: tnt, mx, bcdfgh)
    if es_sigla_o_consonantes(token) then
        return expandir_consonantes(token)
    end

    -- Escaneo de glifos UTF-8 para resolver guiones bajos internos y dígitos acoplados
    local t = {}
    for c in token:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if c == "_" then
            table.insert(t, " " .. SIMBOLOS["_"] .. " ")
        elseif c:match("%d") then
            table.insert(t, " " .. DIGITOS_INDIVIDUALES[c] .. " ")
        else
            table.insert(t, c)
        end
    end
    
    return table.concat(t):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

--- Analiza un único token y genera su equivalencia fonética exacta
local function normalize_token_phonetics(token)
    -- Caso 1: Símbolo aislado o conector relacional explícito (==, !=, etc.)
    if SIMBOLOS[token] then
        return SIMBOLOS[token]
    end

    -- Caso 2: Strings entre comillas
    if token:sub(1,1) == '"' or token:sub(1,1) == "'" then
        local texto_limpio = token:sub(2, #token - 1)
        return texto_limpio ~= "" and texto_limpio or "comillas vacias"
    end

    -- Caso 3: Adherencia de paréntesis al final (ej: main()) -> Se suprimen prosódicamente
    if token:match("%(%)+$") then
        local palabra_limpia = token:gsub("%(%)", "")
        return expandir_palabra_tecnica(palabra_limpia)
    end

    -- Caso 4: Regla de Cardinalidad Numérica Estricta
    if token:match("^%d+$") then
        if #token >= 6 then
            -- Mayor a 5 dígitos -> Deletreo secuencial individual
            local digitos = {}
            for k = 1, #token do
                local d = token:sub(k, k)
                table.insert(digitos, DIGITOS_INDIVIDUALES[d] or d)
            end
            return table.concat(digitos, " ")
        else
            -- Hasta 5 dígitos -> Traducir fonéticamente a cantidad cardinal real en español
            return numero_a_letras(tonumber(token))
        end
    end

    -- Caso 5: Palabra estándar o compuesta técnica
    return expandir_palabra_tecnica(token)
end

-- =============================================================================
-- API PÚBLICA (El Contrato del Módulo)
-- =============================================================================

function M.translate(segmented_list)
    if not segmented_list or #segmented_list == 0 then
        return {}
    end

    local phonetic_list = {}

    for index, token in ipairs(segmented_list) do
        local equivalencia_fonetica = normalize_token_phonetics(token)
        phonetic_list[index] = equivalencia_fonetica
    end

    return phonetic_list
end

return M



