-- =============================================================================
-- INTERCEPTOR DE PALABRAS EN MODO LÍNEA DE COMANDOS (':')
-- =============================================================================

local tts = require("tts")

local function capturar_y_verbalizar_palabra_comando()
    -- Esperamos 15ms a que Neovim actualice la posición interna del cursor 'getcmdpos'
    vim.defer_fn(function()
        -- 1. Extraer el texto completo actual escrito en la barra inferior (:)
        local texto_comando = vim.fn.getcmdline()
        
        -- 2. Obtener la posición actual del cursor (Indexada desde 1 en caracteres)
        local pos_actual = vim.fn.getcmdpos()

        if not texto_comando or texto_comando == "" then return end

        -- 3. ALGORITMO GEOMÉTRICO DE LÍMITES EN CARACTERES
        local total_caracteres = #texto_comando
        
        -- Calibración por si el cursor se sale de los bordes físicos del string
        local col_actual = math.min(pos_actual, total_caracteres)
        if col_actual < 1 then col_actual = 1 end

        local limite_izq = col_actual
        local limite_der = col_actual

        -- Desplazar límite izquierdo hacia atrás hasta topar con un espacio o el inicio del string
        while limite_izq > 1 and not texto_comando:sub(limite_izq - 1, limite_izq - 1):match("%s") do
            limite_izq = limite_izq - 1
        end

        -- Desplazar límite derecho hacia adelante hasta topar con un espacio o el fin del string
        while limite_der <= total_caracteres and not texto_comando:sub(limite_der, limite_der):match("%s") do
            limite_der = limite_der + 1
        end

        -- 4. Extracción y sanitización de la palabra seleccionada
        local palabra_actual = texto_comando:sub(limite_izq, limite_der - 1)
        palabra_actual = palabra_actual:gsub("^%s+", ""):gsub("%s+$", "")

        -- 5. Envío al despachador de goteo único recurrente (Aplica el hachazo automático)
        if palabra_actual ~= "" then
            tts.speak(palabra_actual)
        end
    end, 15)
end

-- =============================================================================
-- REGISTRO DE KEYMAPS TRANSPARENTES PARA MODO COMANDO ('c')
-- =============================================================================

-- Control + Flecha Izquierda: Mueve el cursor una palabra atrás y la verbaliza
vim.keymap.set('c', '<C-Left>', function()
    local secuencia = vim.api.nvim_replace_termcodes('<C-Left>', true, true, true)
    vim.api.nvim_feedkeys(secuencia, 'n', true)
    
    capturar_y_verbalizar_palabra_comando()
end, { desc = "TTS: Leer palabra anterior en la linea de comandos" })

-- Control + Flecha Derecha: Mueve el cursor una palabra adelante y la verbaliza
vim.keymap.set('c', '<C-Right>', function()
    local secuencia = vim.api.nvim_replace_termcodes('<C-Right>', true, true, true)
    vim.api.nvim_feedkeys(secuencia, 'n', true)
    
    capturar_y_verbalizar_palabra_comando()
end, { desc = "TTS: Leer palabra siguiente en la linea de comandos" })

