extends Spatial

onready var World = preload("res://scenes/world.tscn")
onready var Dot = preload("res://scenes/dot.tscn")

func _ready():
	#$UI/Menu/LoadButton.grab_focus()
	var world = World.instance()
	world.world_seed = -1
	add_child(world)
	
	draw_dots()

func draw_dots():
	for x in range(40):
		for y in range(40):
			var dot = Dot.instance()
			add_child(dot)
			dot.rect_position = Vector2(x*40, y*40)

func _process(delta):
	pass
	#if $UI/Menu/LoadButton.is_hovered():
		#$UI/Menu/LoadButton.grab_focus()


func _on_LoadButton_released():
	print("Loading world...")
	get_tree().change_scene("res://scenes/world.tscn")
