local tts_group = vim.api.nvim_create_augroup("TTS_SystemEvents", { clear = true })

-- =============================================================================
-- 1. AUTOCOMANDO: CANCELACIÓN / INTERRUPCIÓN DE COMANDO (CmdlineLeave)
-- =============================================================================

local tts = require("tts")

vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = tts_group,
    callback = function()
        -- vim.v.event.abort devuelve true si el usuario canceló el comando 
        -- (por ejemplo, presionando Escape o Control+C en lugar de Enter)
        if vim.v.event and vim.v.event.abort then
            vim.schedule(function()
                -- Llama a tu función que aplica el hachazo al pasado y verbaliza
                tts.speak("Comando cancelado")
            end)
        end
    end,
    desc = "TTS: Anunciar interrupción o cancelación de la línea de comandos"
})

