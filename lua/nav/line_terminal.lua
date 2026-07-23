-- =============================================================================
-- INTERCEPTOR DE HISTORIAL EN MODO TERMINAL
-- =============================================================================
local tts = require("tts")

--- Captura de forma segura el texto de la línea del prompt de la terminal actual
local function capturar_y_verbalizar_linea_terminal()
    -- CAMBIO CRÍTICO: Reemplazamos schedule por defer_fn con 15ms de retraso.
    -- Esto le da tiempo real a la shell en Termux para reescribir el comando nuevo.
    vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local fila_actual = cursor[1] -- Fila física donde reside el prompt actual

        -- Extraer el string de la línea del buffer del terminal (índice base 0)
        local lineas = vim.api.nvim_buf_get_lines(buf, fila_actual - 1, fila_actual, false)
        local texto_linea = lineas[1] or ""

        if texto_linea ~= "" then
            -- FILTRADO DEL PROMPT
            -- Captura todo lo que esté a la derecha del signo de pesos, gato o mayor que
            local comando_puro = texto_linea:match("[$#>]%s*(.*)$") or texto_linea
            
            -- Sanitización de espacios en blanco residuales
            comando_puro = comando_puro:gsub("^%s+", ""):gsub("%s+$", "")

            -- Enviamos el comando a tu motor único recurrente
            if comando_puro ~= "" then
                tts.speak(comando_puro)
            end
        end
    end, 15) -- 15 milisegundos de retraso para el repintado de la shell en Android
end




-- =============================================================================
-- REGISTRO DE KEYMAPS TRANSPARENTES PARA MODO TERMINAL ('t')
-- =============================================================================

-- Al pulsar Flecha Arriba en el Terminal: Envía la flecha a la shell y lee el cambio
vim.keymap.set('t', '<Up>', function()
    -- vim.api.nvim_feedkeys inyecta la tecla real en la shell de Termux
    -- termcodes resuelve la conversión de strings a bytes crudos de teclado
    local flecha_arriba = vim.api.nvim_replace_termcodes('<Up>', true, true, true)
    vim.api.nvim_feedkeys(flecha_arriba, 'n', true)
    
    -- Disparamos la extracción del historial
    capturar_y_verbalizar_linea_terminal()
end, { desc = "TTS: Verbalizar comando anterior del historial" })

-- Al pulsar Flecha Abajo en el Terminal: Envía la flecha a la shell y lee el cambio
vim.keymap.set('t', '<Down>', function()
    local flecha_abajo = vim.api.nvim_replace_termcodes('<Down>', true, true, true)
    vim.api.nvim_feedkeys(flecha_abajo, 'n', true)
    
    -- Disparamos la extracción del historial
    capturar_y_verbalizar_linea_terminal()
end, { desc = "TTS: Verbalizar comando siguiente del historial" })

