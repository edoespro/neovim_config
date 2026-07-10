-- Responsabilidad única: Traducir bytes crudos a una estructura estandarizada
-- Corrige el filtro de patrones de Lua usando escapes correctos para el guion.

local M = {}

-- Función auxiliar para desglosar combinaciones complejas como <C-S-Up> o <M-x>
local function parse_modifiers(content)
  local modifiers = {
    control = false,
    alt = false,
    shift = false,
  }

  -- Separamos la cadena por el guion
  local parts = {}
  for part in string.gmatch(content, "[^-]+") do
    table.insert(parts, part)
  end

  -- La última parte es siempre la tecla base (ej: "Up" o "x")
  local key_base = parts[#parts]

  -- Las partes anteriores corresponden a los modificadores activos
  for i = 1, #parts - 1 do
    local mod = parts[i]
    if mod == "C" then
      modifiers.control = true
    elseif mod == "M" or mod == "A" then
      modifiers.alt = true
    elseif mod == "S" then
      modifiers.shift = true
    end
  end

  return key_base, modifiers
end

-- Función principal del módulo
function M.parse_key(key_bytes)
  -- 1. Traducir bytes crudos a formato Vim string (ej: <C-a>, <Esc>, a)
  local source = vim.fn.keytrans(key_bytes)

  -- Estructura base requerida
  local result = {
    source = source,
    type = "SIMPLE",
    key = source,
    modifiers = { control = false, alt = false, shift = false },
  }

  if source == "" then
    return result
  end

  -- 2. Clasificación mediante Patrones de Lua corregidos

  -- CASO A: Modificadores (ej: <C-a>, <M-x>, <S-Tab>)
  -- [CORRECCIÓN] Usamos '%-' para obligar a que exista el carácter físico del guion.
  -- El patrón significa: inicia con '<', luego una de las letras C, M o S, luego UN GUION obligatorio, 
  -- seguido de cualquier texto y cierra con '>'.
  if string.match(source, "^<[CMS]%-.+>$") then
    result.type = "MODIFICADOR"
    local content = string.sub(source, 2, -2) -- Quita '<' y '>'
    local key_base, active_mods = parse_modifiers(content)
    result.key = key_base
    result.modifiers = active_mods

  -- CASO B: Teclas Especiales Solas (ej: <Esc>, <Up>, <CR>, <Space>)
  -- Al fallar el caso anterior, si contiene '<' y '>', es una tecla especial pura.
  elseif string.match(source, "^<.+>$") then
    result.type = "ESPECIAL"
    result.key = string.sub(source, 2, -2) -- Quita '<' y '>' para dejar la clave limpia

  -- CASO C: Caracteres Simples / ASCII (ej: "a", "1", "A")
  else
    result.type = "SIMPLE"
    result.key = source
  end

  return result
end

return M



