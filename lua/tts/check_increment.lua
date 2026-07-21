
local tts = require("tts")
local text_separator = require("tts.text_separator")

vim.keymap.set('n', '<Leader>c', function()

local lista_fragmentos = text_separator.separate("Error in main.lua:465231: attempt to index global_var() + local_val")
for _, fragmento in ipairs(lista_fragmentos) do
    -- Mandamos cada trozo directamente a tu sistema actual para validar la fonética
    --tts.speak(fragmento) 
    print(fragmento)
end


end, {
    desc = "TTS: Leer mensajes actuales silenciosamente",
    silent = true -- Evita que Neovim muestre texto en la barra inferior al pulsar las teclas
})


