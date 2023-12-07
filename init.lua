-- ONLY FOR GTK 11.4

--[[
Custom find marker = ctrl+kp4
Custom find = ctrl+f
Copy file path to clipboard = ctrl+alt+c
Duplicate line/selection = ctrl+d
Toggle auto indent = ctrl+f7
Toggle auto pairs = ctrl+f8
Toggle scrollbars = ctrl+f9
Toggle line numbers = ctrl+f10
Toggle Menubar = ctrl+f11
Toggle Tabs = ctrl+f12
insert CSS marker = ctrl+kp2
insert comment marker = ctrl+kp1
insert marker = ctrl+kp3
add/remove block comment = ctrl+kp5
toggle all = ctrl+esc
]]

-- on start with split will cause all tabs to be split
local index = 1;
events.connect(events.QUIT,function()
	view:unsplit()
end,index)

-- Some local colors (/themes/dark.lua)
local white = 0xFFFFFF
local light_black = 0x333333
local black = 0x1A1A1A
local dark_green = 0x1A661A
local red = 0x4D4D99
local teal = 0x99994D
local dark_pink = 0x6666B3
local dark_lavender = 0xB36666
local orange = 0x4D99E6

-- Adjust the default theme's font and size.
if not CURSES then
  view:set_theme('dark', {font = 'DejaVu Sans Mono', size = 15})
end

-- Display file path in status bar if OS is set to hide title bar of apps
local function statusbar_filename()
	-- indicate if file has unsaved changes
	if buffer.modify and buffer.filename then
		ui.statusbar_text = '~' .. buffer.filename
	else
		ui.statusbar_text = buffer.filename
	end
end
events.connect(events.UPDATE_UI,statusbar_filename)
events.connect(events.FILE_AFTER_SAVE,statusbar_filename)

-- Custom find marker
keys['ctrl+kp4'] = function()
	ui.find.find_entry_text = '⌘'
	ui.find.focus()
	ui.find.find_next()
	ui.find.find_prev()
end

-- custom find
keys['ctrl+f'] = function()
	ui.find.find_entry_text = buffer.get_sel_text()
	local str = buffer.get_text()
	local len = string.len(str)
	buffer.indicator_clear_range(0,len)
	ui.find.focus()
	ui.find.find_next()
	ui.find.find_prev()
end
ui.find.highlight_all_matches = true
view.indic_fore[ui.find.INDIC_FIND] = white
view.indic_alpha[ui.find.INDIC_FIND] = 0

-- color selection
local function setSelectnColor()
	view.sel_alpha = 30
	view.element_color[view.ELEMENT_SELECTION_INACTIVE_BACK] = white | 0X20000000
	view.element_color[view.ELEMENT_SELECTION_ADDITIONAL_BACK] = white | 0X20000000
	view.element_color[view.ELEMENT_SELECTION_SECONDARY_BACK] = white | 0X20000000
end
events.connect(events.FOCUS,setSelectnColor)
events.connect(events.RESET_AFTER,setSelectnColor)
events.connect(events.BUFFER_NEW, setSelectnColor)
events.connect(events.FILE_OPENED, setSelectnColor)

-- Launch maximized
ui.maximized = true

-- Multi-edit (ctrl+LM) click or esc to end
buffer.multiple_selection = true
buffer.additional_selection_typing = true

-- Markers
view.marker_back[textadept.bookmarks.MARK_BOOKMARK] = white
view.marker_alpha[textadept.bookmarks.MARK_BOOKMARK] = 25

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
view.element_color[view.ELEMENT_SELECTION_BACK] = white
view.element_color[view.ELEMENT_CARET_LINE_BACK] = black
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = black

-- Caret
view.element_color[view.ELEMENT_CARET] = white
view.caret_line_back = light_black
view.caret_line_frame = 2
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = orange

-- Bracket match, removed in version 12.2
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
view.wrap_indent_mode = view.WRAPINDENT_DEEPINDENT
view.wrap_mode = view.WRAP_WORD

-- no typeover character ")"
textadept.editing.typeover_chars[string.byte(')')] = false

-- remove trailing spaces on save
textadept.editing.strip_trailing_spaces = true

--[[ iterate table
tbl = { 'one', 'two' }
for _, s in pairs(tbl) do
	val = s
end
]]

-- Copy file path to clipboard
local function copy_file_path()
	ui.clipboard_text = buffer.filename
	statusbar_filename()
end
keys['ctrl+alt+c'] = copy_file_path

