extends Spatial

onready var chunk_template = preload("res://scenes/chunk.tscn")
onready var Player = get_node("/root/World/Player")

var world_seed = 0
var chunk_index = {}
var i = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	create_world(2, 2)
	#print(get_chunk(Vector3(16, 0, 0)))

func create_world(distance, height):
	for x in range(distance):
		for y in range(height):
			for z in range(distance):
				create_chunk(Vector3(x, y, z))

func create_chunk(location):
	var chunk = chunk_template.instance()
	add_child(chunk)
	chunk.name = str(location.x) + ", " + str(location.y) + ", " + str(location.z)
	chunk.translate_object_local(Vector3(location.x*16, location.y*16, location.z*16))
	chunk_index[location] = chunk

func get_chunk_sub(location):
	var i = 0
	var x = null
	if location == 0:
		print(location)
		x = i
	if location >= 0:
		while x == null:
			if location >= i and location < i*16:
				print(location)
				x = i
			i += 1
	else:
		while x == null:
			if location >= i and location < i*16:
				print(location)
				x = i
			i -= 1
	return x

func get_chunk(location):
	var x = get_chunk_sub(location.x)
	var y = get_chunk_sub(location.y)
	var z = get_chunk_sub(location.z)
	
	return Vector3(x, y, z)

func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
	
	# 0 frezes the game 
	#print(Player.translation)
	i += 1
	if i >= 100:
		print(get_chunk(Player.translation))
		i = 0
	#if !(chunk_index.has(get_chunk(Player.translation))):
		#create_chunk(get_chunk(Player.translation))
		#print("Creating chunk... ")
