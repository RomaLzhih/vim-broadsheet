" =============================================================================
" broadsheet.vim — shared core for the newspaper colorscheme family
" =============================================================================
"
" Every highlight-group assignment for the family lives here.  A theme is just a
" palette: colors/coffee.vim and colors/graphite.vim each define one and hand it
" to broadsheet#apply().  Fix a group here and both themes inherit the fix.
"
" Design — "Broadsheet":  markup recedes, prose advances.
"
"   Braces, delimiters and hairlines fall back to a faint gray; the text inside
"   {...} keeps full ink and reads as prose.  Commands are the one emphatic
"   thing on the page.  Hierarchy is carried by weight and hue separation, not
"   saturation.
"
" Palette contract — a theme must supply every key below as [gui_hex, cterm256].
" The names are ROLES, not colors: `cmd` is press-red in coffee and oxblood in
" graphite; `math` is ochre in one and brass in the other.
"
"   bg  bg_alt  bg_soft  bg_deep        the paper stock, four steps
"   ink  ink_soft  ink_mute  ink_faint  the ink, four weights.  ink_faint is
"                                       deliberately sub-AA — it is for brace
"                                       glyphs and hairline rules, never text.
"
"   cmd    commands, headings       alert  errors, H3
"   ref    refs, citations, links   env    environment names, preproc
"   verb   strings, verbatim        math   math zones, numbers
"   opt    [options], #params       quote  blockquotes, types, H4-H6
"
"   marker  marker_hot  on_hot      search marks; on_hot is the foreground laid
"                                   over marker_hot, and flips per edition so
"                                   the live match stays the brightest mark
"   diff_add  diff_chg  diff_del  diff_txt
" =============================================================================

let s:none = ['NONE', 'NONE']
let s:p = {}

function! s:c(name) abort
  return empty(a:name) ? s:none : get(s:p, a:name, s:none)
endfunction

" Strip `bold` from an attribute list when g:broadsheet_bold is off, leaving any
" other attributes intact ('bold,italic' -> 'italic', 'bold' -> 'NONE').
" Applied in one place so every group honours the option automatically.
function! s:attr(attr) abort
  if get(g:, 'broadsheet_bold', 1) || a:attr ==# 'NONE'
    return a:attr
  endif
  let l:a = substitute(a:attr, '\C\<bold\>', '', 'g')
  let l:a = substitute(l:a, ',\{2,}', ',', 'g')
  let l:a = substitute(l:a, '^,\|,$', '', 'g')
  return empty(l:a) ? 'NONE' : l:a
endfunction

" s:hi(group, fg, bg [, attr [, guisp]])   — '' means NONE.
function! s:hi(group, fg, bg, ...) abort
  let l:attr = s:attr((a:0 > 0 && !empty(a:1)) ? a:1 : 'NONE')
  let l:fg = s:c(a:fg)
  let l:bg = s:c(a:bg)
  " cterm has no undercurl; degrade to a plain underline there.
  let l:cattr = substitute(l:attr, 'undercurl', 'underline', 'g')
  let l:cmd = printf(
        \ 'highlight %s guifg=%s guibg=%s gui=%s ctermfg=%s ctermbg=%s cterm=%s',
        \ a:group, l:fg[0], l:bg[0], l:attr, l:fg[1], l:bg[1], l:cattr)
  if a:0 > 1 && !empty(a:2)
    let l:cmd .= ' guisp=' . s:c(a:2)[0]
  endif
  execute l:cmd
endfunction

