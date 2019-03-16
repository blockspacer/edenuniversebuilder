extends Spatial

onready var world_template = preload("res://scenes/world.tscn")
onready var dot_template = preload("res://scenes/dot.tscn")
var Hud

func _ready():
	#$UI/Menu/LoadButton.grab_focus()
	var World = world_template.instance()
	World.map_seed = -1
	add_child(World)
	Hud = World.Hud
	draw_dots()

func draw_dots():
	for x in range(40):
		for y in range(40):
			var dot = dot_template.instance()
			add_child(dot)
			dot.rect_position = Vector2(x*40, y*40)

func _process(delta):
	if Input.is_action_just_pressed("load_world"):
			Hud.msg("Loading world...", "Info")
			get_tree().change_scene("res://scenes/world.tscn")


func _on_LoadButton_released():
	Hud.msg("Loading world...", "Info")
	get_tree().change_scene("res://scenes/world.tscn")
