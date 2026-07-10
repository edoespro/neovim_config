vim.opt.number = true
---- Color de los números de línea normales (Foreground, Background)
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#ffffff', bg = 'NONE' })

---- Color del número de línea donde está el cursor (más brillante)
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#88c0d0', bg = 'NONE', bold = true })

vim.g.python3_host_prog = '/data/data/com.termux/files/usr/bin/python3' -- Cambia por la ruta real

