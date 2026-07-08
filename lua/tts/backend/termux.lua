-- lua/a11y/tts/backend/termux.lua
local M = {}

local speak_pipe  = vim.fn.expand("~/.tts_speak")
local cancel_pipe = vim.fn.expand("~/.tts_cancel")

function M.is_available()
  return vim.fn.filereadable(speak_pipe) == 1
end

function M.speak(text, on_done)
  if not M.is_available() then
    vim.notify("[a11y] Loop TTS no está corriendo.", vim.log.levels.WARN)
    return nil
  end
--M.cancel(nil)
--vim.uv.spawn("termux-tts-speak", { args = { "-p", "1", "" } }, function() end)   
--vim.uv.spawn("termux-tts-speak", { args = { text, text } }, function() end)   
local file = io.open(speak_pipe, "w")
  if file then
  file:write(text .. "\n")
    file:flush()
    file:close()
  end


  --local words    = select(2, text:gsub("%S+", ""))
  --local duration = math.max(500, words * 400)

  if on_done then
    vim.defer_fn(on_done, 0)
  end
 -- on_done()
  

  return { _text = text }
end

function M.cancel(job)
--vim.uv.spawn("termux-tts-speak", { args = { "-q", "" } }, function() end)  
  --local file = io.open(cancel_pipe, "w")
  --if file then
    --file:write("cancel\n")
    --file:flush()
    --file:close()
  ---end
  
end

function M.stop()
  M.cancel(nil)
end

return M





