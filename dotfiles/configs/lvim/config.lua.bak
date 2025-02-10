-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.builtin.telescope.defaults.layout_config.width = 200
lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 120
lvim.builtin.telescope.defaults.layout_strategy = "flex"
lvim.builtin.telescope.defaults.path_display = { "absolute" }

lvim.format_on_save.enabled = true

lvim.plugins = {
  "norcalli/nvim-colorizer.lua",
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup {
        navigation = {
          -- cycles to opposite pane while navigating into the border
          -- cycle_navigation = true,

          -- enables default keybindings (C-hjkl) for normal mode
          enable_default_keybindings = true,

          -- prevents unzoom tmux when navigating beyond vim border
          persist_zoom = true,
        },
        resize = {
          -- enables default keybindings (A-hjkl) for normal mode
          enable_default_keybindings = true,
        },
      }
    end,
  },
  {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Documents", "~/Downloads", "/" },
      }
    end
  },
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
    end,
  },
}

-- Keybindings
lvim.keys.normal_mode["|"] = ":vsplit<CR>"
lvim.keys.normal_mode["-"] = ":split<CR>"
lvim.keys.normal_mode["<C-b>"] = ":b#"

-- colorizer plugin for color highlighting
require 'colorizer'.setup()

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
  "go",
  "hcl",
  "markdown",
  "dart",
  "markdown_inline"
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { name = "black" },
  {
    name = "prettierd",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespace
    ---@usage only start in these filetypes, by default it will attach to all filetypes it supports
    filetypes = { "typescript", "typescriptreact", 'javascript', 'javascriptreact' },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { name = "flake8" },
  {
    name = "shellcheck",
    args = { "--severity", "warning" },
  },
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
  {
    name = "proselint",
  },
}

-- Auto change to current directory
-- vim.opt.autochdir = true
