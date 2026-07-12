local M = {}

tts = require("tts")
keyboard = require("keyboard")

keyboard.add_handlers({"i", "n", "V"}, function(key_info) 

if key_info.source == "<Down>" then

M.down()
elseif key_info.source == "<Up>" then
	M.up()
elseif key_info.source == "<Home>" then
	tts.speak("Inicio de línea")
elseif key_info.source == "<End>" then
	tts.speak("Fin de línea")
end

end)



function M.down()
--vim.uv.spawn("termux-tts-speak", { args = { "-q", "" } }, function() end)
        --print("down down down down")
        local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve la tabla {fila, columna}
  local row = cursor[1]                         -- Extrae el número de fila actual (base 1)

  -- Obtenemos el número total de líneas en el búfer actual
  local total_lines = vim.api.nvim_buf_line_count(0)

  -- Si la fila actual ya es la última línea del archivo, no puede bajar más
  if row >= total_lines then
    tts.flush("Fin del archivo")
  else
    -- Usamos vim.api.nvim_buf_get_lines para leer el texto de la línea siguiente.
    -- Esta API usa base 0. Como 'row' en Neovim ya está apuntando de forma natural
    -- al índice de la línea de abajo en base 0, pasamos 'row' y 'row + 1'.
    local next_lines = vim.api.nvim_buf_get_lines(0, row, row + 1, false)
    local target_line = next_lines[1] or ""

    -- Si la línea de abajo está completamente vacía, verbaliza "Línea vacía"
    if target_line == "" then
      target_line = "Línea vacía"
    end

    tts.flush(target_line)
  end

end


function M.up()
        --vim.uv.spawn("termux-tts-speak", { args = { "-q", "" } }, function() end)
        --print("up up up up")
        local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve la tabla {fila, columna}
  local row = cursor[1]                         -- [CORRECCIÓN] Extrae el número de fila (base 1)

  -- Ahora 'row' es un número real, por lo que la comparación funciona perfectamente
  if row <= 1 then
    tts.flush("Inicio del archivo")
  else
    -- Para leer la línea de arriba usando la API (base 0):
    -- Si estamos en la fila 5, la de arriba es el índice 3 en base 0. Formula: row - 2.
    local target_idx = row - 2
    local next_lines = vim.api.nvim_buf_get_lines(0, target_idx, target_idx + 1, false)
    local target_line = next_lines[1] or ""

    if target_line == "" then
      target_line = "Línea vacía"
    end

    tts.flush(target_line)
  end

end



_speak_line = false

keyboard.add_handler("c", function(key_info)

        if key_info.source == "<Down>" or key_info.source == "<Up>" then
                _speak_line = true
        end
end)

local my_cursor_group = vim.api.nvim_create_augroup("CustomCursorTracker", { clear = true })

-- 1. DETECTAR EN MODO COMANDO (:)
vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = my_cursor_group,
    pattern = "*",
    callback = function()
        if _speak_line then
            --local cursor_pos = vim.fn.getcmdpos()
        local current_cmd = vim.fn.getcmdline()
        -- Tu lógica aquí
        tts.speak(current_cmd .. " ")
        _speak_line = false
end
end,
})



return M
