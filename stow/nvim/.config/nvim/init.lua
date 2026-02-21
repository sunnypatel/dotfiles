-- ============================================================================
-- Neovim Configuration
-- ============================================================================
-- Leader key must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============================================================================
-- Bootstrap lazy.nvim (auto-install if missing)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Load plugins from lua/plugins/
-- ============================================================================
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  ui = { border = "rounded" },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- ============================================================================
-- Core Vim Options
-- ============================================================================
vim.opt.number = true                -- Show line numbers
vim.opt.mouse = "a"                  -- Enable mouse support
vim.opt.clipboard = "unnamedplus"    -- System clipboard integration
vim.opt.breakindent = true           -- Wrapped lines respect indent
vim.opt.undofile = true              -- Persistent undo
vim.opt.ignorecase = true            -- Case insensitive search
vim.opt.smartcase = true             -- Unless uppercase used
vim.opt.signcolumn = "yes"           -- Always show sign column
vim.opt.updatetime = 250             -- Faster CursorHold events
vim.opt.splitright = true            -- Vertical splits to right
vim.opt.splitbelow = true            -- Horizontal splits below
vim.opt.expandtab = true             -- Use spaces instead of tabs
vim.opt.shiftwidth = 2               -- 2-space indent
vim.opt.tabstop = 2                  -- 2-space tab
vim.opt.termguicolors = true         -- 24-bit RGB color
vim.opt.scrolloff = 8                -- Keep 8 lines above/below cursor
vim.opt.cursorline = true            -- Highlight current line

-- ============================================================================
-- Core Keymaps
-- ============================================================================
-- Clear search highlight on <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right split" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Formatting
local function format_json()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd('%!jq .')
  local line_count = vim.api.nvim_buf_line_count(0)
  cursor[1] = math.min(cursor[1], line_count)
  vim.api.nvim_win_set_cursor(0, cursor)
end

vim.keymap.set('n', '<leader>f', format_json, { desc = 'Format JSON with jq' })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.json",
  callback = format_json,
})
