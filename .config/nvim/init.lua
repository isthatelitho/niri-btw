local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.local/share/nvim/plugged')

-- Add your plugins here, for example:
-- Plug 'preservim/nerdtree'
-- Plug 'junegunn/fzf.vim'
   Plug 'dylanaraps/wal.vim'
vim.call('plug#end')
vim.cmd('colorscheme wal')
