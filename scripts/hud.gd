extends Control

var analog_is_pressed = false
var frames_passed = 0

func _ready():
	load_debug_screen()

func _process(delta):
	if has_node("/root/World/Player"):
		var Player = get_node("/root/World/Player")
		var XYZ = find_node("Player XYZ")
		XYZ.set_text("XYZ: " + str(Player.translation))
		
		var chunk_address = find_node("Chunk Address")
		chunk_address.set_text(" == " + str(Player.current_chunk) + " == ")
		
		var chunk_position = find_node("Chunk XYZ")
		chunk_position.set_text("XYZ: " + str(Player.current_chunk_pos))
		
	var fps = find_node("FPS")
	fps.set_text("FPS: " + str(Engine.get_frames_per_second()))
	
	frames_passed+=1
	if frames_passed > 100:
		load_debug_screen()
		frames_passed = 0

func load_debug_screen():
	var version = find_node("Version")
	version.set_text(fetch_client_version())
	
	if has_node("/root/World"):
		var World = get_node("/root/World")
		var world_name = find_node("World Name")
		world_name.set_text(" == " + World.map_name + " == ")
		
		var world_path = find_node("World Path")
		world_path.set_text(World.map_path)
		
		var total_chunks = find_node("Total Chunks")
		total_chunks.set_text("Total chunks: " + str(World.total_chunks))
		
		var chunks_cache = find_node("Chunks Cache")
		if World.chunks_cache_size == 0:
			chunks_cache.set_text("Chunks cache: " + "none")
		else:
			chunks_cache.set_text("Chunks cache: " + str(World.chunks_cache_size))

func fetch_client_version():
	var file = File.new()
	if file.open("res://version.txt", File.READ) != 0:
		msg("Error reading client version.", "Error")
	
	return file.get_as_text()

func show_msg(message, tag):
	if find_node("Chat"):
		var Chat = find_node("Chat")
		Chat.add_text(tag + ": " + str(message) + '\n')

func msg(message, tag):
	print(tag, ": ", message)
	
	if get_tree().get_root().has_node("/root/World/HUD"):
		var Hud = get_tree().get_root().get_node("/root/World/HUD")
		Hud.show_msg(message, tag)

func _on_AnalogTop_pressed():
	analog_is_pressed = true;

func _on_AnalogTop_released():
	analog_is_pressed = false;

func _input(event):
	if event is InputEventScreenDrag:
		if analog_is_pressed:
			var touch_position = event.position
			msg("Touching the Analog stick", "Debug")
			msg(touch_position, "Debug")