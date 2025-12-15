-- plugin management
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.local/share/nvim/plugged')

Plug('uZer/pywal16.nvim')
Plug('lervag/vimtex')
Plug('nvim-tree/nvim-tree.lua')
Plug('nvim-tree/nvim-web-devicons')
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.5' })
Plug('nvim-lua/plenary.nvim')
Plug('windwp/nvim-autopairs')
Plug('numToStr/Comment.nvim')

vim.call('plug#end')

-- basic settings
vim.opt.termguicolors = true
vim.cmd.colorscheme('pywal16')

-- line numbers
vim.o.number = true
vim.o.relativenumber = true

-- indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true

-- editor behavior
vim.o.wrap = false
vim.o.swapfile = false
vim.o.backup = false
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.updatetime = 50

-- split behavior
vim.o.splitright = true
vim.o.splitbelow = true

-- mouse support
vim.o.mouse = 'a'

-- keymaps
vim.g.mapleader = " "

-- config management
vim.keymap.set('n', '<leader>o', ':update<CR> :source %<CR>', { desc = "save and source config" })

-- file operations
vim.keymap.set('n', '<leader>w', ':write<CR>', { desc = "save file" })
vim.keymap.set('n', '<leader>q', ':quit<CR>', { desc = "quit" })
vim.keymap.set('n', '<leader>Q', ':qall<CR>', { desc = "quit all" })

-- clipboard
vim.keymap.set({'n', 'v', 'x'}, '<leader>y', '"+y', { desc = "copy to clipboard" })
vim.keymap.set({'n', 'v', 'x'}, '<leader>p', '"+p', { desc = "paste from clipboard" })

-- clear search highlighting
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', { desc = "clear search highlight" })

-- better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "window left" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "window down" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "window up" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "window right" })

-- move lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = "move line down" })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = "move line up" })

-- keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = "scroll down centered" })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = "scroll up centered" })

-- file explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "toggle file explorer" })

-- vimtex configuration (latex)
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'

-- disable some vimtex features
vim.g.vimtex_compiler_progname = 'nvr'  -- for callbacks
vim.g.vimtex_quickfix_mode = 0  -- don't auto-open quickfix window

-- latex keymaps (only work in .tex files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- compile
    vim.keymap.set('n', '<leader>ll', '<plug>(vimtex-compile)', { buffer = true, desc = "latex compile" })
    -- view pdf
    vim.keymap.set('n', '<leader>lv', '<plug>(vimtex-view)', { buffer = true, desc = "latex view pdf" })
    -- clean auxiliary files
    vim.keymap.set('n', '<leader>lc', '<plug>(vimtex-clean)', { buffer = true, desc = "latex clean" })
    -- stop compilation
    vim.keymap.set('n', '<leader>lk', '<plug>(vimtex-stop)', { buffer = true, desc = "latex stop compile" })
    -- toggle table of contents
    vim.keymap.set('n', '<leader>lt', '<plug>(vimtex-toc-toggle)', { buffer = true, desc = "latex toc" })
  end,
})

-- plugin configurations

-- autopairs
require('nvim-autopairs').setup({
  check_ts = false,  -- don't check treesitter
})

-- comments
require('Comment').setup()

-- file explorer
require('nvim-tree').setup({
  view = {
    width = 30,
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
})

-- telescope (fuzzy finder) - if installed
local telescope_ok, telescope = pcall(require, 'telescope')
if telescope_ok then
  telescope.setup()
  vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = "find files" })
  vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "live grep" })
  vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "find buffers" })
end

-- auto commands

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

-- notes
-- after editing this file:
-- 1. run :PlugInstall to install new plugins
-- 2. restart nvim or press <space>o to reload
--
-- latex workflow:
-- 1. open .tex file
-- 2. press <space>ll to start continuous compilation
-- 3. press <space>lv to open pdf in zathura (auto-updates)
-- 4. edit and save - pdf updates automatically
-- 5. press <space>lc to clean auxiliary files when done
