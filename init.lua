-- When editor start by opening file in file manager import session & add opened file
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
--local file_menu = textadept.menu.menubar[_L['File']]
--table.insert(file_menu, #file_menu - 2,{'Import Default Session', import_default_session})

-- Some local colors (/themes/dark.lua)
local white = 0xFFFFFF
local light_black = 0x333333
local black = 0x1A1A1A
local dark_green = 0x1A661A
local red = 0x4D4D99
local teal = 0x99994D
local dark_pink = 0x6666B3
local dark_lavender = 0xB36666

-- Adjust the default theme's font and size.
if not CURSES then
  view:set_theme('dark', {font = 'Monospaced Regular', size = 18})
end

-- Display file path in status bar if OS is set to hide title bar of apps
local function statusbar_filename()
	ui.statusbar_text = buffer.filename
end
events.connect(events.UPDATE_UI,statusbar_filename)
-- Stabalize use of UPDATE_UI
events.emit(events.UPDATE_UI)

-- Find
ui.find.highlight_all_matches = true
view.indic_fore[ui.find.INDIC_FIND] = white
view.indic_alpha[ui.find.INDIC_FIND] = 0

-- Launch maximized
ui.maximized = true

-- Highlight all occurrences of the selected word.
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
view.indic_fore[textadept.editing.INDIC_HIGHLIGHT] = white
view.indic_alpha[textadept.editing.INDIC_HIGHLIGHT] = 0

-- Indent guide color
lexer.styles.indent_guide = {fore = dark_green}

-- Token styles, embedded (<?php)
lexer.styles.embedded = {fore = red}
lexer.styles.keyword = {fore = dark_lavender}
lexer.styles.number = {fore = dark_pink}
lexer.styles.variable = {fore = teal}

-- Highlighted selected word
view.element_color[view.ELEMENT_SELECTION_BACK] = light_black
--view.element_color[view.ELEMENT_SELECTION_TEXT] = white
view.element_color[view.ELEMENT_CARET_LINE_BACK] = black
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = black

-- Caret
view.element_color[view.ELEMENT_CARET] = white
view.caret_line_back = light_black
view.caret_line_frame = 2

-- Bracket match
view.indic_fore[textadept.editing.INDIC_BRACEMATCH] = white

-- Default indentation settings for all buffers.
buffer.use_tabs = true
buffer.tab_width = 4

-- Always use PEP-8 indentation style for Python files.
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'python' then return end
  buffer.tab_width = 4
  buffer.use_tabs = false
  view.view_ws = view.WS_VISIBLEALWAYS
end)

-- Wrap lines
--view.wrap_indent_mode = view.WRAPINDENT_INDENT
view.wrap_indent_mode = view.WRAPINDENT_DEEPINDENT
view.wrap_mode = view.WRAP_WORD
--view.wrap_visual_flags = view.WRAPVISUALFLAG_START
--view.wrap_visual_flags_location = view.WRAPVISUALFLAGLOC_START_BY_TEXT

-- Copy file path to clipboard
local function copy_file_path()
	--ui.print(buffer.filename)
	ui.clipboard_text = buffer.filename
end
keys['ctrl+alt+c'] = copy_file_path

-- Duplicate line/selection
local function dup()
	--ui.print(buffer.line_from_position(buffer.selection_start) .. "/" .. buffer.line_from_position(buffer.selection_end))
	if not buffer.selection_empty and buffer.line_from_position(buffer.selection_start) ~= buffer.line_from_position(buffer.selection_end) then
		-- Just copy instead of duplicate so when ctrl+z is better behavior
		--buffer.selection_duplicate()
		buffer.copy()
		-- Then unselect
		--ui.print(buffer.current_pos)
		buffer.set_empty_selection(buffer.current_pos)
		-- Then move caret down
		buffer.new_line()
		-- Then paste it there
		buffer.paste()
	else
		buffer.line_duplicate()
	end
end
keys['ctrl+d'] = dup

-- Toggle auto indent
local is_autoindent = false
local function toggle_autoindent()
	if not is_autoindent then
		textadept.editing.auto_indent = false
	else
		textadept.editing.auto_indent = true
	end
	is_autoindent = not is_autoindent
end
keys['ctrl+f7'] = toggle_autoindent
-- No auto indent on startup
events.connect(events.VIEW_NEW,toggle_autoindent)

-- Toggle auto pairs
local is_autopairs = false
local auto_pairs = textadept.editing.auto_pairs
local function toggle_autopairs()
	if not is_autopairs then
		textadept.editing.auto_pairs = nil
	else
		textadept.editing.auto_pairs = auto_pairs
	end
	is_autopairs = not is_autopairs
end
keys['ctrl+f8'] = toggle_autopairs
-- No auto pairs on startup
events.connect(events.VIEW_NEW,toggle_autopairs)

-- Toggle scrollbars
local is_scrollbars = false
local function toggle_scrollbars()
	if not is_scrollbars then
		view.v_scroll_bar = false
		view.h_scroll_bar = false
	else
		view.v_scroll_bar = true
		view.h_scroll_bar = true	
	end
	is_scrollbars = not is_scrollbars
end
keys['ctrl+f9'] = toggle_scrollbars
-- Hide scrollbars on startup
events.connect(events.VIEW_NEW,toggle_scrollbars)

-- Toggle line numbers
local is_linenum = false
local function toggle_linenum()
	if not is_linenum then
		for i = 1, view.margins do
			if view.margin_width_n[i] > 0 then
				view.margin_width_n[i] = 0
				view.margins = 0
			end
		end
	else
		view.margins = 5
		reset()
	end
	is_linenum = not is_linenum
end
keys['ctrl+f10'] = toggle_linenum
-- Hide line numbers on startup
events.connect(events.VIEW_NEW,toggle_linenum)

-- Toggle Menubar
local is_menubar = false
local menubar = textadept.menu.menubar
--keys['ctrl+f11'] = function()
local function toggle_menubar()
	if not is_menubar then
		textadept.menu.menubar = nil
	else
		textadept.menu.menubar = menubar
	end
	is_menubar = not is_menubar
end
keys['ctrl+f11'] = toggle_menubar
-- no menubar on startup
events.connect(events.VIEW_NEW,toggle_menubar)

-- Toggle Tabs
local is_tabs= false
local function toggle_tabs()
	if not is_tabs then
		ui.tabs = false
	else
		ui.tabs = true
	end
	is_tabs = not is_tabs
end
keys['ctrl+f12'] = toggle_tabs
-- no tabs on startup
events.connect(events.VIEW_NEW,toggle_tabs)

-- TESTING
local function test()
	--ui.print(buffer.get_text())
	local str = buffer.get_text()
	local first, last = 0
	while true do
		first, last = str:find((("<?php"):gsub("%p","%%%0")), first+1)
		--first, last = str:find("?>", first+1)
		if not first then break end
		ui.print(str:sub(first, last), first, last)
	end
end
keys['ctrl+~'] = test
