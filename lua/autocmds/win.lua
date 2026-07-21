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

