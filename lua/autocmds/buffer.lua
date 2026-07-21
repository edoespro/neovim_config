local tts = require("tts")

-- Creamos un grupo para agrupar los autocomandos y evitar duplicados al recargar
local tts_group = vim.api.nvim_create_augroup("TTS_NavigationReader", { clear = true })

-- AUTOMATIZACIÓN PARA CAMBIO DE VENTANA (WinEnter)
-- AUTOMATIZACIÓN PARA CAMBIO DE BUFFER (BufEnter)
vim.api.nvim_create_autocmd("BufEnter", {
    group = tts_group,
    callback = function()
        vim.schedule(function()
            -- Obtenemos la ruta completa del buffer actual
            local buf_name = vim.api.nvim_buf_get_name(0)
            -- Obtenemos el tipo de archivo (ej. lua, python, markdown)
            local filetype = vim.bo.filetype

            local mensaje = ""

            if buf_name == "" then
                mensaje = "Buffer vacío"
            else
                -- Extraemos solo el nombre del archivo (descartando la ruta de Termux)
                local nombre_archivo = vim.fs.basename(buf_name)
                mensaje = "" .. nombre_archivo
            end

            -- Si el archivo tiene un tipo definido (ej. Python), lo añadimos al mensaje
            --if filetype and filetype ~= "" then
                --mensaje = mensaje .. ", tipo " .. filetype
            --end

            tts.speak(mensaje)
        end)
    end,
})

