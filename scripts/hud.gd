extends Control

############################## public variables ###############################

var analog_is_pressed = false
var frames_passed = 0
var workspace = "game"




################################### signals ###################################

func _ready(): ################################################################
	load_debug_screen()


func _process(delta): #########################################################
	if has_node("/root/World/Player"):
		var Player = get_node("/root/World/Player")
		var World = get_node("/root/World")
		var XYZ = find_node("Player XYZ")
		XYZ.set_text("XYZ: " + str(Player.translation))
		#msg(str(round_vector3(Player.translation, 2.0)), "Trace")
		
		var chunk_address = find_node("Chunk Address")
		chunk_address.set_text(" == " + str(World.get_chunk(Player.translation)) + " == ")
		
		var chunk_position = find_node("Chunk XYZ")
		#chunk_position.set_text("XYZ: " + str(World.ChunkAddresses[Vector2(World.get_chunk(Player.translation).x, World.get_chunk(Player.translation).z)]))
		
		var looking_position = find_node("Looking XYZ")
		looking_position.set_text("Looking at: XYZ: " + str(Player.get_looking_at(OS.get_window_size() / 2)))
		
		var looking_chunk = find_node("Looking at Chunk")
		looking_chunk.set_text("Looking at chunk: XYZ: " + str(World.get_chunk(Player.get_looking_at(OS.get_window_size() / 2))))
		
		var orentation = find_node("Orentation")
		orentation.set_text("Orentation: " + Player.get_orientation())
		
		var mode = find_node("Mode")
		mode.set_text("Mode: " + Player.action_mode)
		
		var entities = find_node("Entities")
		entities.set_text("Entities: " + str(World.total_entities) + " | Players: " + str(World.total_players))
		
		var fps = find_node("FPS")
		fps.set_text("FPS: " + str(Engine.get_frames_per_second()))
	
	frames_passed+=1
	if frames_passed > 100:
		load_debug_screen()
		frames_passed = 0

func _on_AnalogTop_button_down():
	analog_is_pressed = true


func _on_AnalogTop_button_up():
	analog_is_pressed = false
	Input.action_release("move_forward")
	Input.action_release("move_backward")


func _input(event): ###########################################################
	if event is InputEventScreenDrag:
		if analog_is_pressed:
			msg("Touching the Analog stick", "Debug")
			msg(str(event.position), "Debug")
			var analog_center = Vector2(200, 870)
			var analog_bounds = Vector2(100, 100)
			
			if abs(abs(event.position) - abs(analog_center)) < analog_bounds:
				get_node("HUD/HorizontalMain/VerticalMain/Navbox/TextureRect/AnalogTop").position = event.position
				if event.position > analog_center:
					Input.action_press("move_forward")
				else:
					Input.action_press("move_backward")
	if event is InputEventScreenTouch:
		msg("Touched the screen at: " + str(event.position), "Debug")

func _on_BurnButton_toggled(button_pressed): ##################################
	msg("Changing action_mode to burn...", "Info")
	get_node("/root/World/Player").action_mode = "burn"
	
	switch_mode("burn")


func _on_MineButton_toggled(button_pressed): ##################################
	msg("Changing action_mode to mine...", "Info")
	get_node("/root/World/Player").action_mode = "mine"
	
	switch_mode("mine")


func _on_BuildButton_toggled(button_pressed): #################################
	msg("Changing action_mode to build...", "Info")
	get_node("/root/World/Player").action_mode = "build"
	switch_mode("build")


func _on_PaintButton_toggled(button_pressed): #################################
	msg("Changing action_mode to paint...", "Info")
	get_node("/root/World/Player").action_mode = "paint"
	
	switch_mode("paint")


func _on_OptionsButton_toggled(button_pressed): ###############################
	msg("Opening pause workspace...", "Info")
	if button_pressed:
		get_node("HorizontalMain/VerticalMain/VerticalCenterContent/PauseWindow").visible = true
		get_node("HorizontalMain/VerticalMain/Navbox").visible = false
		get_node("Chat").visible = false
	else:
		get_node("PauseWindow").visible = false
		get_node("HorizontalMain/VerticalMain/Navbox").visible = true
		get_node("Chat").visible = true

func _on_ExitButton_pressed():
	msg("Loading main menu...", "Info")
	get_tree().change_scene("res://scene/main_menu.tscn")



################################## functions ##################################

func switch_mode(mode):
	if mode == "burn":
		if get_node("HorizontalMain/Toolbox/BurnButton").pressed:
			get_node("HorizontalMain/Toolbox/BurnButton").pressed = true
		else:
			get_node("HorizontalMain/Toolbox/BurnButton").pressed = false
		
	elif mode == "mine":
		if get_node("HorizontalMain/Toolbox/MineButton").pressed:
			get_node("HorizontalMain/Toolbox/MineButton").pressed = true
		else:
			get_node("HorizontalMain/Toolbox/MineButton").pressed = false
		
	elif mode == "build":
		if get_node("HorizontalMain/Toolbox/BuildButton").pressed:
			get_node("HorizontalMain/Toolbox/BuildButton").pressed = true
		else:
			get_node("HorizontalMain/Toolbox/BuildButton").pressed = false
	
	elif mode == "paint":
		if get_node("HorizontalMain/Toolbox/PaintButton").pressed:
			get_node("HorizontalMain/Toolbox/PaintButton").pressed = true
		else:
			get_node("HorizontalMain/Toolbox/PaintButton").pressed = false

func round_vector3(vector, places): ###########################################
	#var x = round(vector.x * pow(10.0, places)) / pow(10.0, places)
	#var y = round(vector.y * pow(10.0, places)) / pow(10.0, places)
	#var z = round(vector.z * pow(10.0, places)) / pow(10.0, places)
	var x = stepify(vector.x, places)
	var y = stepify(vector.y, places)
	var z = stepify(vector.z, places)
	
	return Vector3(x, y, z)


func load_debug_screen(): ####################################################
	if has_node("/root/World"):
		var World = get_node("/root/World")
		
		var version = find_node("Version")
		version.set_text(World.version)
		
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
		
		var chunks_loaded = find_node("Chunks Loaded")
		chunks_loaded.set_text("Chunks loaded: " + str(World.loaded_chunks))
		
		var map_seed = find_node("Seed")
		map_seed.set_text("Seed: " + str(World.map_seed))


func fetch_client_version(): ##################################################
	#var file = File.new()
	#if file.open("res://version.txt", File.READ) != 0:
	#	msg("Error reading client version.", "Error")
	
	#return file.get_as_text()
	var World = get_node("/root/World")
	return World.version


func show_msg(message, tag): ##################################################
	#if get_tree().get_root().has_node("/root/Main Menu/World/HUD/Chat"):
	#	var Chat = get_tree().get_root().get_node("/root/Main Menu/World/HUD/Chat")
	#	Chat.add_text(tag + ": " + str(message) + '\n')
	
	if has_node("HorizontalMain/VerticalMain/VerticalCenterContent/Chat"):
		var Chat = get_node("HorizontalMain/VerticalMain/VerticalCenterContent/Chat")
		Chat.add_text(tag + ": " + str(message) + '\n')


func msg(message, tag): #######################################################
	print(tag, ": ", message)
	show_msg(message, tag)



