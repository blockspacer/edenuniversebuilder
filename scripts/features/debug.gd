extends Node

func init():
	var file = File.new()
	var dir = Directory.new()
	dir.make_dir("user://logs/")
	file.open("user://logs/latest.txt", File.WRITE)
	file.close()

func msg(message, level):
	print(level + ": " + message)
	
	var file = File.new()
	file.open("user://logs/latest.txt", File.READ_WRITE)
	file.seek_end()
	file.store_string(level + ": " + message + '\n')
	file.close()
	
	for id in Entity.get_entities_with("terminal"):
		var components = Entity.objects[id].components
		if components.terminal.debug == true:
			components.terminal.text += level + ": " + message + '\n'
			components.terminal.text_rendered = false