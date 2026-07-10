
-- Responsabilidad única: Orquestar el eco global de teclado en vim.on_key.
-- Decide qué texto verbalizar basándose en el tipo de tecla y el modo actual.

local M = {}

local parser = require("keyboard.key_parser")



local listeners = {}

function M.add_handler(event, handler)
  if not listeners[event] then
	  listeners[event] = {}
	  end
  table.insert(listeners[event], handler)
end


function M.dispatch(event, data)
	if not listeners[event] then return end
  for _, handler in ipairs(listeners[event]) do
    handler(data)
  end
end

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

 M.dispatch(parsed.type, parsed)

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

M.start()
return M

