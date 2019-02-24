extends Spatial

onready var chunk_template = preload("res://scenes/chunk.tscn")
var world_seed = 0
var chunk_array = Array()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	create_world(1)

func create_world(distance):
	var chunk = chunk_template.instance()
	add_child(chunk)
	#chunk.name = str(chunk_x) + ", " + str(chunk_y) + "-" + str(id)
	#chunk.generate_block_mesh(id, block_name, textures)
	#chunk_array.append(chunk)

func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
