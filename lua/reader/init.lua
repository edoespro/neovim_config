local M = {}

local modes = require("reader.modes")
local echo = require("reader.echo")
local tts = require("tts")

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
  modes.setup()
  echo.start()

  vim.api.nvim_create_autocmd("CursorMovedI", {
    group = vim.api.nvim_create_augroup("TTS_Accessibility_Cursor", { clear = true }),
    callback = function()
      if _G.tts_word_jump_active then
        local cursor = vim.api.nvim_win_get_cursor(0)
        local col = cursor[2] -- Columna numérica exacta (base 0)
        local line = vim.api.nvim_get_current_line()

        -- 1. Gestión estricta de los bordes físicos de la línea
        if _G.tts_word_jump_direction == "left" and col == 0 then
          tts.speak("Inicio de línea")
        elseif _G.tts_word_jump_direction == "right" and col >= #line then
          tts.speak("Fin de línea")
        else
          -- 2. Extraer el carácter físico exacto bajo el cursor (índice Lua = col + 1)
          local char_idx = col + 1
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

        -- Limpieza obligatoria de las banderas
        _G.tts_word_jump_active = false
        _G.tts_word_jump_direction = ""
      end
    end,
  })
end

M.setup()

return M

