extends TextEdit

const PATH = "res://sintax/"
const YAML = ".yaml"

func _ready():
	theme.set_color("number_color", "TextEdit", "a1ffe1")

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

#func set_strings(formats):
#	for format in formats:
#		add_color_region(format, format, Color.yellow)

func set_string(formats):
	add_color_region(formats[0], formats[1], Color("ffeca1"))

func set_keywords(keywords):
	for keyword in keywords:
		print(keyword)
		add_keyword_color(keyword, Color("ff7185"))