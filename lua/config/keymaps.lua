

local tts = require("tts")

local function get_last_word()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2] -- Asegúrate de extraer el índice de columna de la tabla
  local line = vim.api.nvim_get_current_line()
  
  local text_before_cursor = string.sub(line, 1, col)
  
  -- El corchete [%w_]+ significa: Busca cualquier combinación de letras, números O guiones bajos
  local last_word = string.match(text_before_cursor, "([%w_]+)$")
  
  return last_word
end


-- 1. Mapeo para la tecla <Space> (Verbaliza palabras procesando guiones bajos)
vim.keymap.set("i", "<Space>", function()
  
  local word = get_last_word()
  
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



-- 2. Mapeo para la tecla <BS> (Verbaliza caracteres individuales)
vim.keymap.set("i", "<BS>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  
  --if col > 0 then
    -- Captura el carácter exacto que el Backspace va a eliminar
    local char_to_delete = string.sub(line, col, col)

    if char_to_delete == " " then
      char_to_delete = "espacio"
    elseif char_to_delete == "" and row > 1 then
      char_to_delete = "fin de línea"
      --char_to_delete = "delete line"
    end

    tts.speak(char_to_delete)
  --end

  return "<BS>"
end, { expr = true, replace_keycodes = true })


vim.keymap.set("i", "<CR>", function()
  -- Envía el aviso de nueva línea al proceso persistente de inmediato
  --tts.speak("new line")
  local word = get_last_word()
  
  if not word or word == "" then 
    tts.speak("Inicio de línea")
  elseif word and word ~= "" then
    -- Envía la palabra completa al proceso persistente de inmediato
    tts.speak(word)
  end

  -- Retorna el Enter físico para que Neovim salte de línea en el búfer
  return "<CR>"
end, { expr = true, replace_keycodes = true })



-- 3. Mapeo para la tecla <Del> (Suprimir - Borra hacia adelante) - CORREGIDO
vim.keymap.set("i", "<Del>", function()
  local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve una tabla {fila, columna}
  local col = cursor[2]                         -- Extraemos la columna (basada en 0)
  local line = vim.api.nvim_get_current_line()
  
  -- Ahora 'col' es un número real, por lo que podemos sumarle 1 de forma segura
  local target_col = col + 1
  
  --if target_col <= #line then
    local char_to_delete = string.sub(line, target_col, target_col)

    if char_to_delete == " " then
      char_to_delete = "espacio"
    elseif char_to_delete == "" then
      char_to_delete = "delete line"
    end

    tts.speak(char_to_delete)
  --end

  return "<Del>"
end, { expr = true, replace_keycodes = true })

-- 4. Mapeo para la tecla <Left> (Navegación horizontal izquierda) - CORREGIDO
vim.keymap.set("i", "<Left>", function()
  local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve la tabla {fila, columna}
  local col = cursor[2]                        -- [CORRECCIÓN] Extrae el número de columna (base 0)
  local line = vim.api.nvim_get_current_line()

  -- Si ya está en la columna 0, no puede retroceder más dentro de esta línea
  if col == 0 then
    tts.speak("Inicio de línea")
  else
    -- Al movernos a la izquierda, el cursor se desplazará al índice anterior.
    -- Como Neovim usa base 0 y Lua usa base 1, el índice del carácter de destino
    -- en Lua coincide exactamente con el valor actual de 'col'.
    local next_char = string.sub(line, col, col)

    if next_char == " " then
      next_char = "espacio"
    elseif next_char == "" then
      next_char = "salto de línea"
    end

    tts.speak(next_char)
  end

  return "<Left>"
end, { expr = true, replace_keycodes = true })




-- 5. Mapeo para la tecla <Right> (Navegación horizontal derecha) - CORREGIDO
vim.keymap.set("i", "<Right>", function()
  local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve la tabla {fila, columna}
  local col = cursor[2]                         -- Extrae el número de columna (base 0)
  local line = vim.api.nvim_get_current_line()

  -- En modo insertar, la longitud máxima permitida es igual a #line (el final de la línea)
  if col >= #line then
    tts.speak("Fin de línea")
  else
    -- Al movernos a la derecha, el cursor avanzará un paso.
    -- Para ver el carácter que estará bajo el cursor en Lua (base 1), 
    -- sumamos 2 al índice de Neovim (base 0).
    local next_col = col + 2
    local next_char = string.sub(line, next_col, next_col)

    if next_char == " " then
      next_char = "espacio"
    elseif next_char == "" then
      next_char = "fin de línea"
    end

    tts.speak(next_char)
  end

  return "<Right>"
end, { expr = true, replace_keycodes = true })

-- 6. Mapeo para la tecla <Down> (Navegación vertical hacia abajo)
vim.keymap.set("i", "<Down>", function()
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

  return "<Down>"
end, { expr = true, replace_keycodes = true })





-- 7. Mapeo para la tecla <Up> (Navegación vertical hacia arriba) - CORREGIDO
vim.keymap.set("i", "<Up>", function()
 
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

  return "<Up>"
end, { expr = true, replace_keycodes = true })


local function check_map()

-- Obtener detalles del mapeo 'x' en modo normal
local map_details = vim.fn.maparg('<C-Left>', 'i', false, true)

if next(map_details) ~= nil then
    print(vim.inspect(map_details))
    -- Devuelve una tabla como: { lhs = "x", rhs = "_x", mode = "n", silent = 0, ... }
else
    print("La tecla 'C-Left' no está mapeada en modo insert")
end

end

--check_map()

-- Declaramos variables globales compartidas para que el autocomando las lea
_G.tts_word_jump_active = false
_G.tts_word_jump_direction = ""

-- 8. Mapeo para <C-Left> (Solo levanta la bandera de dirección)
vim.keymap.set("i", "<C-Left>", function()
  _G.tts_word_jump_active = true
  _G.tts_word_jump_direction = "left"
  return "<C-Left>"
end, { expr = true, replace_keycodes = true })

-- 9. Mapeo para <C-Right> (Solo levanta la bandera de dirección)
vim.keymap.set("i", "<C-Right>", function()
  _G.tts_word_jump_active = true
  _G.tts_word_jump_direction = "right"
  return "<C-Right>"
end, { expr = true, replace_keycodes = true })


