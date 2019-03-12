
static func msg(message, tag):
	print(tag, ": ", message)
	
	var Hud = load("res://scripts/hud.gd").new()
	Hud.show_msg(message, tag)