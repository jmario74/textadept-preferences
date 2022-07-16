-- Import session on file open startup
local function import_default_session()
  textadept.session.load(_USERHOME..'/session')
  for i = 1, #arg do
    local filename = lfs.abspath(arg[i], arg[-1])
    if lfs.attributes(filename) then -- not a switch
      io.open_file(filename)
    end
  end
end
events.connect(events.VIEW_NEW,import_default_session)

-- some local colors
local white = 0xFFFFFF
local light_black = 0x333333
local black = 0x1A1A1A
local dark_green = 0x1A661A

-- Adjust the default theme's font and size.
if not CURSES then
  view:set_theme('dark', {font = 'Monospaced Regular', size = 18})
end

-- Highlight all occurrences of the selected word.
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
view.indic_fore[textadept.editing.INDIC_HIGHLIGHT] = white
view.indic_alpha[textadept.editing.INDIC_HIGHLIGHT] = 0

-- Indent guide color
lexer.styles.indent_guide = {fore = dark_green}

-- Highlighted selected word
view.element_color[view.ELEMENT_SELECTION_BACK] = light_black
--view.element_color[view.ELEMENT_SELECTION_TEXT] = white
view.element_color[view.ELEMENT_CARET_LINE_BACK] = black
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = black

-- Caret
view.element_color[view.ELEMENT_CARET] = white
view.caret_line_back = light_black
view.caret_line_frame = 2

-- bracket match
view.indic_fore[textadept.editing.INDIC_BRACEMATCH] = white

-- Default indentation settings for all buffers.
buffer.use_tabs = true
buffer.tab_width = 4

-- Always use PEP-8 indentation style for Python files.
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'python' then return end
  buffer.use_tabs = false
  buffer.tab_width = 4
end)

-- no scroll bars
view.v_scroll_bar = false
view.h_scroll_bar = false

-- wrap indents
view.wrap_indent_mode = view.WRAPINDENT_DEEPINDENT
view.wrap_mode = view.WRAP_WORD
--view.wrap_visual_flags = view.WRAPVISUALFLAG_START
--view.wrap_visual_flags_location = view.WRAPVISUALFLAGLOC_START_BY_TEXT

-- toggle line numbers
--local margin_widths = {}
local function hide_margins()
	for i = 1, view.margins do
		if view.margin_width_n[i] > 0 then
			--margin_widths[i] = view.margin_width_n[i] 
			view.margin_width_n[i] = 0
			view.margins = 0
		--else
			--view.margin_width_n[i] = margin_widths[i]  or 0
		end
	end
	print(buffer.filename)
end
keys['ctrl+alt+m'] = hide_margins
local function show_margins()
	view.margins = 5
	reset()
end
keys['ctrl+alt+n'] = show_margins

-- Copy file path to clipboard
local function copy_file_path()
	--ui.print(buffer.filename)
	ui.clipboard_text = buffer.filename
end
keys['ctrl+alt+c'] = copy_file_path
