local M = {}

tts = require("tts")
keyboard = require("keyboard")
 
keyboard.add_handlers({"i", "c"}, function(key_info)
if key_info.type == "SIMPLE" then
tts.speak(key_info.key)
end
end)

keyboard.add_handler("c", function(key_info) 
if key_info.source == "<Space>" then
	M.space_c()
end
end)

function M.get_last_word(line, col)
--  local cursor = vim.api.nvim_win_get_cursor(0)
  --local col = cursor[2] -- Asegúrate de extraer el índice de columna de la tabla
  --local line = vim.api.nvim_get_current_line()

  local text_before_cursor = string.sub(line, 1, col)

  -- El corchete [%w_]+ significa: Busca cualquier combinación de letras, números O guiones bajos
  local last_word = string.match(text_before_cursor, "([%w_]+)$")

  return last_word
end


-- 1. Mapeo para la tecla <Space> (Verbaliza palabras procesando guiones bajos)
vim.keymap.set("i", "<Space>", function()

  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2] -- Asegúrate de extraer el índice de columna de la tabla
  local line = vim.api.nvim_get_current_line()
  local word = M.get_last_word(line, col)

  if word and word ~= "" then
    -- Envía la palabra completa al proceso persistente de inmediato
    tts.speak(word)
  end

        --local word = get_last_word()

  --if word and word ~= "" then
    -- Reemplaza globalmente (string.gsub) cada "_" por la frase "barra baja "
    -- El espacio extra al final de "barra baja " asegura que el motor TTS separe los sonidos de las palabras vecinas
    --local verbalized_word = string.gsub(word, "_", "barra baja ")

    -- Eliminamos posibles espacios dobles al final para limpiar el texto
    --verbalized_word = vim.trim(verbalized_word)

    -- Envía la expresión procesada completa a la cola FIFO
    --tts.speak(verbalized_word)
  --end

  return "<Space>"
end, { expr = true, replace_keycodes = true })


function M.space_c()

local col = vim.fn.getcmdpos()
local line = vim.fn.getcmdline()
local word = M.get_last_word(line, col)
tts.speak(word)

end

return M


