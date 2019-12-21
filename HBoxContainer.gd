extends HBoxContainer

func _ready():
	$LineEdit.connect("text_changed", self, "text_changed")

func text_changed(text):
	pass