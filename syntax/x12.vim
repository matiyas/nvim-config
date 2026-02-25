" Vim syntax file for ANSI X12 EDI
" Fixed version - handles variable-length ISA and escapes special regex chars

if exists("b:current_syntax")
  finish
endif

if getline(1) =~ "^ISA"
  let b:ISA = getline(1)
elseif getline(2) =~ "^ISA"
  let b:ISA = getline(2)
else
  finish
endif

" Element delimiter is always at position 3
let b:elmdl = b:ISA[3:3]

" Sub-element delimiter (ISA16) is last char for variable-length ISA
" or position 104 for standard 106-char ISA
let s:len = strlen(b:ISA)
if s:len > 105
  let b:subdl = b:ISA[104:104]
  let b:segdl = b:ISA[105:105]
else
  let b:subdl = b:ISA[s:len - 1:s:len - 1]
endif

" Escape for very-nomagic mode (only backslash needs escaping)
let s:elm_esc = escape(b:elmdl, '\')
let s:sub_esc = escape(b:subdl, '\')

exe 'syn match x12ElmDelimiter "\V' . s:elm_esc . '"'
exe 'syn match x12SubDelimiter "\V' . s:sub_esc . '"'

if exists("b:segdl")
  let s:seg_esc = escape(b:segdl, '\')
  exe 'syn match x12SegDelimiter "\V' . s:seg_esc . '"'
endif

syn match x12Envelope "^\(ISA\|GS\|ST\|SE\|GE\|IEA\)"
syn match x12Segments "^\([A-Z][A-Z0-9]\{1,2\}\)"

let b:current_syntax = "x12"

hi def link x12ElmDelimiter Operator
hi def link x12SubDelimiter Special
hi def link x12SegDelimiter SpecialChar
hi def link x12Envelope     Keyword
hi def link x12Segments     Function
