-- =============================================================================
-- CAPTURA DE PALABRA ACTUAL SEGÚN LA POSICIÓN DEL CURSOR EN TERMINAL
-- =============================================================================

local tts = require("tts")

local function capturar_y_verbalizar_palabra_terminal()
    -- Esperamos 15ms a que la shell de Termux mueva la columna del cursor físicamente
    vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()
        
        -- 1. Obtener la fila y columna actual del cursor en el terminal
        local cursor = vim.api.nvim_win_get_cursor(win)
        local fila_actual = cursor[1]
        local col_actual = cursor[2] + 1 -- Lua indexa desde 1

        -- 2. Obtener el string bruto de la línea del terminal
        local lineas = vim.api.nvim_buf_get_lines(buf, fila_actual - 1, fila_actual, false)
        local texto_linea = lineas[1] or ""

        if texto_linea == "" then return end

        -- 3. Identificar dónde termina el Prompt de la Shell (ej: "home $ ")
        -- Buscamos el final de la cadena del prompt para calibrar la columna real
        local inicio_comando = texto_linea:find("[$#>]")
        if inicio_comando then
            -- Avanzamos para saltar el símbolo '$' y el espacio que le sigue habitualmente
            inicio_comando = inicio_comando + 1
            while inicio_comando <= #texto_linea and texto_linea:sub(inicio_comando, inicio_comando):match("%s") do
                inicio_comando = inicio_comando + 1
            end
        else
            inicio_comando = 1
        end

        -- Si el cursor está parado antes de que empiece el comando (en el prompt), ignoramos
        if col_actual < inicio_comando then return end

        -- 4. ALGORITMO GEOMÉTRICO DE FRONTERAS DE PALABRA
        -- Buscamos los límites izquierdo y derecho de la palabra bajo el cursor
        local limite_izq = col_actual
        local limite_der = col_actual

        -- Expandir hacia la izquierda hasta encontrar un espacio o el inicio del comando
        while limite_izq > inicio_comando and not texto_linea:sub(limite_izq - 1, limite_izq - 1):match("%s") do
            limite_izq = limite_izq - 1
        end

        -- Expandir hacia la derecha hasta encontrar un espacio o el fin de la línea
        while limite_der <= #texto_linea and not texto_linea:sub(limite_der, limite_der):match("%s") do
            limite_der = limite_der + 1
        end

        -- Extracto de la palabra exacta en la que aterrizó el cursor
        local palabra_actual = texto_linea:sub(limite_izq, limite_der - 1)
        palabra_actual = palabra_actual:gsub("^%s+", ""):gsub("%s+$", "")

        -- 5. Envío al despachador de goteo único
        if palabra_actual ~= "" then
            tts.speak(palabra_actual)
        end
    end, 15)
end

-- =============================================================================
-- MAPEOS TRANSPARENTES PARA NAVEGACIÓN POR PALABRA EN MODO TERMINAL ('t')
-- =============================================================================

-- Control + Flecha Izquierda: Mover a la palabra anterior y leerla
vim.keymap.set('t', '<C-Left>', function()
    local secuencia = vim.api.nvim_replace_termcodes('<C-Left>', true, true, true)
    vim.api.nvim_feedkeys(secuencia, 'n', true)
    
    capturar_y_verbalizar_palabra_terminal()
end, { desc = "TTS: Leer palabra anterior en terminal" })

-- Control + Flecha Derecha: Mover a la palabra siguiente y leerla
vim.keymap.set('t', '<C-Right>', function()
    local secuencia = vim.api.nvim_replace_termcodes('<C-Right>', true, true, true)
    vim.api.nvim_feedkeys(secuencia, 'n', true)
    
    capturar_y_verbalizar_palabra_terminal()
end, { desc = "TTS: Leer palabra siguiente en terminal" })

