
-- =============================================================================
-- 1. LAZY.NVIM BOOTSTRAP (Installer)
-- This must be at the very top of your init.lua
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- 2. GLOBAL SETTINGS (Optional but Recommended)
-- =============================================================================
-- Set leader keys before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Configure tab settings
vim.opt.tabstop = 4         -- Number of visual spaces per tab.
vim.opt.softtabstop = 4     -- Number of spaces inserted when pressing <Tab>.
vim.opt.shiftwidth = 4      -- Number of spaces to use for auto-indent.
vim.opt.expandtab = true    -- Use spaces instead of tabs.

-- Keymaps
vim.keymap.set('n', '<leader>nv', ':e ~/.config/nvim<CR>', { desc = 'Open nvim config dir' })
vim.keymap.set('n', '-', '<cmd>Oil<CR>')

-- Daily Notes System
require('daily-notes').setup()

-- =============================================================================
-- 3. LAZY.NVIM SETUP 
-- =============================================================================
require("lazy").setup({
  -- lazy.nvim's own options go here
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },

  -- All of your plugins MUST go inside this 'spec' table
  spec = {
    -- Import plugins from lua/plugins/
    { import = "plugins" },
    
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = { "OXY2DEV/markview.nvim" },
      build = ":TSUpdate",
      config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "c_sharp", "http", "json" },
          sync_install = false,
          highlight = { 
              enable = true,
              additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end
    },
  }
})

