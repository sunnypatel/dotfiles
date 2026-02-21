-- ============================================================================
-- Editor Features: Treesitter, Telescope, and Essential Editing Tools
-- ============================================================================
return {
  -- Syntax highlighting via Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      -- Install parsers if missing (runs async, no-op if already installed)
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          local ensure = { "lua", "javascript", "typescript", "json", "yaml", "markdown", "bash", "vim", "vimdoc" }
          local installed = require("nvim-treesitter.config").get_installed()
          local missing = vim.tbl_filter(function(p) return not vim.tbl_contains(installed, p) end, ensure)
          if #missing > 0 then
            require("nvim-treesitter.install").install(missing)
          end
        end,
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
  },

  -- Commenting
  { "numToStr/Comment.nvim", opts = {} },

  -- Surround
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
