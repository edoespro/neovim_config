
-- Responsabilidad única: Orquestar el eco global de teclado en vim.on_key.
-- Decide qué texto verbalizar basándose en el tipo de tecla y el modo actual.

local M = {}

local tts = require("tts")
local parser = require("reader.key_parser")
local modes = require("reader.modes")

-- Tabla de traducción fonética para teclas especiales solas
local special_translations = {
  ["Esc"]   = "escape",
  ["CR"]    = "enter",
  ["BS"]    = "retroceso",
  ["Del"]   = "suprimir",
  ["Space"] = "espacio",
  ["Tab"]   = "tabulador",
  ["Up"]    = "flecha arriba",
  ["Down"]  = "flecha abajo",
  ["Left"]  = "flecha izquierda",
  ["Right"] = "flecha derecha",
}

-- Función auxiliar para traducir los nombres técnicos de los modificadores
local function get_modifier_phrase(parsed)
  local mods = parsed.modifiers
  local phrase = ""

  if mods.control then phrase = phrase .. "control " end
  if mods.alt     then phrase = phrase .. "alt " end
  if mods.shift   then phrase = phrase .. "shift " end

  -- Añadimos la tecla base (tradiciéndola si es una tecla especial)
  local base_key = parsed.key
  if special_translations[base_key] then
    base_key = special_translations[base_key]
  end

  return phrase .. base_key
end

-- Función principal que se conectará al evento global vim.on_key
function M.process_key(key_bytes)
  -- 1. Analizar la tecla usando el parser puro
  local parsed = parser.parse_key(key_bytes)

  -- Si es un evento vacío o no hay caracteres válidos, ignoramos de inmediato
  if parsed.source == "" then return end

  -- 2. Consultar el modo actual usando tu módulo de modos
  local current_mode = modes.get_mode()
  local short_mode = current_mode.short_name

  -----------------------------------------------------------------
  -- REGLA 1: LÓGICA PARA EL MODO INSERTAR ("i", "ic", "ix", etc.)
  -----------------------------------------------------------------
  if string.match(short_mode, "^i") then
  --if short_name == "i" then
	  -- En modo insertar, las teclas ESPECIALES (<BS>, <Del>, <CR>, <Space>, <Up>, <Down>, etc.)
    -- YA tienen sus propios mapeos dedicados e independientes en keymaps.lua.
    -- Las ignoramos aquí por completo para evitar lecturas duplicadas.
    if parsed.type == "ESPECIAL" then
      --tts.speak("especial " .. parsed.key)
        return
    end

    -- Las combinaciones complejas (ej. <C-a>) sí deben anunciarse
    if parsed.type == "MODIFICADOR" then
      --local phrase = get_modifier_phrase(parsed)
      print(parsed.key .. " " )
      --if parsed.key == "Left" or parsed.key == "Right" and parsed.modifiers.control == True then
      if parsed.source == "<C-Left>" or parsed.source == "<C-Right>" then	
      	local target_word = vim.fn.expand("<cword>")
	tts.speak(target_word)
	end
	--tts.speak(phrase)
      return
    end

    -- Si es un carácter SIMPLE (letras, números, puntuación suelta):
    -- Como decidiste que al escribir solo hable palabras completas al presionar <Space>,
    -- aquí en el eco de teclado general ignoramos las letras sueltas para no interrumpir.
    if parsed.type == "SIMPLE" then
      -- Opcional: Si en el futuro quieres eco de caracteres letra por letra al escribir, 
      -- descomentarías la línea de abajo. Por ahora se ignora para priorizar la palabra.
      tts.speak(parsed.key)
      return
    end
  end

  -----------------------------------------------------------------
  -- REGLA 2: LÓGICA PARA TODOS LOS DEMÁS MODOS (Normal, Visual, Línea de Comandos, etc.)
  -----------------------------------------------------------------
  -- Fuera del modo insertar, cada pulsación es un comando, por lo que DEBEMOS ecoarlo todo.
  
  --if parsed.type == "SIMPLE" then
    -- En modo Normal, si presionas 'd', dice "d" suelta
    --tts.speak(parsed.key)

  --elseif parsed.type == "ESPECIAL" then
    -- Convierte nombres técnicos como "CR" o "Esc" a español ("enter", "escape")
    --local text = special_translations[parsed.key] or parsed.key
    --tts.speak(text)

  --elseif parsed.type == "MODIFICADOR" then
    -- Construye la frase de la combinación (ej. "control shift flecha arriba")
    --local phrase = get_modifier_phrase(parsed)
    --tts.speak(phrase)
  --end
end

-- Funciones para encender y apagar el eco de teclado de manera interactiva
local ns_id = nil

function M.start()
  if not ns_id then
    -- Registramos el callback global en Neovim
    ns_id = vim.on_key(M.process_key)
  end
end

function M.stop()
  if ns_id then
    -- Al pasarle nil a la referencia guardada, vim.on_key se apaga por completo
    vim.on_key(nil, ns_id)
    ns_id = nil
  end
end

return M

