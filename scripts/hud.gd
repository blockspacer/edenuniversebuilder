extends Control

onready var Debug = preload("res://scripts/debug.gd").new()
var analog_is_pressed = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func show_msg(message, tag):
	if get_node("/root/World") != null:
		var Chat = get_node("/root/World/HUD/Chat")
		Chat.add_text(message)

func _on_AnalogTop_pressed():
	analog_is_pressed = true;

func _on_AnalogTop_released():
	analog_is_pressed = false;

func _input(event):
	if event is InputEventScreenDrag:
		if analog_is_pressed:
			var touch_position = event.position
			Debug.msg("Touching the Analog stick", "Debug")
			Debug.msg(touch_position, "Debug")