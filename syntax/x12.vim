" Vim syntax file for ANSI X12 EDI
" Fixed version - escapes special regex chars in delimiters

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

let b:elmdl = escape(b:ISA[3:3], '\^$.*~[]>')
let b:subdl = escape(b:ISA[104:104], '\^$.*~[]>')

if strlen(b:ISA) > 105
  let b:segdl = escape(b:ISA[105:105], '\^$.*~[]>')
endif

exe 'syn match x12ElmDelimiter "\V' . b:elmdl . '"'
exe 'syn match x12SubDelimiter "\V' . b:subdl . '"'

if exists("b:segdl")
  exe 'syn match x12SegDelimiter "\V' . b:segdl . '"'
endif

syn match x12Envelope "^\(ISA\|GS\|ST\|SE\|GE\|IEA\)"
syn match x12Segments "^\([A-Z][A-Z0-9]\{1,2\}\)"

let b:current_syntax = "x12"

hi def link x12ElmDelimiter Delimiter
hi def link x12SubDelimiter Special
hi def link x12SegDelimiter Operator
hi def link x12Envelope     Keyword
hi def link x12Segments     Type
