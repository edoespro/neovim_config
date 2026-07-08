-- Responsabilidad única: Traducir, registrar y exponer el modo actual de Neovim.
-- Gestiona los autocomandos mode_changed globales y verbaliza las transiciones.

local M = {}
local tts = require("tts")

-- Diccionario de mapeo: short_name -> name (Traducido y Normalizado)
M.mode_map = {
  ["n"]      = "Normal",
  ["niI"]    = "Normal temporal en inserción",
  ["niR"]    = "Normal temporal en reemplazo",
  ["niV"]    = "Normal temporal en reemplazo virtual",
  ["nt"]     = "Normal en terminal",
  
  ["v"]      = "Visual carácter por carácter",
  ["V"]      = "Visual por línea",
  ["\22"]    = "Visual por bloque",
  ["ve"]     = "Selección visual",
  
  ["s"]      = "Selección por carácter",
  ["S"]      = "Selección por línea",
  ["\19"]    = "Selección por bloque",
  
  ["i"]      = "Inserción",
  ["ic"]     = "Inserción con autocompletado activo",
  ["ix"]     = "Inserción con completado especial",
  
  ["R"]      = "Reemplazo",
  ["Rc"]     = "Reemplazo con autocompletado activo",
  ["Rx"]     = "Reemplazo con completado especial",
  ["Rv"]     = "Reemplazo virtual",
  
  ["c"]      = "Línea de comandos",
  ["cv"]     = "Ex modo vim",
  ["ce"]     = "Ex modo normal",
  ["ci"]     = "Inserción en línea de comandos",
  ["cr"]     = "Reemplazo en línea de comandos",
  
  ["o"]      = "Operador pendiente",
  ["no"]     = "Operador pendiente general",
  ["nov"]    = "Operador pendiente forzado por caracteres",
  ["noV"]    = "Operador pendiente forzado por líneas",
  ["no\22"]  = "Operador pendiente forzado por bloques",
  
  ["e"]      = "Línea de comandos flotante",
  ["s"]      = "Barra de estado flotante",
  ["sd"]     = "Arrastrando barra de estado",
  ["vs"]     = "Separador vertical flotante",
  ["vd"]     = "Arrastrando separador vertical",
  ["m"]      = "Mensaje de paginación",
  ["ml"]     = "Mensaje de última línea de paginación",
  ["sm"]     = "Coincidencia de paréntesis",
  ["t"]      = "Terminal activa",
}

-- Devuelve una tabla con { name = "Modo", short_name = "s_name" }
function M.get_mode()
  -- nvim_get_mode devuelve una tabla donde .mode es el string corto (ej: "n", "i")
  local current = vim.api.nvim_get_mode()
  local s_name = current.mode
  local name = M.mode_map[s_name] or ("Modo desconocido " .. s_name)
  
  return {
    name = name,
    short_name = s_name
  }
end

-- Hook global ejecutado ANTES de abandonar un modo
function M.on_exit(old_mode_info)
  -- Reservado para lógicas futuras (ej. limpiar cachés de voz, detener timers)
end

-- Hook global ejecutado AL ENTRAR a un nuevo modo
function M.on_enter(new_mode_info)
  -- Verbaliza el nuevo modo de manera inmediata por la cola FIFO
  tts.speak(new_mode_info.name)
end

-- Inicializa el autocomando nativo de Neovim
function M.setup()
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("TTS_Accessibility_Modes", { clear = true }),
    pattern = "*:*", -- Captura cualquier transición de modo (ej: n:i, i:n)
    callback = function(args)
      -- El campo args.match contiene el patrón "antiguo_modo:nuevo_modo" (ej: "n:i")
      local parts = vim.split(args.match, ":")
      local old_short = parts[1]
      local new_short = parts[2]

      local old_name = M.mode_map[old_short] or "Modo anterior"
      local new_name = M.mode_map[new_short] or "Modo nuevo"

      -- Disparamos las funciones de gestión general estructurando la información
      M.on_exit({ name = old_name, short_name = old_short })
      M.on_enter({ name = new_name, short_name = new_short })
    end,
  })
end

return M

