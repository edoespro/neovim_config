local M = {}

tts = require("tts")
keyboard = require("keyboard")

keyboard.add_handlers({"i", "n", "v", "t"}, function(key_info) 

if key_info.source == "<Left>" then

M.left()
elseif key_info.source == "<Right>" then
	M.Right()
end

end)

function M.left()

local cursor = vim.api.nvim_win_get_cursor(0) -- Devuelve la tabla {fila, columna}
  local col = cursor[2]                        -- [CORRECCIÓN] Extrae el número de columna (base 0)
  local line = vim.api.nvim_get_current_line()

  -- Si ya está en la columna 0, no puede retroceder más dentro de esta línea
  --if col == 0 then
    --tts.speak("Inicio de línea")
  --else
    -- Al movernos a la izquierda, el cursor se desplazará al índice anterior.
    -- Como Neovim usa base 0 y Lua usa base 1, el índice del carácter de destino
    -- en Lua coincide exactamente con el valor actual de 'col'.
    local next_char = string.sub(line, col, col)

    if next_char == " " then
      next_char = "espacio"
    elseif next_char == "" then
    next_char = string.sub(line, col+1, col+1)
    --next_char = "salto de línea"
    end

    tts.speak(next_char)
  --end
end


function M.Right()
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

end


keyboard.add_handler("c", function(key_info) 

if key_info.source == "<Left>" then

M.left_c()
elseif key_info.source == "<Right>" then
  M.Right_c()
end

end)

function M.left_c()

local col = vim.fn.getcmdpos()
local line = vim.fn.getcmdline()
	-- Si ya está en la columna 0, no puede retroceder más dentro de esta línea
  if col == 0 then
    tts.speak("Inicio de línea")
  else
    -- Al movernos a la izquierda, el cursor se desplazará al índice anterior.
    -- Como Neovim usa base 0 y Lua usa base 1, el índice del carácter de destino
    -- en Lua coincide exactamente con el valor actual de 'col'.
    if col > 1 then
    col = col - 1
    end
    local next_char = string.sub(line, col, col)

    if next_char == " " then
      next_char = "espacio"
    elseif next_char == "" then
      next_char = "salto de línea"
    end

    tts.speak(next_char)
  end
end


function M.Right_c()

local col = vim.fn.getcmdpos()
local line = vim.fn.getcmdline()

  -- En modo insertar, la longitud máxima permitida es igual a #line (el final de la línea)
  if col >= #line then
    tts.speak("Fin de línea")
  else
    -- Al movernos a la derecha, el cursor avanzará un paso.
    -- Para ver el carácter que estará bajo el cursor en Lua (base 1),
    -- sumamos 2 al índice de Neovim (base 0).
    local next_col = col + 1
    local next_char = string.sub(line, next_col, next_col)

    if next_char == " " then
      next_char = "espacio"
    elseif next_char == "" then
      next_char = "fin de línea"
    end

    tts.speak(next_char)
  end

end


return M

