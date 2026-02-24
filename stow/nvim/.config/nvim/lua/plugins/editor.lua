-- ============================================================================
-- Editor Features: Treesitter, Telescope, and Essential Editing Tools
-- ============================================================================
return {
  -- Syntax highlighting via Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "javascript", "typescript", "json", "yaml", "markdown", "bash", "vim", "vimdoc" },
    },
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

  -- JSON path display in winbar + copy keymap
  {
    "phelipetls/jsonpath.nvim",
    ft = "json",
    config = function()
      require("jsonpath").setup({ show_on_winbar = true })
      vim.keymap.set("n", "y<C-p>", function()
        vim.fn.setreg("+", require("jsonpath").get())
      end, { desc = "Copy JSON path", buffer = true })
    end,
  },

  -- Commenting
  { "numToStr/Comment.nvim", opts = {} },

  -- Surround
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
