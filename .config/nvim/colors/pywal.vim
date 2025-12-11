" Pywal colorscheme for Neovim
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name="pywal"

" Pywal colors
let s:color0  = "#1c1c0c"
let s:color1  = "#8A7266"
let s:color2  = "#988975"
let s:color3  = "#D09C71"
let s:color4  = "#7C8480"
let s:color5  = "#A9A29D"
let s:color6  = "#C2BAAC"
let s:color7  = "#c6c6c2"
let s:color8  = "#70705b"
let s:color9  = "#8A7266"
let s:color10 = "#988975"
let s:color11 = "#D09C71"
let s:color12 = "#7C8480"
let s:color13 = "#A9A29D"
let s:color14 = "#C2BAAC"
let s:color15 = "#c6c6c2"
let s:fg = "#c6c6c2"
let s:bg = "#1c1c0c"
let s:cursor = "#c6c6c2"

function! s:h(group, fg, bg, attr)
  if a:fg != "" | exec "hi " . a:group . " guifg=" . a:fg | endif
  if a:bg != "" | exec "hi " . a:group . " guibg=" . a:bg | endif
  if a:attr != "" | exec "hi " . a:group . " gui=" . a:attr | endif
endfunction

" Editor
call s:h("Normal", s:fg, s:bg, "")
call s:h("Cursor", s:bg, s:cursor, "")
call s:h("CursorLine", "", s:color0, "NONE")
call s:h("CursorLineNr", s:color4, s:color0, "bold")
call s:h("LineNr", s:color8, s:bg, "")
call s:h("ColorColumn", "", s:color0, "")
call s:h("SignColumn", "", s:bg, "")
call s:h("VertSplit", s:color0, s:color0, "")
call s:h("StatusLine", s:fg, s:color0, "NONE")
call s:h("StatusLineNC", s:color8, s:color0, "NONE")
call s:h("Pmenu", s:fg, s:color0, "")
call s:h("PmenuSel", s:bg, s:color4, "bold")
call s:h("Visual", "", s:color8, "")
call s:h("Search", s:bg, s:color3, "")
call s:h("IncSearch", s:bg, s:color9, "")

" Syntax
call s:h("Comment", s:color8, "", "italic")
call s:h("Constant", s:color1, "", "")
call s:h("String", s:color2, "", "")
call s:h("Number", s:color3, "", "")
call s:h("Boolean", s:color1, "", "")
call s:h("Identifier", s:color4, "", "")
call s:h("Function", s:color12, "", "")
call s:h("Statement", s:color5, "", "")
call s:h("Conditional", s:color5, "", "")
call s:h("Operator", s:color6, "", "")
call s:h("Keyword", s:color13, "", "")
call s:h("PreProc", s:color9, "", "")
call s:h("Type", s:color3, "", "")
call s:h("Special", s:color14, "", "")
call s:h("Error", s:color1, s:bg, "bold")
call s:h("Todo", s:color11, s:bg, "bold")

" Diff
call s:h("DiffAdd", s:color2, s:color0, "")
call s:h("DiffChange", s:color3, s:color0, "")
call s:h("DiffDelete", s:color1, s:color0, "")

" LSP
call s:h("DiagnosticError", s:color1, "", "")
call s:h("DiagnosticWarn", s:color3, "", "")
call s:h("DiagnosticInfo", s:color4, "", "")
call s:h("DiagnosticHint", s:color6, "", "")

delfunc s:h
