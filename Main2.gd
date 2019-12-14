extends Control
export (PackedScene) var Body
onready var Dialog = $FileDialog
onready var TabCont = $TabContainer
onready var Workspace = $HBoxContainer/VBoxContainer/Tree
onready var Command = $Command
var workspace = ""

func _ready():
	Dialog.connect("dir_selected", self, "workspace_selected")
	Command.get_node("LineEdit").connect("text_entered", self, "command_requested")

func command_requested(command):
	Command.hide()
	if command != "":
		var parts = command.split(" ", false)
		match parts[0]:
			"open":
				open_file(parts[1])
	Command.get_node("LineEdit").text = ""

func open_file(path):
	var f = path.split("/", false)
	for tab in TabCont.get_tab_count():
		var Tab =TabCont.get_tab_control(tab)
		if Tab.current_file:
			if Tab.current_file == f[f.size()-1]:
				TabCont.current_tab = tab
				return
	var new_body = Body.instance()
	print(workspace +  "/" + path)
	new_body.path = workspace + "/" + path
	TabCont.add_child(new_body)
	TabCont.set_tab_title(TabCont.get_tab_count()-1, f[f.size()-1])
	set_focus_on_TextEditor()
	

func set_focus_on_TextEditor():
	TabCont.get_current_tab_control().get_node("VBoxContainer/TextEdit").grab_focus()

func add_size_font_to_TextEditor(value):
	TabCont.get_current_tab_control().get_node("TextEdit").get_font("font").size += value

func workspace_selected(path):
	workspace = path
	OS.set_window_title("Script - Workspace: " + workspace)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("workspace"):
			Dialog.popup_centered_minsize()
		elif event.is_action_pressed("command"):
			Command.popup_centered_minsize()
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
		elif event.is_action_pressed("resize_up"):
			add_size_font_to_TextEditor(1)
		elif event.is_action_pressed("resize_down"):
			add_size_font_to_TextEditor(-1)