extends TextEdit

const PATH = "res://sintax/"
const YAML = ".yaml"

onready var line = get_line(cursor_get_line())

var last_char = ""

func _ready():
	connect("text_changed", self, "text_changed")
	connect("request_completion", self, "test")

func test():
	print("completion")

func text_changed():
	brace_matching()

func set_sintax(sintax):
	clear_colors()
	var file = File.new()
	if not file.file_exists(PATH + sintax + YAML):
		return
	file.open(PATH + sintax + YAML, File.READ)
	var yaml = file.get_as_text()
	file.close()
	yaml = yaml.split("\n",false)
	for line in yaml:
		var op = line.split(": ",false)
		print(typeof(op[0]), op[0])
		var array = str(op[1])
		array.erase(0,1)
		array.erase(array.length()-1, 1)
		array = array.split(", ", false)
		print(array)
		match op[0]:
			"keyword":
				set_keywords(array)
			"string":
				set_string(array)
			"line_comment":
				set_line_comment(array)
			"block_comment":
				set_block_comment(array)

func set_line_comment(formats):
	for format in formats:
		add_color_region(format, "\n", Color("80c1cdd0"), true)

func set_block_comment(formats):
	add_color_region(formats[0], formats[1], Color("80c1cdd0"))

func set_string(formats):
	add_color_region(formats[0], formats[1], Color("ffeca1"))

func set_keywords(keywords):
	for keyword in keywords:
		print(keyword)
		add_keyword_color(keyword, Color("ff7185"))

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			last_char = OS.get_scancode_string(event.get_scancode())
			if event.is_action_pressed("show_lines"):
				var begin = get_selection_from_line()
				var finish = get_selection_to_line()
				for line in finish-begin:
					set_line_as_hidden(begin+line, false)
			elif event.is_action_pressed("hide_lines"):
				var begin = get_selection_from_line()
				var finish = get_selection_to_line()
				for line in finish-begin:
					set_line_as_hidden(begin+line, true)

func brace_matching():
	var matched = true
	match last_char:
		"QuoteDbl":
			insert_text_at_cursor("\"")
		"Apostrophe":
			insert_text_at_cursor("\'")
		"ParenLeft":
			insert_text_at_cursor(")")
		"BraceLeft":
			insert_text_at_cursor("}")
		"BracketLeft":
			insert_text_at_cursor("]")
		_:
			matched = false
	if matched:
		cursor_set_column(cursor_get_column()-1, true)