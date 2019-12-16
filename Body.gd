extends Control

var copy_file = ""
var txt_changed = false
var col = 0
var line = 0
var path = ""
var current_file = ""
var is_focused = false
onready var TabCont = get_parent()
onready var TextLabel = $VBoxContainer/ToolBar/HBoxContainer2/TextLabel
onready var FileLabel = $VBoxContainer/ToolBar/HBoxContainer/FileLabel
onready var Editor = $VBoxContainer/TextEdit

func _input(event):
	if is_focused:
		if event is InputEventKey:
			if event.is_pressed():
				if event.is_action_pressed("resize_down"):
					add_size_font(-1)
				elif event.is_action_pressed("resize_up"):
					add_size_font(1)

func add_size_font(value):
	Editor.get_font("font").size += value

func _ready():
	connect("focus_entered", self, "body_focus_entered")
	Editor.connect("focus_entered", self, "focus_entered")
	Editor.connect("focus_exited", self, "focus_exited")
	Editor.connect("text_changed", self, "text_changed")
	Editor.connect("cursor_changed", self, "cursor_changed")
	#text_changed()

func body_focus_entered():
	focus_editor()

func focus_editor():
	Editor.grab_focus()

func focus_entered():
	is_focused = true

func focus_exited():
	is_focused = false

func cursor_changed():
	col = Editor.cursor_get_column()
	line = Editor.cursor_get_line()
	TextLabel.text = "Col: " + str(col) +", Line: " + str(line)

func text_changed():
	FileLabel.text = "Total: " + str(Editor.text.length()) + ", Changes: " + str(abs(copy_file.length() - Editor.text.length())) + "\nPath: " + path
	txt_changed = Editor.text != copy_file
	if txt_changed:
		TabCont.set_tab_title(TabCont.current_tab, current_file + "*")
	else:
		TabCont.set_tab_title(TabCont.current_tab, current_file)

func load_file():
	if path != "":
		var file = File.new()
		file.open(path, File.READ)
		Editor.text = file.get_as_text()
		file.close()
		copy_file = Editor.text
		FileLabel.text = current_file
		var sintax = current_file.split(".",false)
		Editor.set_sintax(sintax[sintax.size()-1])
		text_changed()
	else:
		text_changed()

#func update_info():
#	#TabCont.set_tab_title(TabCont.current_tab, current_file)
#	text_changed()

#func save_file_as(p, f):
#	var file = File.new()
#	file.open(p, File.WRITE)
#	file.store_string(Editor.text)
#	file.close()
#	copy_file = Editor.text
#	current_file = f
#	var sintax = current_file.split(".", false)
#	Editor.set_sintax(sintax[sintax.size()-1])
#	text_changed()

func save_file(p, f):
	if p:
		path = p
		current_file = f
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(Editor.text)
	file.close()
	copy_file = Editor.text
	var sintax = current_file.split(".", false)
	Editor.set_sintax(sintax[sintax.size()-1])
	text_changed()