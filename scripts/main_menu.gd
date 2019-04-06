extends Spatial

############################## public variables ###############################

onready var world_template = preload("res://scenes/world.tscn")
onready var dot_template = preload("res://scenes/dot.tscn")
var World
var Hud


var loader
var wait_frames
var time_max = 100 # msec
var current_scene
var process = false
var main_menu = true




################################### signals ###################################

func _ready(): ################################################################
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
	#$UI/Menu/LoadButton.grab_focus()
	World = world_template.instance()
	World.map_seed = -1
	#Hud = get_node("/root/Main Menu")
	#World.Hud = Hud
	add_child(World)
	draw_dots()
	msg("Starting logs...", "Info")


func _process(delta): #########################################################
	if Input.is_action_just_pressed("load_world"):
		pass
	if Input.is_action_just_pressed("create_server"):
		World.create_server("server")
	if Input.is_action_just_pressed("join_server"):
		World.join_server("player")
	if Input.is_action_just_pressed("send_data"):
		msg("Sending message...", "Info")
		World.send_message("Hello!")
	
	if process:
		if loader == null:
			msg("Loader was null!", "Debug")
			# no need to process anymore
			process = false
			return
		
		if wait_frames > 0: # wait for frames to let the "loading" animation show up
			wait_frames -= 1
			return
		
		var t = OS.get_ticks_msec()
		while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread
			
			# poll your loader
			var err = loader.poll()
			
			if err == ERR_FILE_EOF: # Finished loading.
				var resource = loader.get_resource()
				loader = null
				msg("Removing old scene...", "Debug")
				get_node("UI/LoadingContainer").visible = false
				current_scene.queue_free() # get rid of the old scene
				msg("Setting new scene...", "Debug")
				set_new_scene(resource)
				#if main_menu:
					#msg("Removing scene...", "Debug")
					#current_scene.queue_free() # get rid of the old scene
					#main_menu = false
				break
			elif err == OK:
				update_progress()
			else: # error during loading
				msg("Error during loading", "Error")
				loader = null
			break


func _on_CreateServerButton_pressed(): ########################################
	World.create_server("server")


func _on_JoinServerButton_pressed(): ##########################################
	World.join_server("player")


func _on_SendButton_pressed(): ################################################
	msg("Sending message...", "Info")
	World.send_message("Hello!")


func _on_SharedWorlds_released(): #############################################
	msg("Shared worlds are not implemented yet!", "Warn")
	

func _on_NewFlatWorldButton_pressed(): ########################################
	msg("Loading a new flat terrain world...", "Info")
	#World.map_path = ""
	#World.map_name = "New Flat Terrain World"
	#World.map_seed = 0
	load_world()


func _on_NewNaturalTerrainButton_pressed(): ###################################
	msg("Loading a new natural terrain world...", "Info")
	#World.map_path = ""
	#World.map_name = "New Natural Terrain World"
	#World.map_seed = 8901627346
	load_world()


func _on_TestWorldButton_pressed(): ###########################################
	pass # replace with function body


func _on_DirectCityButton_pressed(): ##########################################
	pass # replace with function body


func _on_OptionsButton_pressed(): #############################################
	pass # Replace with function body.




################################## functions ##################################

func draw_dots(): #############################################################
	for x in range(OS.get_window_size().x / 10):
		for y in range(OS.get_window_size().y / 10):
			var dot = dot_template.instance()
			get_node("/root/Main Menu/UI/Background").add_child(dot)
			dot.rect_position = Vector2(x*40, y*40)


func update_progress(): #######################################################
	msg("Updating progress...", "Debug")
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# Update your progress bar?
	#get_node("progress").set_progress(progress)
	
	# ... or update a progress animation?
	var length = get_node("AnimationPlayer").get_current_animation_length()
	
	# Call this on a paused animation. Use "true" as the second argument to force the animation to update.
	get_node("AnimationPlayer").seek(progress * length, true)


func set_new_scene(scene_resource): ###########################################
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)


func load_world(): ############################################################
	msg("Changing scene to world.tscn...", "Info")
	var path = "res://scenes/world.tscn"
	
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		msg("Loader was null!", "Error")
		return
	process = true
	
	get_node("UI/LoadingContainer").visible = true
	
	# start your "loading..." animation
	msg("Starting animation...", "Debug")
	get_node("AnimationPlayer").play("Loading")
	
	wait_frames = 60


func show_msg(message, tag): ##################################################
	#if get_tree().get_root().has_node("/root/Main Menu/World/HUD/Chat"):
	#	var Chat = get_tree().get_root().get_node("/root/Main Menu/World/HUD/Chat")
	#	Chat.add_text(tag + ": " + str(message) + '\n')
	
	if get_tree().get_root().has_node("/root/Main Menu/UI/Home/VBoxContainer/TopContainer/Chat/VBoxContainer/Chat"):
		var Chat = get_tree().get_root().get_node("/root/Main Menu/UI/Home/VBoxContainer/TopContainer/Chat/VBoxContainer/Chat")
		Chat.add_text(tag + ": " + str(message) + '\n')
		
	elif get_tree().get_root().has_node("/root/World/HUD/Chat"):
		var Chat = get_tree().get_root().get_node("/root/World/HUD/Chat")
		Chat.add_text(tag + ": " + str(message) + '\n')


func msg(message, tag): #######################################################
	print(tag, ": ", message)
	show_msg(message, tag)



