vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("main")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-lualine/lualine.nvim" },
})

require("nvim-tree").setup()

require("lualine").setup()

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



