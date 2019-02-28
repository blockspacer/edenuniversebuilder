extends Spatial

onready var chunk_template = preload("res://scenes/chunk.tscn")
onready var Player = get_node("/root/World/Player")

var world_seed = 0
var chunk_index = {}
var temp_player_chunk = Vector3(0, 0, 0)

func _ready():
	
	if Player == null:
		Player = get_node("/root/Main Menu/World/Player")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	create_world(2, 1)
	#print(get_chunk(Vector3(16, 0, 0)))

func create_world(distance, height):
	for x in range(distance):
		for y in range(height):
			for z in range(distance):
				create_chunk(Vector3(x, y, z))

func create_chunk(location):
	var chunk = chunk_template.instance()
	chunk.chunk_location = location
	add_child(chunk)
	chunk.name = str(location.x) + ", " + str(location.y) + ", " + str(location.z)
	chunk.translate_object_local(Vector3(location.x*16, location.y*16, location.z*16))
	chunk_index[location] = chunk

func get_chunk_sub(location):
	var x = 0
	if location == 0:
		return 0
	elif location > 0:
		#print(location)
		while !(location >= x and location < x*16):
			x += 1
	else:
		#print("Location neg: ", location)
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
	
	var player_chunk = get_chunk(Player.translation)
	if player_chunk != temp_player_chunk:
		print(player_chunk)
		temp_player_chunk = player_chunk
	
	#if !(chunk_index.has(get_chunk(Player.translation))):
		#create_surrounding_chunks(get_chunk(Player.translation))
	create_surrounding_chunks(get_chunk(Player.translation))

func create_surrounding_chunks(center_chunk):
	for x in range(3):
		for y in range(3):
			for z in range(3):
				if !(chunk_index.has(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))):
					#print("Creating chunk... ")
					create_chunk(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))