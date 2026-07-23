
local M = {}


local tts = require("tts")
local keyboard = require("keyboard")

_G.tts_word_jump_active = False
_G.tts_word_jump_direction = ""

keyboard.add_handlers({"i", "n"}, function(key_info)
      if key_info.source == "<C-Left>" or key_info.source == "<C-Right>" then
	_G.tts_word_jump_active = true
	_G.tts_word_jump_direction = key_info.key
	--tts.speak(key_info.key)
	--print(key_info.key)
end
end)

--keyboard.add_handler("c", function(key_info)
--      if key_info.source == "<C-Left>" or key_info.source == "<C-Right>" then
--	M.cursormoved_c()

--      end
--end)


-- Diccionario fonético para cuando el cursor frene en símbolos especiales
local symbol_translations = {
  ["."] = "punto",
  ["("] = "abre paréntesis",
  [")"] = "cierra paréntesis",
  ["["] = "abre corchete",
  ["]"] = "cierra corchete",
  ["{"] = "abre llave",
  ["}"] = "cierra llave",
  ['"'] = "comillas",
  ["'"] = "comilla simple",
  ["="] = "igual",
  ["+"] = "más",
  ["-"] = "menos",
  ["*"] = "asterisco",
  ["/"] = "barra",
  [";"] = "punto y coma",
  [","] = "coma",
  [":"] = "dos puntos",
  ["_"] = "barra baja",
  ["<"] = "menor que",
  [">"] = "mayor que",
}

function M.setup()

  vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
    group = vim.api.nvim_create_augroup("TTS_Accessibility_Cursor", { clear = true }),
    callback = function()
      if _G.tts_word_jump_active then
        local cursor = vim.api.nvim_win_get_cursor(0)
        local col = cursor[2] -- Columna numérica exacta (base 0)
        local line = vim.api.nvim_get_current_line()

        -- 1. Gestión estricta de los bordes físicos de la línea
        --if _G.tts_word_jump_direction == "Left" and col == 0 then
          --tts.speak("Inicio de línea")
        if _G.tts_word_jump_direction == "Right" and col >= #line then
          tts.speak("Fin de línea")
        else
          -- 2. Extraer el carácter físico exacto bajo el cursor (índice Lua = col + 1)
          local char_idx = col + 1
	  M.process(line, char_idx)
          end
        end

        -- Limpieza obligatoria de las banderas
        _G.tts_word_jump_active = false
        _G.tts_word_jump_direction = ""
      
    end,
  })
end

function M.process(line, char_idx)

	local current_char = string.sub(line, char_idx, char_idx)

          -- 3. Caso A: Si el cursor frenó sobre un espacio en blanco
          if current_char == " " or current_char == "" then
            tts.speak("espacio")

          -- 4. Caso B: Si el cursor frenó sobre un signo de puntuación / símbolo
          elseif symbol_translations[current_char] then
            tts.speak(symbol_translations[current_char])

          -- 5. Caso C: Si el cursor frenó sobre una palabra (alfanumérico o guion bajo)
          elseif string.match(current_char, "[%w_]") then
            -- Reconstruimos la palabra completa buscando sus límites de forma nativa
            -- Buscamos hacia atrás desde la posición del cursor
            local text_before = string.sub(line, 1, char_idx)
            local part1 = string.match(text_before, "([%w_]+)$") or ""

            -- Buscamos hacia adelante desde la posición del cursor (sin incluir el carácter actual que ya está en part1)
            local text_after = string.sub(line, char_idx + 1)
            local part2 = string.match(text_after, "^([%w_]+)") or ""

            local full_word = part1 .. part2
            tts.speak(full_word)
          else
            -- Respaldo por si cae en un carácter no mapeado (ej. emojis o caracteres raros)
            tts.speak(current_char)

	end
end

M.setup()

local cmd_tracker = {
    last_pos = 1,
}


function M.cursormoved_c()
    -- Programamos la ejecución justo un instante después de que la tecla actúe
    vim.schedule(function()
        local col = vim.fn.getcmdpos()
        
        -- Validamos si la posición cambió respecto al último registro
        if col ~= cmd_tracker.last_pos then
            -- ¡AQUÍ CAPTURAS EL EVENTO! El cursor se movió sin escribir nada
            local line = vim.fn.getcmdline()
	    M.process(line, col) 
            
            -- Actualizamos la última posición conocida
            cmd_tracker.last_pos = col
        end
    end)

    -- Retornamos la tecla original para que Neovim mueva el cursor normalmente

end

vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
        cmd_tracker.last_pos = 1 -- Al presionar (:) el cursor siempre inicia en 1
    end
})

    return M