" Apply a palette.  Called by each colors/*.vim after it picks its edition.
function! broadsheet#apply(name, palette, ansi) abort
  hi clear
  if exists('syntax_on')
    syntax reset
  endif
  let g:colors_name = a:name
  let s:p = a:palette

  " ---------------------------------------------------------------------------
  " Editor chrome
  " ---------------------------------------------------------------------------

  call s:hi('Normal',        'ink',       'bg')
  call s:hi('NormalNC',      'ink',       'bg')
  call s:hi('NormalFloat',   'ink',       'bg_alt')
  call s:hi('Cursor',        'bg',        'ink')
  call s:hi('lCursor',       'bg',        'cmd')
  call s:hi('CursorIM',      'bg',        'ink')
  call s:hi('TermCursor',    'bg',        'ink')

  " Line-wise highlights are background-only so syntax colors survive underneath.
  call s:hi('CursorLine',    '',          'bg_alt')
  call s:hi('CursorColumn',  '',          'bg_alt')
  call s:hi('ColorColumn',   '',          'bg_alt')
  call s:hi('Visual',        '',          'bg_soft')
  call s:hi('VisualNOS',     '',          'bg_soft')
  call s:hi('QuickFixLine',  '',          'bg_soft')

  call s:hi('LineNr',        'ink_faint', '')
  call s:hi('LineNrAbove',   'ink_faint', '')
  call s:hi('LineNrBelow',   'ink_faint', '')
  call s:hi('CursorLineNr',  'cmd',   'bg_alt',  'bold')
  call s:hi('SignColumn',    'ink_mute',  '')
  call s:hi('FoldColumn',    'ink_faint', '')
  call s:hi('Folded',        'ink_mute',  'bg_alt',  'italic')

  " Hairline rules — the thin gray keylines between columns of a page.
  call s:hi('VertSplit',     'bg_deep',   'bg')
  call s:hi('WinSeparator',  'bg_deep',   'bg')
  call s:hi('NonText',       'ink_faint', '')
  call s:hi('EndOfBuffer',   'bg',        '')
  call s:hi('SpecialKey',    'ink_faint', '')
  call s:hi('Conceal',       'ink_faint', '')
  call s:hi('Whitespace',    'ink_faint', '')

  " A highlighter pen drawn across the page.  `on_hot` flips per edition: ink over
  " amber on paper, but paper-stock over amber at night, so the live match stays
  " the brightest mark on the page either way.
  call s:hi('Search',        'ink',       'marker')
  call s:hi('IncSearch',     'on_hot',    'marker_hot', 'bold')
  call s:hi('CurSearch',     'on_hot',    'marker_hot', 'bold')
  call s:hi('MatchParen',    'cmd',   'bg_soft',    'bold')

  " The folio line — a solid ink bar across the foot of the page.
  " The inactive bar recedes by going pale, not by dimming its text — the filename
  " in a background split still has to be legible (ink_mute here fails AA on
  " bg_deep, so the secondary ink is used instead).
  call s:hi('StatusLine',    'bg',        'ink',     'bold')
  call s:hi('StatusLineNC',  'ink_soft',  'bg_deep')
  call s:hi('StatusLineTerm',   'bg',     'ink',     'bold')
  call s:hi('StatusLineTermNC', 'ink_soft', 'bg_deep')
  call s:hi('TabLine',       'ink_soft',  'bg_deep')
  call s:hi('TabLineSel',    'ink',       'bg',      'bold')
  call s:hi('TabLineFill',   'ink_faint', 'bg_deep')
  call s:hi('ToolbarLine',   '',          'bg_deep')
  call s:hi('ToolbarButton', 'ink',       'bg_soft', 'bold')

  " The selected completion row is a paper step, not a solid accent block: a
  " filled navy bar is the heaviest thing on an otherwise light page and reads
  " as a hole punched in it.  bg_deep is the darkest stock in the palette, so
  " the row still separates clearly from Pmenu's bg_alt while staying paper.
  " The fuzzy-matched characters keep the accent, which is what needs to pop.
  call s:hi('Pmenu',         'ink_soft',  'bg_alt')
  call s:hi('PmenuSel',      'ink',       'bg_deep', 'bold')
  call s:hi('PmenuSbar',     '',          'bg_soft')
  call s:hi('PmenuThumb',    '',          'ink_faint')
  call s:hi('PmenuKind',     'env',       'bg_alt')
  call s:hi('PmenuKindSel',  'env',       'bg_deep', 'bold')
  call s:hi('PmenuExtra',    'ink_mute',  'bg_alt')
  call s:hi('PmenuExtraSel', 'ink_soft',  'bg_deep')
  call s:hi('PmenuMatch',    'cmd',       'bg_alt',  'bold')
  call s:hi('PmenuMatchSel', 'cmd',       'bg_deep', 'bold')
  call s:hi('WildMenu',      'ink',       'bg_deep', 'bold')

  call s:hi('Directory',     'ref',      '',        'bold')
  call s:hi('Title',         'cmd',   '',        'bold')
  call s:hi('Question',      'env', '',        'bold')
  call s:hi('ModeMsg',       'ink',       '',        'bold')
  call s:hi('MoreMsg',       'env', '',        'bold')
  call s:hi('ErrorMsg',      'alert',       '',        'bold')
  call s:hi('WarningMsg',    'math',     '',        'bold')
  call s:hi('debugPC',       '',          'bg_soft')
  call s:hi('debugBreakpoint', 'alert',     '',        'bold')

  " ---------------------------------------------------------------------------
  " Diff — proofreading marks, washes rather than blocks
  " ---------------------------------------------------------------------------

  call s:hi('DiffAdd',     '',      'diff_add')
  call s:hi('DiffChange',  '',      'diff_chg')
  call s:hi('DiffDelete',  'alert',   'diff_del')
  call s:hi('DiffText',    '',      'diff_txt', 'bold')
  call s:hi('Added',       'verb', '')
  call s:hi('Changed',     'ref',  '')
  call s:hi('Removed',     'alert',   '')

  " ---------------------------------------------------------------------------
  " Spell — undercurl only.  A background fill would wreck the page.
  " ---------------------------------------------------------------------------

  call s:hi('SpellBad',   '', '', 'undercurl', 'alert')
  call s:hi('SpellCap',   '', '', 'undercurl', 'ref')
  call s:hi('SpellRare',  '', '', 'undercurl', 'opt')
  call s:hi('SpellLocal', '', '', 'undercurl', 'env')

  " ---------------------------------------------------------------------------
  " Standard syntax groups — these carry embedded code (lstlisting, md fences)
  " ---------------------------------------------------------------------------

  call s:hi('Comment',        'ink_mute',  '', 'italic')
  call s:hi('Constant',       'opt',      '')
  call s:hi('String',         'verb',     '')
  call s:hi('Character',      'verb',     '')
  call s:hi('Number',         'math',     '')
  call s:hi('Boolean',        'math',     '')
  call s:hi('Float',          'math',     '')
  call s:hi('Identifier',     'ink_soft',  '')
  call s:hi('Function',       'ref',      '', 'bold')
  call s:hi('Statement',      'cmd',   '', 'bold')
  call s:hi('Conditional',    'cmd',   '')
  call s:hi('Repeat',         'cmd',   '')
  call s:hi('Label',          'cmd',   '')
  call s:hi('Operator',       'ink_soft',  '')
  call s:hi('Keyword',        'cmd',   '', 'bold')
  call s:hi('Exception',      'cmd',   '', 'bold')
  call s:hi('PreProc',        'env', '')
  call s:hi('Include',        'env', '')
  call s:hi('Define',         'env', '')
  call s:hi('Macro',          'env', '')
  call s:hi('PreCondit',      'env', '')
  call s:hi('Type',           'quote',     '')
  call s:hi('StorageClass',   'quote',     '')
  call s:hi('Structure',      'quote',     '')
  call s:hi('Typedef',        'quote',     '')
  call s:hi('Special',        'math',     '')
  call s:hi('SpecialChar',    'math',     '')
  call s:hi('Tag',            'ref',      '')
  call s:hi('Delimiter',      'ink_faint', '')
  call s:hi('SpecialComment', 'ink_mute',  '', 'bold,italic')
  call s:hi('Debug',          'alert',       '')
  call s:hi('Underlined',     'ref',      '', 'underline')
  call s:hi('Ignore',         'ink_faint', '')
  call s:hi('Error',          'alert',       '', 'bold')
  call s:hi('Todo',           'ink',       'marker', 'bold')
  call s:hi('Property',       'ref',      '')

  " =============================================================================
  " LaTeX — vimtex
  " =============================================================================
  " vimtex declares its groups with `highlight def link` (core.vim:759-932), so
  " explicit definitions here win.  The child links are re-stated below because
  " `hi clear` on a colorscheme reload wipes vimtex's own defaults until the
  " syntax script is re-sourced.
  " ---------------------------------------------------------------------------

  " -- root groups ------------------------------------------------------------
  call s:hi('texCmd',            'cmd',   '', 'bold')     " every \command
  call s:hi('texCmdType',        'cmd',   '')             " \large, \bfseries
  call s:hi('texDelim',          'ink_faint', '')             " { } — recede
  call s:hi('texArg',            'ink',       '')             " prose inside {}
  call s:hi('texOpt',            'opt',      '', 'italic')   " [options]
  call s:hi('texOptSep',         'ink_faint', '')
  call s:hi('texParm',           'opt',      '', 'bold')     " #1 #2
  call s:hi('texComment',        'ink_mute',  '', 'italic')
  call s:hi('texLength',         'math',     '')
  call s:hi('texSpecialChar',    'ink_faint', '')
  call s:hi('texSymbol',         'ink_faint', '')

  " Section titles read as headlines, not as strings.
  call s:hi('texPartArgTitle',   'ink',       '', 'bold')
  call s:hi('texTitleArg',       'ink',       '', 'bold')

  " Environment names get their own hue, distinct from the \begin that opens it.
  call s:hi('texEnvArgName',     'env', '', 'bold')
  call s:hi('texMathEnvArgName', 'env', '', 'bold')

  " Cross-references and citations behave like hyperlinks in print.
  call s:hi('texRefArg',         'ref',      '', 'underline')
  call s:hi('texFileArg',        'ref',      '')
  call s:hi('texHrefArgLink',    'ref',      '', 'underline')
  call s:hi('texHrefArgText',    'ink',       '')

  " The math band — one warm hue for everything between the dollars.
  call s:hi('texMathZone',       'math',     '')
  call s:hi('texMathCmd',        'math',     '', 'bold')
  call s:hi('texMathCmdText',    'math',     '')
  call s:hi('texMathSymbol',     'math',     '')
  call s:hi('texMathDelim',      'math',     '')
  call s:hi('texMathOper',       'ink_soft',  '')

  " Verbatim / listings sit on tinted stock.
  call s:hi('texZone',           'verb',     'bg_alt')

  " Diagnostics
  call s:hi('VimtexTodo',        'ink',       'marker', 'bold')
  call s:hi('VimtexWarning',     'math',     '', 'bold')
  call s:hi('VimtexError',       'alert',       '', 'bold')
  call s:hi('VimtexFatal',       'alert',       '', 'bold')
  call s:hi('texError',          'alert',       '', 'undercurl', 'alert')
  call s:hi('VimtexPopupContent',     'ink',   'bg_alt')
  call s:hi('VimtexPopupPrompt',      'cmd', 'bg_alt', 'bold')
  call s:hi('VimtexPopupPromptInput', 'ref',  'bg_alt')
  call s:hi('VimtexImgBorder',        'ink_faint', '')

  " -- content styling --------------------------------------------------------
  " No foreground is set: \textbf{...} content stays ink and reads as prose, it
  " just gains weight.  vimtex sets these with a bare `highlight def`
  " (core.vim:786-794) which `hi clear` erases, so they are re-stated here.
  " Routed through s:attr() rather than written literally, so that disabling
  " g:broadsheet_bold also drops the weight from \textbf{} content.
  for [s:g, s:a] in [
        \ ['texStyleBold',          'bold'],
        \ ['texStyleItal',          'italic'],
        \ ['texStyleUnder',         'underline'],
        \ ['texStyleBoth',          'bold,italic'],
        \ ['texStyleBoldUnder',     'bold,underline'],
        \ ['texStyleItalUnder',     'italic,underline'],
        \ ['texStyleBoldItalUnder', 'bold,italic,underline'],
        \ ['texMathStyleBold',      'bold'],
        \ ['texMathStyleItal',      'italic'],
        \ ]
    execute printf('highlight %s gui=%s cterm=%s', s:g, s:attr(s:a), s:attr(s:a))
  endfor
  unlet! s:g s:a

  " -- child links (restated; see note above) ---------------------------------
  highlight! link texCmdAccent         texCmd
  highlight! link texCmdAuthor         texCmd
  highlight! link texCmdBib            texCmd
  highlight! link texCmdBibitem        texCmd
  highlight! link texCmdClass          texCmd
  highlight! link texCmdConditional    texCmd
  highlight! link texCmdDef            texCmd
  highlight! link texCmdE3             texCmd
  highlight! link texCmdEnv            texCmd
  highlight! link texCmdEnvM           texCmd
  highlight! link texCmdFootnote       texCmd
  highlight! link texCmdInput          texCmd
  highlight! link texCmdItem           texCmd
  highlight! link texCmdLet            texCmd
  highlight! link texCmdMath           texCmd
  highlight! link texCmdMathEnv        texCmd
  highlight! link texCmdNew            texCmd
  highlight! link texCmdNewcmd         texCmd
  highlight! link texCmdNewenv         texCmd
  highlight! link texCmdNewthm         texCmd
  highlight! link texCmdPackage        texCmd
  highlight! link texCmdParbox         texCmd
  highlight! link texCmdPart           texCmd
  highlight! link texCmdRef            texCmd
  highlight! link texCmdRefConcealed   texCmd
  highlight! link texCmdStyleBold      texCmd
  highlight! link texCmdStyleBoldItal  texCmd
  highlight! link texCmdStyleItal      texCmd
  highlight! link texCmdStyleItalBold  texCmd
  highlight! link texCmdTitle          texCmd
  highlight! link texCmdVerb           texCmd
  highlight! link texArgNew            texCmd
  highlight! link texCmdSize           texCmdType
  highlight! link texCmdStyle          texCmdType
  highlight! link texCmdGreek          texMathCmd
  highlight! link texCmdLigature       texSpecialChar

  highlight! link texPartConcealed     texCmd
  highlight! link texPartConcArgTitle  texPartArgTitle
  highlight! link texNewenvArgName     texEnvArgName
  highlight! link texEnvMArgName       texEnvArgName

  highlight! link texBibitemArg        texArg
  highlight! link texConcealedArg      texArg
  highlight! link texConditionalArg    texArg
  highlight! link texNewthmArgName     texArg
  highlight! link texFilesArg          texFileArg
  highlight! link texDefArgName        texArgNew
  highlight! link texLetArgName        texArgNew
  highlight! link texNewcmdArgName     texArgNew

  highlight! link texAuthorOpt         texOpt
  highlight! link texBibitemOpt        texOpt
  highlight! link texEnvOpt            texOpt
  highlight! link texFileOpt           texOpt
  highlight! link texItemLabel         texOpt
  highlight! link texMathArrayArg      texOpt
  highlight! link texNewcmdOpt         texOpt
  highlight! link texNewenvOpt         texOpt
  highlight! link texRefOpt            texOpt
  highlight! link texTabularArg        texOpt
  highlight! link texTabularCol        texOpt
  highlight! link texTheoremEnvOpt     texOpt

  highlight! link texDefParm           texParm
  highlight! link texNewcmdParm        texParm
  highlight! link texNewenvParm        texParm

  highlight! link texRefArgs           texRefArg
  highlight! link texRefConcealedArg   texRefArg
  highlight! link texRefConcealedPArg  texRefArg
  highlight! link texRefConcealedDelim texDelim
  highlight! link texMathDelimZone     texDelim
  highlight! link texE3Delim           texDelim

  highlight! link texMathArg           texMathZone
  highlight! link texMathGroup         texMathZone
  highlight! link texMathSub           texMathZone
  highlight! link texMathSuper         texMathZone
  highlight! link texMathZoneEnv       texMathZone
  highlight! link texMathZoneEnvStarred texMathZone
  highlight! link texMathZoneEnsured   texMathZone
  highlight! link texMathZoneLI        texMathZone
  highlight! link texMathZoneLD        texMathZone
  highlight! link texMathZoneTI        texMathZone
  highlight! link texMathZoneTD        texMathZone
  highlight! link texMathCmdStyle      texMathCmd
  highlight! link texMathCmdStyleBold  texMathCmd
  highlight! link texMathCmdStyleItal  texMathCmd
  highlight! link texMathDelimMod      texMathDelim
  highlight! link texMathSuperSub      texMathOper

  highlight! link texVerbZone          texZone
  highlight! link texVerbZoneInline    texZone
  highlight! link texLstZone           texZone
  highlight! link texMintedZone        texZone

  highlight! link texCommentAcronym    texComment
  highlight! link texCommentFalse      texComment
  highlight! link texCommentURL        texComment
  highlight! link texCommentTodo       Todo
  highlight! link texTabularChar       texSymbol
  highlight! link texBoxOptPosVal      texSymbol
  highlight! link texOptEqual          texSymbol
  highlight! link texMathError         texError
  highlight! link texGroupError        texError

  " -- BibTeX -----------------------------------------------------------------
  call s:hi('bibType',     'cmd',   '', 'bold')
  call s:hi('bibEntryKw',  'env', '')
  call s:hi('bibKey',      'ref',      '', 'bold')
  call s:hi('bibField',    'ink',       '')
  call s:hi('bibVariable', 'opt',      '')
  call s:hi('bibComment',  'ink_mute',  '', 'italic')
  call s:hi('bibNSEntryKw','env', '')
  call s:hi('bibUnescapedSpecial', 'alert', '', 'undercurl', 'alert')

  " =============================================================================
  " Markdown
  " =============================================================================
  " Covers preservim/vim-markdown (mkd*/html*) and Vim's built-in syntax
  " (markdown*), so the page looks right with either active.
  " ---------------------------------------------------------------------------

  " A descending headline hierarchy — the same rule a masthead follows.
  call s:hi('htmlH1', 'cmd',  '', 'bold')
  call s:hi('htmlH2', 'cmd',  '', 'bold')
  call s:hi('htmlH3', 'alert',      '', 'bold')
  call s:hi('htmlH4', 'quote',    '', 'bold')
  call s:hi('htmlH5', 'quote',    '', 'bold')
  call s:hi('htmlH6', 'ink_mute', '', 'bold')

  " The '#' glyphs themselves recede, exactly as braces do in LaTeX.
  call s:hi('mkdHeading',        'ink_faint', '')
  call s:hi('mkdDelimiter',      'ink_faint', '')
  call s:hi('mkdRule',           'ink_faint', '')        " a hairline rule
  call s:hi('mkdLineBreak',      '',          'bg_soft')

  call s:hi('mkdBold',           'ink',       '', 'bold')
  call s:hi('mkdItalic',         'ink_soft',  '', 'italic')
  call s:hi('mkdBoldItalic',     'ink',       '', 'bold,italic')
  call s:hi('htmlBold',          'ink',       '', 'bold')
  call s:hi('htmlItalic',        'ink_soft',  '', 'italic')
  call s:hi('htmlBoldItalic',    'ink',       '', 'bold,italic')
  call s:hi('htmlUnderline',     '',          '', 'underline')
  call s:hi('htmlStrike',        'ink_faint', '', 'strikethrough')
  call s:hi('mkdStrike',         'ink_faint', '', 'strikethrough')

  call s:hi('mkdCode',           'verb',     'bg_alt')
  call s:hi('mkdCodeStart',      'ink_faint', 'bg_alt')
  call s:hi('mkdCodeEnd',        'ink_faint', 'bg_alt')
  call s:hi('mkdCodeDelimiter',  'ink_faint', 'bg_alt')
  call s:hi('mkdSnippetInclude', 'ink_faint', 'bg_alt')

  call s:hi('mkdListItem',         'cmd',   '', 'bold')
  call s:hi('mkdListItemLine',     'ink',       '')
  call s:hi('mkdListItemCheckbox', 'env', '', 'bold')

  call s:hi('mkdLink',           'ref',   '')
  call s:hi('mkdURL',            'ref',   '', 'underline')
  call s:hi('mkdInlineURL',      'ref',   '', 'underline')
  call s:hi('mkdLinkDef',        'ref',   '')
  call s:hi('mkdLinkDefTarget',  'ref',   '', 'underline')
  call s:hi('mkdLinkTitle',      'quote',  '', 'italic')
  call s:hi('htmlLink',          'ref',   '', 'underline')

  call s:hi('mkdBlockquote',     'quote',  '', 'italic')  " a pull-quote
  call s:hi('mkdMath',           'math',  '')
  call s:hi('mkdFootnote',       'opt',   '')
  call s:hi('mkdFootnotes',      'opt',   '')
  call s:hi('mkdID',             'opt',   '')
  call s:hi('mkdString',         'verb',  '')
  call s:hi('htmlString',        'verb',  '')

  " Built-in markdown syntax, same treatment.
  highlight! link markdownH1                  htmlH1
  highlight! link markdownH2                  htmlH2
  highlight! link markdownH3                  htmlH3
  highlight! link markdownH4                  htmlH4
  highlight! link markdownH5                  htmlH5
  highlight! link markdownH6                  htmlH6
  highlight! link markdownHeadingDelimiter    mkdHeading
  highlight! link markdownHeadingRule         mkdRule
  highlight! link markdownRule                mkdRule
  highlight! link markdownBold                mkdBold
  highlight! link markdownItalic              mkdItalic
  highlight! link markdownBoldItalic          mkdBoldItalic
  highlight! link markdownCode                mkdCode
  highlight! link markdownCodeBlock           mkdCode
  highlight! link markdownCodeDelimiter       mkdCodeDelimiter
  highlight! link markdownListMarker          mkdListItem
  highlight! link markdownOrderedListMarker   mkdListItem
  highlight! link markdownBlockquote          mkdBlockquote
  highlight! link markdownLinkText            mkdLink
  highlight! link markdownUrl                 mkdURL
  highlight! link markdownLinkDelimiter       mkdDelimiter
  highlight! link markdownLinkTextDelimiter   mkdDelimiter
  highlight! link markdownUrlDelimiter        mkdDelimiter
  highlight! link markdownUrlTitleDelimiter   mkdDelimiter
  highlight! link markdownIdDeclaration       mkdID
  highlight! link markdownId                  mkdID
  highlight! link markdownFootnote            mkdFootnote
  highlight! link markdownFootnoteDefinition  mkdFootnote
  highlight! link markdownEscape              mkdDelimiter
  highlight! link markdownError               Normal

  " =============================================================================
  " Other prose filetypes
  " =============================================================================

  " -- reStructuredText -------------------------------------------------------
  call s:hi('rstSections',              'cmd',   '', 'bold')
  call s:hi('rstTransition',            'ink_faint', '')
  call s:hi('rstDirective',             'env', '', 'bold')
  call s:hi('rstLiteralBlock',          'verb',     'bg_alt')
  call s:hi('rstInlineLiteral',         'verb',     'bg_alt')
  call s:hi('rstEmphasis',              'ink_soft',  '', 'italic')
  call s:hi('rstStrongEmphasis',        'ink',       '', 'bold')
  call s:hi('rstHyperlinkTarget',       'ref',      '', 'underline')
  call s:hi('rstStandaloneHyperlink',   'ref',      '', 'underline')
  call s:hi('rstInterpretedTextOrHyperlinkReference', 'ref', '')
  call s:hi('rstExplicitMarkup',        'ink_faint', '')
  call s:hi('rstComment',               'ink_mute',  '', 'italic')
  call s:hi('rstCitation',              'opt',      '')
  call s:hi('rstFootnote',              'opt',      '')

  " -- git commit -------------------------------------------------------------
  call s:hi('gitcommitSummary',       'ink',       '', 'bold')
  call s:hi('gitcommitOverflow',      'alert',       '')
  call s:hi('gitcommitComment',       'ink_mute',  '', 'italic')
  call s:hi('gitcommitBranch',        'opt',      '', 'bold')
  call s:hi('gitcommitOnBranch',      'ink_mute',  '')
  call s:hi('gitcommitHeader',        'ink_soft',  '', 'bold')
  call s:hi('gitcommitSelectedType',  'verb',     '')
  call s:hi('gitcommitSelectedFile',  'verb',     '', 'bold')
  call s:hi('gitcommitDiscardedType', 'alert',       '')
  call s:hi('gitcommitDiscardedFile', 'alert',       '', 'bold')
  call s:hi('gitcommitUntrackedFile', 'math',     '')
  call s:hi('gitcommitUnmergedFile',  'alert',       '', 'bold')
  call s:hi('gitcommitFile',          'ink',       '', 'bold')

  " -- vim help ---------------------------------------------------------------
  call s:hi('helpHeadline',      'cmd',   '', 'bold')
  call s:hi('helpSectionDelim',  'ink_faint', '')
  call s:hi('helpHyperTextJump', 'ref',      '', 'underline')
  call s:hi('helpHyperTextEntry','env', '', 'bold')
  call s:hi('helpOption',        'opt',      '')
  call s:hi('helpCommand',       'verb',     '')
  call s:hi('helpExample',       'verb',     '')
  call s:hi('helpNote',          'math',     '', 'bold')
  call s:hi('helpSpecial',       'quote',     '')
  call s:hi('helpBar',           'ink_faint', '')
  call s:hi('helpStar',          'ink_faint', '')
  call s:hi('helpURL',           'ref',      '', 'underline')

  " -- mail -------------------------------------------------------------------
  call s:hi('mailHeader',    'ink_mute',  '')
  call s:hi('mailHeaderKey', 'ink_soft',  '', 'bold')
  call s:hi('mailSubject',   'ink',       '', 'bold')
  call s:hi('mailURL',       'ref',      '', 'underline')
  call s:hi('mailEmail',     'ref',      '', 'underline')
  call s:hi('mailQuoted1',   'env', '')
  call s:hi('mailQuoted2',   'opt',      '')
  call s:hi('mailQuoted3',   'quote',     '')
  call s:hi('mailQuoted4',   'ref',      '')
  call s:hi('mailQuoted5',   'verb',     '')
  call s:hi('mailQuoted6',   'math',     '')

  " -- vim-pandoc (inert unless the plugin is installed) ----------------------
  highlight! link pandocEmphasis            mkdItalic
  highlight! link pandocStrong              mkdBold
  highlight! link pandocStrongEmphasis      mkdBoldItalic
  highlight! link pandocBlockQuote          mkdBlockquote
  highlight! link pandocCodeBlock           mkdCode
  highlight! link pandocVerbatimInline      mkdCode
  highlight! link pandocLinkText            mkdLink
  highlight! link pandocLinkURL             mkdURL
  highlight! link pandocCitekey             mkdLink
  highlight! link pandocHeading             htmlH1
  highlight! link pandocTitleBlock          htmlH1
  highlight! link pandocListMarker          mkdListItem
  highlight! link pandocFootnoteID          mkdFootnote
  highlight! link pandocTableDelims         mkdDelimiter

  " =============================================================================
  " Plugins
  " =============================================================================

  " -- coc.nvim ---------------------------------------------------------------
  call s:hi('CocErrorSign',      'alert',       '', 'bold')
  call s:hi('CocWarningSign',    'math',     '', 'bold')
  call s:hi('CocInfoSign',       'ref',      '', 'bold')
  call s:hi('CocHintSign',       'env', '', 'bold')
  call s:hi('CocErrorHighlight',   '', '', 'undercurl', 'alert')
  call s:hi('CocWarningHighlight', '', '', 'undercurl', 'math')
  call s:hi('CocInfoHighlight',    '', '', 'undercurl', 'ref')
  call s:hi('CocHintHighlight',    '', '', 'undercurl', 'env')
  call s:hi('CocErrorFloat',     'alert',       'bg_alt')
  call s:hi('CocWarningFloat',   'math',     'bg_alt')
  call s:hi('CocInfoFloat',      'ref',      'bg_alt')
  call s:hi('CocHintFloat',      'env', 'bg_alt')
  call s:hi('CocFloating',       'ink_soft',  'bg_alt')
  call s:hi('CocFloatDividingLine', 'ink_faint', 'bg_alt')
  call s:hi('CocFloatActive',    'cmd',   'bg_alt', 'bold')
  " coc drives its own completion popup off CocMenuSel; keep it in step with
  " PmenuSel above -- a paper step rather than a filled accent block.
  call s:hi('CocMenuSel',        'ink',       'bg_deep', 'bold')
  call s:hi('CocSearch',         'cmd',   '',       'bold')
  call s:hi('CocPumSearch',      'cmd',   '',       'bold')
  call s:hi('CocPumMenu',        'ink_soft',  'bg_alt')
  call s:hi('CocPumDetail',      'ink_mute',  'bg_alt')
  call s:hi('CocPumShortcut',    'ink_mute',  'bg_alt')
  call s:hi('CocHighlightText',  '',          'bg_soft')
  call s:hi('CocHighlightRead',  '',          'bg_soft')
  call s:hi('CocHighlightWrite', '',          'bg_soft', 'bold')
  call s:hi('CocSelectedText',   'cmd',   '',        'bold')
  call s:hi('CocCodeLens',       'ink_faint', '',        'italic')
  call s:hi('CocInlayHint',      'ink_faint', '',        'italic')
  call s:hi('CocFadeOut',        'ink_faint', '')
  call s:hi('CocUnusedHighlight','ink_faint', '')
  call s:hi('CocDeprecatedHighlight', 'ink_mute', '', 'strikethrough')
  call s:hi('CocListMode',       'bg',        'ink',     'bold')
  call s:hi('CocListPath',       'ink_mute',  '')
  call s:hi('CocSymbolDefault',  'ink_soft',  '')
  call s:hi('CocNotificationProgress', 'env', '')

  " -- fzf --------------------------------------------------------------------
  call s:hi('fzf1', 'cmd',   'bg_alt', 'bold')
  call s:hi('fzf2', 'env', 'bg_alt')
  call s:hi('fzf3', 'ink_mute',  'bg_alt')

  " -- vim-startify -----------------------------------------------------------
  call s:hi('StartifyHeader',  'cmd',   '', 'bold')
  call s:hi('StartifySection', 'env', '', 'bold')
  call s:hi('StartifyBracket', 'ink_faint', '')
  call s:hi('StartifyNumber',  'cmd',   '', 'bold')
  call s:hi('StartifyPath',    'ink_mute',  '')
  call s:hi('StartifySlash',   'ink_faint', '')
  call s:hi('StartifyFile',    'ink',       '')
  call s:hi('StartifySpecial', 'ink_mute',  '', 'italic')
  call s:hi('StartifyFooter',  'ink_faint', '', 'italic')

  " -- vim-easymotion ---------------------------------------------------------
  call s:hi('EasyMotionTarget',       'cmd', '', 'bold')
  call s:hi('EasyMotionTarget2First', 'cmd', '', 'bold')
  call s:hi('EasyMotionTarget2Second','opt',    '', 'bold')
  call s:hi('EasyMotionShade',        'ink_faint', '')
  call s:hi('EasyMotionIncSearch',    'on_hot',  'marker_hot', 'bold')

  " -- marks & bookmarks ------------------------------------------------------
  call s:hi('SignatureMarkText',   'opt',    '', 'bold')
  call s:hi('SignatureMarkerText', 'math',   '', 'bold')
  call s:hi('BookmarkSign',        'cmd', '', 'bold')
  call s:hi('BookmarkAnnotationSign', 'opt', '', 'bold')
  call s:hi('BookmarkLine',        '',        'bg_alt')
  call s:hi('BookmarkAnnotationLine', '',     'bg_alt')

  " -- vim-visual-multi -------------------------------------------------------
  call s:hi('VM_Mono',   'bg',      'cmd', 'bold')
  call s:hi('VM_Extend', '',        'bg_soft')
  call s:hi('VM_Cursor', 'bg',      'ref',    'bold')
  call s:hi('VM_Insert', 'bg',      'env')

  " -- vim-signify ------------------------------------------------------------
  " NOTE: .vimrc defines s:SignifyGitSignStyle() on `ColorScheme *`, which will
  " override these with its hardcoded gruvbox colors.  See the file's docs.
  call s:hi('SignifySignAdd',             'verb',     '', 'bold')
  call s:hi('SignifySignChange',          'ref',      '', 'bold')
  call s:hi('SignifySignDelete',          'alert',       '', 'bold')
  call s:hi('SignifySignChangeDelete',    'opt',      '', 'bold')
  call s:hi('SignifySignDeleteFirstLine', 'alert',       '', 'bold')
  call s:hi('SignifyLineAdd',             '',          'diff_add')
  call s:hi('SignifyLineChange',          '',          'diff_chg')
  call s:hi('SignifyLineDelete',          '',          'diff_del')

  " -- vim-floaterm -----------------------------------------------------------
  call s:hi('Floaterm',       'ink',       'bg')
  call s:hi('FloatermBorder', 'ink_faint', 'bg')
  call s:hi('FloatermNC',     'ink_mute',  'bg')

  " -- vim-which-key ----------------------------------------------------------
  call s:hi('WhichKey',          'cmd',   '', 'bold')
  call s:hi('WhichKeySeperator', 'ink_faint', '')
  call s:hi('WhichKeyGroup',     'env', '', 'bold')
  call s:hi('WhichKeyDesc',      'ink',       '')
  call s:hi('WhichKeyFloating',  'ink',       'bg_alt')

  " -- coc.nvim semantic tokens -----------------------------------------------
  " coc registers these with `hi default link`, so they only take if nothing set
  " them first -- and `hi clear` on a colorscheme switch wipes whatever was
  " there.  Stating them here means they are re-established on every load rather
  " than depending on coc re-running.
  "
  " The real names are CocSemType<Kind> / CocSemMod<Modifier>; a plain
  " `CocSemFunction` is from an older coc and is never consulted.
  "
  " coc would rather have the treesitter-style names (its map reads
  " ['@function', 'Function']), but Vim -- unlike Neovim -- only allows
  " alphanumerics and underscore in a highlight group name, so defining
  " `@function` or `@markup.link.url` raises W18 on every load.  They are
  " deliberately not defined here; coc's fallback to the classic groups below
  " is the correct path in Vim.
  for [s:k, s:v] in items({
        \ 'TypeNamespace': 'Include',     'TypeType': 'Type',
        \ 'TypeClass': 'Special',         'TypeEnum': 'Type',
        \ 'TypeInterface': 'Type',        'TypeStruct': 'Structure',
        \ 'TypeTypeParameter': 'Identifier', 'TypeParameter': 'Identifier',
        \ 'TypeVariable': 'Identifier',   'TypeProperty': 'Property',
        \ 'TypeEnumMember': 'Constant',   'TypeEvent': 'Keyword',
        \ 'TypeFunction': 'Function',     'TypeMethod': 'Function',
        \ 'TypeMacro': 'Define',          'TypeKeyword': 'Keyword',
        \ 'TypeModifier': 'StorageClass', 'TypeComment': 'Comment',
        \ 'TypeString': 'String',         'TypeNumber': 'Number',
        \ 'TypeBoolean': 'Boolean',       'TypeRegexp': 'String',
        \ 'TypeOperator': 'Operator',     'TypeDecorator': 'Identifier',
        \ 'ModDeprecated': 'CocDeprecatedHighlight',
        \ })
    execute 'highlight! link CocSem' . s:k . ' ' . s:v
  endfor
  unlet! s:k s:v

  " ---------------------------------------------------------------------------
  " :terminal / floaterm ANSI palette
  " ---------------------------------------------------------------------------

  let g:terminal_ansi_colors = a:ansi
  call s:hi('Terminal', 'ink', 'bg')
endfunction


" vim: set ft=vim ts=2 sw=2 et:
