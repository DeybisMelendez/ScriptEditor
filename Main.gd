extends Control

var copy_file = ""
var txt_changed = false
var col = 0
var line = 0
onready var TextLabel = $VBoxContainer/ToolBar/HBoxContainer2/TextLabel
onready var FileLabel = $VBoxContainer/ToolBar/HBoxContainer/FileLabel
onready var Editor = $VBoxContainer/TextEdit
onready var Dialog = $FileDialog
onready var Confirm = $ConfirmDialog

func _ready():
	Editor.connect("text_changed", self, "text_changed")
	Dialog.connect("file_selected", self, "file_selected")
	Confirm.connect("confirmed", self, "confirmed")
	Editor.connect("cursor_changed", self, "cursor_changed")

func cursor_changed():
	col = Editor.cursor_get_column()
	line = Editor.cursor_get_line()
	TextLabel.text = "Col: " + str(col) +", Line: " + str(line)

func confirmed():
	print("confirmed")
	if Dialog.mode == FileDialog.MODE_OPEN_ANY:
		new_file()
	elif Dialog.mode == FileDialog.MODE_SAVE_FILE:
		Dialog.popup_centered_minsize()
	elif Dialog.mode == FileDialog.MODE_OPEN_FILE:
		Dialog.popup_centered_minsize()

func file_selected(path):
	match Dialog.get_mode():
		FileDialog.MODE_OPEN_FILE:
			load_file(path)
			OS.set_window_title(path)
		FileDialog.MODE_SAVE_FILE:
			save_file(path)
	Dialog.invalidate()

func file_exists(path):
	var file = File.new()
	var file_exists = file.file_exists(path)
	file.close()
	return file_exists

func new_file():
	print("new_file")
	Editor.text = ""
	copy_file = Editor.text
	Dialog.set_current_file("")
	text_changed()

func load_file(path):
	var file = File.new()
	file.open(path, File.READ)
	Editor.text = file.get_as_text()
	file.close()
	copy_file = Editor.text
	FileLabel.text = Dialog.get_current_file()
	var sintax = Dialog.get_current_file().split(".",false)
	Editor.set_sintax(sintax[sintax.size()-1])

func save_file(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(Editor.text)
	file.close()
	copy_file = Editor.text
	text_changed()
	var sintax = Dialog.get_current_file().sintax.split(",",false)
	Editor.set_sintax(sintax[sintax.size()-1])

func text_changed():
	txt_changed = Editor.text != copy_file
	if txt_changed:
		FileLabel.text = Dialog.current_file + "*"
	else:
		FileLabel.text = Dialog.current_file

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("new_file"):
			#usado para identificar nuevo archivo nada mas
			Dialog.set_mode(FileDialog.MODE_OPEN_ANY)
			if txt_changed:
				Confirm.popup_centered_minsize()
			else:
				new_file()
		elif event.is_action_pressed("open_file"):
			Dialog.set_mode(FileDialog.MODE_OPEN_FILE)
			if txt_changed:
				Confirm.popup_centered_minsize()
			else:
				Dialog.popup_centered_minsize()
		elif event.is_action_pressed("save_file_as"):
			Dialog.set_mode(FileDialog.MODE_SAVE_FILE)
			Dialog.popup_centered_minsize()
		elif event.is_action_pressed("save_file"):
			Dialog.set_mode(FileDialog.MODE_SAVE_FILE)
			if file_exists(Dialog.current_path):# and Dialog.current_dir != "":
				save_file(Dialog.current_path)
			else:
				Dialog.popup_centered_minsize()
		elif event.is_action_pressed("resize_up"):
			Editor.get_font("font").size +=1
		elif event.is_action_pressed("resize_down"):
			Editor.get_font("font").size -=1
		elif event.is_action_pressed("comments"):
			var begin = Editor.get_selection_from_line()
			var end = Editor.get_selection_from_to_line()