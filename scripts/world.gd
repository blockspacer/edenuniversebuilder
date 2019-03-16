extends Spatial

onready var chunk_template = preload("res://scenes/chunk.tscn")
onready var player_template = preload("res://scenes/player.tscn")

onready var Player = null
onready var World = null
onready var Hud = get_node("HUD")

var map_seed = 0
#var map_path = "user://world1.eden2"
var map_path = "res://worlds/direct_city.eden2"
var map_name = "direct_city.eden2"
#var map_path = "res://worlds/test_world.eden2"
#var map_name = "test_world.eden2"
var loaded = false
var player_teleported = false
var first_chunk = Vector3(0, 0, 0)
var total_chunks = 0
var chunks_cache_size = 0
var loaded_chunks = 0
var chunk_index = {}
var temp_player_chunk = Vector3(0, 0, 0)

var map_file = File.new()
var ChunkLocations = Dictionary()
var ChunkAddresses = Dictionary()
var ChunkMetadata = Array()

var worldAreaX = 0
var worldAreaY = 0
var worldAreaWidth = 0
var worldAreaHeight = 0

var player_move_forward = false

func _ready():
	if map_seed != -1:
		var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
		World = get_node("/root/World")
		EdenWorldDecoder.World = World
		EdenWorldDecoder.set_vars()
		EdenWorldDecoder.init_world()
		
		Player = player_template.instance()
		Player.World = World
		add_child(Player)
	else:
		World = get_node("/root/Main Menu/World")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	create_world(2, 1)
	Hud.msg("Staring...", "Debug")

func create_world(distance, height):
	for x in range(distance):
		for y in range(height):
			for z in range(distance):
				create_chunk(Vector3(x, y, z))

func create_chunk(location):
	var chunk = chunk_template.instance()
	chunk.World = World
	chunk.chunk_location = location
	add_child(chunk)
	chunk.name = str(location.x) + ", " + str(location.y) + ", " + str(location.z)
	chunk.translate_object_local(Vector3(location.x*16, location.y*16, location.z*16))
	
	if map_seed != -1:
		var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
		EdenWorldDecoder.World = World
		EdenWorldDecoder.set_vars()
		#EdenWorldDecoder.init_world()
		#chunk.chunk_address = EdenWorldDecoder.ChunkMetadata[floor(rand_range(0, 6))].address
	
	chunk_index[location] = chunk

func get_chunk_sub(location):
	var x = 0
	if location == 0:
		return 0
	elif location > 0:
		while !(location >= x and location < x*16):
			x += 1
	else:
		while !(location <= x and location > x*16):
			x -= 1
	return x - 1

func get_chunk(location):
	var x = get_chunk_sub(int(round(location.x)))
	var y = get_chunk_sub(int(round(location.y)))
	var z = get_chunk_sub(int(round(location.z)))
	
	return Vector3(x, y, z)

func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
	
	if map_seed != -1:
		if loaded == true and player_teleported == false:
			Player.translation =  first_chunk
			player_teleported = true
		
		var player_chunk = get_chunk(Player.translation)
		if player_chunk != temp_player_chunk:
			print(player_chunk)
			temp_player_chunk = player_chunk
	
		#if !(chunk_index.has(get_chunk(Player.translation))):
		#create_surrounding_chunks(get_chunk(Player.translation))
		create_surrounding_chunks(get_chunk(Player.translation))
	else:
		create_surrounding_chunks(get_chunk(Vector3(0, 0, 0)))

func create_surrounding_chunks(center_chunk):
	for x in range(3):
		for y in range(3):
			for z in range(3):
				if !(chunk_index.has(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))):
					#print("Creating chunk... ")
					create_chunk(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))

func _on_ForwardButton_pressed():
	player_move_forward = true


func _on_ForwardButton_released():
	player_move_forward = false
