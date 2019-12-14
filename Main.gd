extends Control

var copy_file = ""
var txt_changed = false
var col = 0
var line = 0
export (PackedScene) var Body
onready var Dialog = $FileDialog
onready var TabCont = $TabContainer

func _ready():
	Dialog.connect("file_selected", self, "file_selected")

func file_selected(path):
	match Dialog.get_mode():
		FileDialog.MODE_OPEN_FILE:
			new_file(path)
			#set_focus_on_TextEditor()
			#OS.set_window_title(path)
		FileDialog.MODE_SAVE_FILE:
			save_file_as(path, Dialog.current_file)
			set_focus_on_TextEditor()
	Dialog.invalidate()

func new_file(path):
	var new_body = Body.instance()
	var current_file = "untitled"
	if path:
		new_body.path = path
		current_file = Dialog.current_file
		new_body.current_file = current_file
	else:
		new_body.current_file = "untitled"
	TabCont.add_child(new_body)
	TabCont.set_tab_title(TabCont.get_tab_count()-1, current_file)
	TabCont.current_tab = TabCont.get_tab_count()-1
	set_focus_on_TextEditor()

func set_focus_on_TextEditor():
	TabCont.get_current_tab_control().focus_editor()

func save_file_as(p, f):
	TabCont.get_current_tab_control().save_file_as(p, f)

func file_exists(path):
	var file = File.new()
	var file_exists = file.file_exists(path)
	file.close()
	return file_exists

#func set_focus_on_TextEditor():
#	TabCont.get_current_tab_control().get_node("VBoxContainer/TextEdit").grab_focus()

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("new_file"):
			#usado para identificar nuevo archivo nada mas
			new_file(null)
		elif event.is_action_pressed("open_file"):
			Dialog.set_mode(FileDialog.MODE_OPEN_FILE)
			Dialog.popup_centered_minsize()
		elif event.is_action_pressed("next_tab"):
			var total_tabs = TabCont.get_tab_count()
			if total_tabs > 1:
				var next_tab = TabCont.current_tab + 1
				if next_tab >= total_tabs:
					TabCont.current_tab = 0
				else:
					TabCont.current_tab = next_tab
			set_focus_on_TextEditor()
		elif event.is_action_pressed("back_tab"):
			var total_tabs = TabCont.get_tab_count()
			if total_tabs > 1:
				var back_tab = TabCont.current_tab - 1
				if back_tab < 0:
					TabCont.current_tab = total_tabs - 1
				else:
					TabCont.current_tab = back_tab
			set_focus_on_TextEditor()