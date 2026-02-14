-- ============================================================================
-- UI Enhancements: Colorscheme, Statusline, and Visual Aids
-- ============================================================================
return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Which-key (shows keybinding hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
