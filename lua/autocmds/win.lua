local tts = require("tts")

-- Creamos un grupo para agrupar los autocomandos y evitar duplicados al recargar
local tts_group = vim.api.nvim_create_augroup("TTS_NavigationReader", { clear = true })

-- AUTOMATIZACIÓN PARA CAMBIO DE VENTANA (WinEnter)
vim.api.nvim_create_autocmd("WinEnter", {
    group = tts_group,
    callback = function()
        vim.schedule(function()
            -- Obtenemos el número de la ventana actual
            local win_id = vim.api.nvim_get_current_win()
            tts.speak("Ventana " .. win_id)
        end)
    end,
})



-- 2. AUTOCOMANDO: DESPLAZAMIENTO DE VENTANA (WinScrolled)
vim.api.nvim_create_autocmd("WinScrolled", {
    group = tts_group,
    callback = function()
        -- Usamos un debouncer implícito o vim.schedule para evitar que si el scroll
        -- avanza 10 líneas seguidas, el TTS intente hablar 10 veces en paralelo.
        vim.schedule(function()
            -- Obtener la información del scroll de la ventana actual (0)
            -- 'line1' es la primera línea visible arriba y 'line2' es la última abajo
            local info_ventana = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]

            if info_ventana then
                local primera_linea = info_ventana.topline
                local ultima_linea = info_ventana.botline
                local total_lineas = vim.api.nvim_buf_line_count(0)

                -- Estructuramos un mensaje corto, útil y elocuente
                local mensaje_scroll = string.format(
                    "Desplazamiento. Viendo líneas de la %d a la %d, de un total de %d",
                    primera_linea,
                    ultima_linea,
                    total_lineas
                )

                -- Se envía al despachador único recurrente.
                -- Si sigues haciendo scroll, cada nueva línea ejecutará el interruptor
                -- automático, deteniendo el anuncio anterior y actualizando las cifras.
                tts.speak(mensaje_scroll)
            end
        end)
    end,
    desc = "TTS: Anunciar rango de líneas visibles tras un desplazamiento"
})

