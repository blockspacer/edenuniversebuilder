# just routes input signals to other systems
extends Node

func _ready():
	Debug.msg("Input System ready.", "Info")

func _process(delta):
	var entities = Entity.get_entities_with("hud")
	for id in entities:
		if get_node("/root/Entity/" + str(id)):
			var components = entities[id].components
			if !Entity.get_component(id, "hud.horizontal_main.vertical_main.nav_controls.joystick.input_system") and Entity.get_component(id, "hud.horizontal_main.vertical_main.nav_controls.joystick.interface_system"):
				var bottom = get_node("/root/Entity/" + str(id) + "/Hud/HorizontalMain/VerticalMain/NavControls/Joystick/Bottom")
				var top = get_node("/root/Entity/" + str(id) + "/Hud/HorizontalMain/VerticalMain/NavControls/Joystick/Top")
				
				bottom.connect("button_down", self, "_joystick_pressed", [true])
				bottom.connect("button_up", self, "_joystick_pressed", [false])
				
				components.hud.horizontal_main.vertical_main.nav_controls.joystick.input_system = true
				Entity.edit(id, components)
	
	
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#InterfaceSystem.pause_menu()
		#get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _joystick_pressed(down):
	Debug.msg("Woah", "Debug")

################################### signals ###################################

func ready(): ################################################################
	World.total_players += 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#camera_width_center = OS.get_window_size().x / 2
	#camera_height_center = OS.get_window_size().y / 2

func _physics_process(delta): #################################################
	for id in Entity.get_entities_with("player"):
		if Entity.objects.has(id):
			var components = Entity.objects[id].components
			if components.has("player"):
				#connect("submit", components.text_input.object, components.text_input.method, [id])
				#Player.fly(delta, id)
				Player.walk(delta, id)
				#if event is InputEventKey and event.pressed:
					#if event.scancode == KEY_ENTER:
						#emit_signal("submit")
					#components.text_input.text += event.as_text()

signal submit

func _input(event): ###########################################################
	for id in Entity.get_entities_with("text_input"):
		if Entity.objects.has(id):
			var components = Entity.objects[id].components
			if components.has("text_input"):
				if components.text_input.rendered == false:
					var node = get_node("/root/Entity/" + str(id))
					
					var text_input = Control.new()
					text_input.name = "TextInput"
					node.add_child(text_input)
					
					components.text_input.rendered = true
					
					if components.text_input.has("terminal") == false or components.text_input.terminal == false:
						connect("submit", components.text_input.object, components.text_input.method, [id])
					#Entity.edit(id, components)
				if event is InputEventKey and event.pressed:
					if event.scancode == KEY_ENTER:
						emit_signal("submit")
					components.text_input.text += event.as_text()
					
					if components.text_input.has("terminal") and components.text_input.terminal:
						components.terminal.text += event.as_text()
						components.terminal.text_rendered = false
					Entity.edit(id, components)
	
	var entities = Entity.get_entities_with("player")
	for id in entities:
		var components = entities[id].components
		if components.player.rendered == true:
			var head = get_node("/root/Entity/" + str(id) + "/Player/Head")
			var camera = get_node("/root/Entity/" + str(id) + "/Player/Head/Camera")
			
			if event is InputEventMouseMotion:
				#if Hud.analog_is_pressed == false:
				head.rotate_y(deg2rad(-event.relative.x * Player.mouse_sensitivity))
				
				var change = -event.relative.y * Player.mouse_sensitivity
				if change + Player.camera_angle < 90 and change + Player.camera_angle > -90:
					camera.rotate_x(deg2rad(change))
					Player.camera_angle += change
				
			elif event.is_action_pressed("action"):
				Debug.msg("Action pressed!", "Debug")
				Player.action(id, OS.get_window_size() / 2)
			
			#player.translation = components.player.position
			#components.player.rendered = true
			#Entity.edit(id, components)
	
	
	if event.is_action_pressed("fly"):
		pass
		#if move_mode == "walk":
			#Debug.msg("Changing move_mode to fly...", "Info")
			#move_mode = "fly"
			#get_node("Capsule").disabled = true
		#else:
			#Debug.msg("Changing move_mode to walk...", "Info")
			#move_mode = "walk"
			#get_node("Capsule").disabled = false
	
	if event.is_action_pressed("break"):
		#action(OS.get_window_size() / 2)
		Debug.msg("Break pressed!", "Debug")
	
	if event is InputEventScreenTouch:
		pass
		#action(event.position)
	
	if event.is_action_pressed("burn"):
		Debug.msg("Changing action_mode to burn...", "Info")
		#action_mode = "burn"
		#Debug.switch_mode("burn")
		
	if event.is_action_pressed("mine"):
		Debug.msg("Changing action_mode to mine...", "Info")
		#action_mode = "mine"
		#Debug.switch_mode("mine")
		
	if event.is_action_pressed("build"):
		Debug.msg("Changing action_mode to build...", "Info")
		#action_mode = "build"
		#Debug.switch_mode("build")
		
	if event.is_action_pressed("paint"):
		Debug.msg("Changing action_mode to paint...", "Info")
		#action_mode = "paint"
		#Debug.switch_mode("paint")


################################## functions ##################################

func _stop_player(player):
	player.stop()
	player.queue_free()