-- Duplicate line/selection
local function dup()
	--ui.print(buffer.line_from_position(buffer.selection_start) .. "/" .. buffer.line_from_position(buffer.selection_end))
	if not buffer.selection_empty and buffer.line_from_position(buffer.selection_start) ~= buffer.line_from_position(buffer.selection_end) then
		-- get selected text for its length
		local sel_text = buffer.get_sel_text()

		-- Just insert instead of duplicate for custom behavior
		--buffer.selection_duplicate()

		-- Then unselect
		buffer.set_empty_selection(buffer.current_pos)

		-- Then move caret down
		buffer.new_line()

		-- add space in between
		--buffer.new_line()

		-- Then insert duplicate text
		buffer.insert_text(buffer.current_pos,sel_text)

		-- reposition caret to end of line of inserted duplicate text
		buffer.goto_pos(buffer.current_pos + #sel_text)

		-- caret is at end of line, count backwards using length to reselect
		buffer.set_selection(buffer.current_pos, buffer.current_pos - string.len(sel_text))
	else
		buffer.line_duplicate()
	end
end
keys['ctrl+d'] = dup

-- Toggle auto indent
local is_autoindent = false
local function toggle_autoindent()
	if not is_autoindent then
		textadept.editing.auto_indent = true
	else
		textadept.editing.auto_indent = false
	end
	is_autoindent = not is_autoindent
end
keys['ctrl+f7'] = toggle_autoindent

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

-- Toggle scrollbars
local isScrollbars = false
local scrolBarState;
local function toggle_scrollbars()
	if not isScrollbars then
		scrolBarState = false
	else
		scrolBarState = true
	end

	view.v_scroll_bar = scrolBarState
	view.h_scroll_bar = scrolBarState

	isScrollbars = not isScrollbars
end
keys['ctrl+f9'] = toggle_scrollbars

-- Toggle line numbers
local isLinenum = false
local mWdtLst = {}
local mWdtState
local function toggle_linenum()
	if not isLinenum then
		mWdtLst[1] = view.margin_width_n[1]
		mWdtState = 0
	else
		view.margin_width_n[1] = mWdtLst[1]
		mWdtState = mWdtLst[1]
	end
	view.margin_width_n[1] = mWdtState
	isLinenum = not isLinenum
end
keys['ctrl+f10'] = toggle_linenum

-- Toggle Tabs
local isTabs = false
local function toggle_tabs()
	if not isTabs then
		ui.tabs = false
	else
		ui.tabs = true
	end
	is_tabs = not isTabs
end
keys['ctrl+f12'] = toggle_tabs

-- Toggle Menubar
local isMenubar = false
local menubar = textadept.menu.menubar
--keys['ctrl+f11'] = function()
local function toggle_menubar()
	if not isMenubar then
		textadept.menu.menubar = nil
	else
		textadept.menu.menubar = menubar
	end
	isMenubar = not isMenubar
end
keys['ctrl+f11'] = toggle_menubar
events.connect(events.INITIALIZED,toggle_menubar)

function toggle_all()
	toggle_linenum()
	toggle_autoindent()
	toggle_autopairs()
	toggle_scrollbars()
	toggle_tabs()
end
keys['ctrl+esc'] = toggle_all

function updateState()
	-- update tabs on state of...
	view.margin_width_n[1] = mWdtState
	view.v_scroll_bar = scrolBarState
	view.h_scroll_bar = scrolBarState
end
events.connect(events.BUFFER_AFTER_SWITCH,updateState)
events.connect(events.BUFFER_NEW,updateState)
events.connect(events.FILE_OPENED,updateState)
--events.connect(events.VIEW_AFTER_SWITCH,updateState)

local once = false
events.connect(events.VIEW_NEW,function()
	if not once then
		toggle_all()
		once = true
	end
end)

-- insert CSS marker
local function cssmrk()
	buffer.add_text('/* ⌘ */')
end
keys['ctrl+kp2'] = cssmrk

-- insert comment marker
local function cmrk()
	buffer.add_text('// ⌘')
end
keys['ctrl+kp1'] = cmrk

-- insert marker
local function mrk()
	buffer.add_text(' ⌘')
end
keys['ctrl+kp3'] = mrk

-- add/remove block comment
local function blok_commnt()
	-- get selected text
	local sel_text = buffer.get_sel_text()
	-- only if or not block comment
	if string.find(sel_text, "/[*]") == nil and string.find(sel_text, "[*]/") == nil then
		buffer.replace_sel('/*' .. sel_text .. '*/')
	elseif string.find(sel_text, "/[*]") ~= nil and string.find(sel_text, "[*]/") ~= nil then
		-- remove open
		local opnBegIdx, opnEndIdx = string.find(sel_text, "/[*]")
		local prfx1 = string.sub(sel_text, 1, opnBegIdx - 1)
		local sufx1 = string.sub(sel_text, opnEndIdx + 1)
		local blokStr = prfx1 .. sufx1
		-- remove close
		local clsBegIdx, clsEndIdx = string.find(blokStr, "[*]/")
		local prfx2 = string.sub(blokStr, 1, clsBegIdx - 1)
		local sufx2 = string.sub(blokStr, clsEndIdx + 1)
		buffer.replace_sel(prfx2 .. sufx2)
	end
end
keys['ctrl+kp5'] = blok_commnt

-- thank you to Eric Anderson for his show & tell of this code
-- show opening block in status bar, closing block must not have space before it
function string.trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

events.connect(events.UPDATE_UI, function(updated)
  -- We only care when the cursor moves
  if not (updated & buffer.UPDATE_SELECTION) then return end

  local line = buffer:line_from_position(buffer.current_pos)
  local line_text = buffer.get_line(line)
  local blank = line_text == "\n"

  -- Starting line is blank so nothing to match up against
  if blank then return end

  -- First line can't match up to anything so return early otherwise we get an
  -- error trying to read the previous line.
  if line <= 1 then return end

  local cur_indent = buffer.line_indentation[line]
  local prev_indent = buffer.line_indentation[line-1]

  -- If the previous line is not nested, return early as we are not ending a indention match
  if prev_indent <= cur_indent then return end

  repeat
    line = line - 1
    prev_indent = buffer.line_indentation[line]
    line_text = buffer:get_line(line)
    blank = line_text == "\n"
  until prev_indent <= cur_indent and not blank

  line_text = line_text:trim()

  if line_text == '/*' then return end
  if line_text == '/**' then return end

  if buffer.filename then
	ui.statusbar_text = buffer.filename .. "	" .. "block start: " .. line_text
  end
end)

events.connect(events.VIEW_NEW,function()
	-- has before "toggle_all()" or it does not work in "events.VIEW_NEW"
	textadept.session.load(_USERHOME..'/session')
	for i = 1, #arg do
		local filename = lfs.abspath(arg[i], arg[-1])
		if lfs.attributes(filename) then -- not a switch
			io.open_file(filename)
			updateState()
		end
	end
end)
