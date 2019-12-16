extends Control

export (PackedScene) var Body
onready var Dialog = $FileDialog
onready var TabCont = $TabContainer
onready var ConfirmClose = $ConfirmDialog

func _ready():
	Dialog.connect("file_selected", self, "file_selected")
	ConfirmClose.connect("confirmed", self, "close_confirmed")

func close_confirmed():
	TabCont.get_current_tab_control().queue_free()

func get_path():
	return TabCont.get_current_tab_control().path

func get_text():
	return TabCont.get_current_tab_control().Editor.text

func text_changed():
	return TabCont.get_current_tab_control().txt_changed

func get_editor():
	return TabCont.get_current_tab_control().Editor

func file_is_open(path):
	for tab in TabCont.get_tab_count():
		if TabCont.get_tab_control(tab).path == path:
			TabCont.current_tab = tab
			return true
	return false

func file_selected(path):
	match Dialog.get_mode():
		FileDialog.MODE_OPEN_FILE:
			if not file_is_open(path):
				new_file(path)
		FileDialog.MODE_SAVE_FILE:
			save_file(path)
	set_focus_on_TextEditor()
	TabCont.get_current_tab_control().text_changed()
	Dialog.invalidate()

func new_file(path):
	var new_body = Body.instance()
	#var current_file = "untitled"
	if path:
		new_body.path = path
		new_body.current_file = Dialog.current_file
	else:
		new_body.current_file = "untitled"
	TabCont.add_child(new_body)
	TabCont.current_tab = TabCont.get_tab_count()-1
	TabCont.get_current_tab_control().load_file()
	TabCont.get_current_tab_control().focus_editor()

func save_file(path):
	TabCont.get_current_tab_control().save_file(path, Dialog.current_file)

func set_focus_on_TextEditor():
	TabCont.get_current_tab_control().focus_editor()

func file_exists(path):
	var file = File.new()
	var file_exists = file.file_exists(path)
	file.close()
	return file_exists

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.is_action_pressed("new_file"):
				new_file(null)
			elif event.is_action_pressed("open_file"):
				Dialog.set_mode(FileDialog.MODE_OPEN_FILE)
				Dialog.popup_centered_minsize()
			elif event.is_action_pressed("save_file_as"):
				Dialog.set_mode(FileDialog.MODE_SAVE_FILE)
				Dialog.popup_centered_minsize()
			elif event.is_action_pressed("save_file"):
				var path = get_path()
				if path == "":
					Dialog.set_mode(FileDialog.MODE_SAVE_FILE)
					Dialog.popup_centered_minsize()
				else:
					save_file(null)
			elif event.is_action_pressed("close_file"):
				if TabCont.get_tab_count() > 0:
					if text_changed():
						ConfirmClose.popup_centered_minsize()
					else:
						close_confirmed()
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