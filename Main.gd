extends Control

var copy_file = ""
var txt_changed = false
var col = 0
var line = 0
onready var TextLabel = $VBoxContainer/ToolBar/HBoxContainer2/TextLabel
onready var FileLabel = $VBoxContainer/ToolBar/HBoxContainer/FileLabel

func _ready():
	load_file($FileDialog.current_path)
	$VBoxContainer/TextEdit.connect("text_changed", self, "text_changed")
	$FileDialog.connect("file_selected", self, "file_selected")
	$ConfirmationDialog.connect("confirmed", self, "confirmed")
	$VBoxContainer/TextEdit.connect("cursor_changed", self, "cursor_changed")

func cursor_changed():
	col = $VBoxContainer/TextEdit.cursor_get_column()
	line = $VBoxContainer/TextEdit.cursor_get_line()
	TextLabel.text = "Col: " + str(col) +", Line: " + str(line)

func confirmed():
	save_file($FileDialog.current_file)

func file_selected(path):
	match $FileDialog.get_mode():
		FileDialog.MODE_OPEN_FILE:
			load_file(path)
			OS.set_window_title(path)
		FileDialog.MODE_SAVE_FILE:
			save_file(path)

func load_file(path):
	var file = File.new()
	file.open(path, File.READ)
	$VBoxContainer/TextEdit.text = file.get_as_text()
	file.close()
	copy_file = $VBoxContainer/TextEdit.text
	FileLabel.text = $FileDialog.current_file

func save_file(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string($VBoxContainer/TextEdit.text)
	file.close()
	copy_file = $VBoxContainer/TextEdit.text
	text_changed()

func text_changed():
	txt_changed = $VBoxContainer/TextEdit.text != copy_file
	if txt_changed:
		FileLabel.text = $FileDialog.current_file + "*"
	else:
		FileLabel.text = $FileDialog.current_file

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("open_file"):
			if txt_changed:
				$ConfirmationDialog.popup()
			else:
				$FileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
				$FileDialog.popup()
		elif event.is_action_pressed("save_file"):
			if $FileDialog.current_file != "":
				save_file($FileDialog.current_path)
			else:
				$FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
				$FileDialog.popup()
		elif event.is_action_pressed("save_file_as"):
			$FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
			$FileDialog.popup()
		elif event.is_action_pressed("resize_up"):
			$VBoxContainer/TextEdit.get_font("font").size +=1
		elif event.is_action_pressed("resize_down"):
			$VBoxContainer/TextEdit.get_font("font").size -=1