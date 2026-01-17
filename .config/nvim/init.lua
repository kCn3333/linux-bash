-- ~/.config/nvim/init.lua
-- Neovim configuration with lazy.nvim plugin manager

-- ============================================================================
-- LAZY.NVIM BOOTSTRAP
-- ============================================================================
-- Automatically install lazy.nvim if it doesn't exist
-- This ensures the plugin manager is available on first run
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
-- Prepend lazy.nvim to runtime path so it can be loaded
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- CORE VIM OPTIONS
-- ============================================================================
-- Enable 24-bit RGB color in the terminal
vim.opt.termguicolors = true

-- Display absolute line numbers in the left gutter
vim.opt.number = true

-- Display line numbers relative to cursor position (useful for motions)
vim.opt.relativenumber = true

-- Enable mouse support in all modes
vim.opt.mouse = "a"

-- Use system clipboard for all yank/delete/paste operations
vim.opt.clipboard = "unnamedplus"

-- Always show the sign column to prevent text shifting when signs appear
vim.opt.signcolumn = "yes"

-- ============================================================================
-- CUSTOM KEYMAPS
-- ============================================================================
-- Toggle line numbers and sign column with Ctrl+L
-- Useful for clean copying or presentation mode
vim.keymap.set('n', '<C-l>', function()
  vim.opt.number = not vim.opt.number:get()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
  vim.opt.signcolumn = vim.opt.signcolumn:get() == "yes" and "no" or "yes"
end, { desc = "Toggle line numbers and sign column" })

-- ============================================================================
-- PLUGIN CONFIGURATION
-- ============================================================================
require("lazy").setup({
  -- --------------------------------------------------------------------------
  -- COLORSCHEME: VSCode Theme
  -- --------------------------------------------------------------------------
  {
    "Mofiqul/vscode.nvim",
    priority = 1000, -- Load colorscheme before other plugins
    config = function()
      -- Set VSCode theme variant (options: "dark", "light", "hc")
      vim.g.vscode_style = "dark"
      
      -- Enable italic fonts for comments and keywords
      vim.g.vscode_enable_italic = 1
      
      -- Enable bold fonts for certain syntax elements
      vim.g.vscode_enable_bold = 1
      
      -- Apply the colorscheme
      vim.cmd.colorscheme("vscode")
      
      -- Custom highlight overrides for softer, more pastel appearance
      -- Make current line number stand out with bright blue
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#82cfff", bold = true })
      
      -- Subtle visual selection background
      vim.api.nvim_set_hl(0, "Visual", { bg = "#2a2d2e" })
      
      -- Search highlight with better contrast
      vim.api.nvim_set_hl(0, "Search", { bg = "#3e4452", fg = "#ffffff" })
    end,
  },

  -- --------------------------------------------------------------------------
  -- TREESITTER: Advanced Syntax Highlighting & Code Understanding
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Auto-update parsers after install/update
    opts = {
      -- List of language parsers to install automatically
      ensure_installed = { 
        "lua", 
        "java", 
        "bash", 
        "json", 
        "yaml", 
        "dockerfile" 
      },
      
      -- Enable treesitter-based syntax highlighting
      highlight = {
        enable = true,
        -- Disable vim's regex-based highlighting to avoid conflicts
        additional_vim_regex_highlighting = false,
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- LSP: Language Server Protocol Support
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    -- Note: This just loads the plugin; actual LSP servers need to be
    -- configured separately (e.g., with require('lspconfig').lua_ls.setup{})
  },

  -- --------------------------------------------------------------------------
  -- STATUSLINE: Lualine
  -- --------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { 
          -- Use material theme for consistent look
          theme = "material" 
        }
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- FUZZY FINDER: Telescope
  -- --------------------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    -- Using latest master branch for compatibility with Neovim 0.11+
    -- Remove tag/branch specification to get latest version
    dependencies = { 'nvim-lua/plenary.nvim' }, -- Required dependency
    config = function()
      require('telescope').setup({
        defaults = {
          -- Truncate long file paths for better readability
          -- Extra safeguard for Neovim 0.11 compatibility
          path_display = { "truncate" },
        }
      })
      
      -- Convenient keybindings for common Telescope operations
      local builtin = require('telescope.builtin')
      
      -- Ctrl+P: Find files in current directory
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find Files" })
      
      -- <leader>fg: Live grep search across all files
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
      
      -- <leader>fb: List and switch between open buffers
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
    end
  },
})
