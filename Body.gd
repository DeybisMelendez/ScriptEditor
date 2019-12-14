extends Control

var copy_file = ""
var txt_changed = false
var col = 0
var line = 0
var path = ""
var workspace = ""
var current_file = ""
var is_focused = false

onready var TextLabel = $VBoxContainer/ToolBar/HBoxContainer2/TextLabel
onready var FileLabel = $VBoxContainer/ToolBar/HBoxContainer/FileLabel
onready var Editor = $VBoxContainer/TextEdit
onready var Confirm = $ConfirmationDialog

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("save_file"):
			save_file()
		elif event.is_action_pressed("close_file"):
			if is_focused:
				if txt_changed:
					Confirm.popup_centered_minsize()
				else:
					queue_free()

func _ready():
	Editor.connect("focus_entered", self, "focus_entered")
	Editor.connect("focus_exited", self, "focus_exited")
	Editor.connect("text_changed", self, "text_changed")
	Editor.connect("cursor_changed", self, "cursor_changed")
	Confirm.connect("confirmed", self, "confirmed")
	load_file(null)
	#current_file = path.split("/",false)[path.split("/",false).size()-1]

func focus_entered():
	is_focused = true

func focus_exited():
	is_focused = false

func confirmed():
	queue_free()

func cursor_changed():
	col = Editor.cursor_get_column()
	line = Editor.cursor_get_line()
	TextLabel.text = "Col: " + str(col) +", Line: " + str(line)

func text_changed():
	txt_changed = Editor.text != copy_file
	if txt_changed:
		FileLabel.text = current_file + "*"
	else:
		FileLabel.text = current_file

func load_file(p):
	if p:
		path = p
	current_file = path.split("/",false)[path.split("/",false).size()-1]
	var file = File.new()
	file.open(workspace+path, File.READ)
	Editor.text = file.get_as_text()
	file.close()
	copy_file = Editor.text
	FileLabel.text = current_file
	var sintax = current_file.split(".",false)
	Editor.set_sintax(sintax[sintax.size()-1])

func save_file():
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(Editor.text)
	file.close()
	copy_file = Editor.text
	text_changed()
	var sintax = current_file.split(".", false)
	Editor.set_sintax(sintax[sintax.size()-1])