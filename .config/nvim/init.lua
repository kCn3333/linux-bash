-- ~/.config/nvim/init.lua


-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- core options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes"

-- 
vim.keymap.set('n', '<C-l>', function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  vim.opt.signcolumn = vim.opt.signcolumn:get() == "yes" and "no" or "yes"
end, { desc = "Toggle line numbers" })

-- Navigation between windows (Alt + hjkl)
vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = "Przejdź w lewo" })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = "Przejdź w dół" })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = "Przejdź w górę" })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = "Przejdź w prawo" })

-- plugins
require("lazy").setup({
    {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      -- Ustawienia motywu
      vim.g.vscode_style = "dark"          -- dark mode 
      vim.g.vscode_enable_italic = 1       -- enable italic comments
      vim.g.vscode_enable_bold = 1         -- enable bold keywords
      vim.cmd.colorscheme("vscode")        -- load the colorscheme

      -- Color customizations
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#82cfff", bold = true })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#2a2d2e" })
      vim.api.nvim_set_hl(0, "Search", { bg = "#3e4452", fg = "#ffffff" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "java", "bash", "json", "yaml", "dockerfile" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "material" }
      })
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {

          path_display = { "truncate" },
        }
      })
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- for file icons
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35,
          side = "left",
        },
        renderer = {
          group_empty = true, -- group empty folders
          highlight_opened_files = "all",
        },
        filters = {
          dotfiles = false, -- show dotfiles
        },
      })

      -- \e to toggle the file explorer
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

})
