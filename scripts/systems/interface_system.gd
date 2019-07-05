extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Debug.msg("Interface System ready.", "Info")

func _process(delta):
	var entities = Entity.get_entities_with("terminal")
	for id in entities:
		if get_node("/root/Entity/" + str(id)):
			var components = entities[id].components
			if components.terminal.rendered == false:
				var node = get_node("/root/Entity/" + str(id))
				
				var terminal = load("res://scenes/terminal.tscn").instance()
				node.add_child(terminal)
				
				get_node("/root/Entity/" + str(id) + "/Terminal").rect_position = components.terminal.position
				get_node("/root/Entity/" + str(id) + "/Terminal/Text").text = components.terminal.text
				components.terminal.rendered = true
				Entity.edit(id, components)
			if components.terminal.has("text_rendered"):
				if components.terminal.text_rendered == false:
					get_node("/root/Entity/" + str(id) + "/Terminal/Text").text = components.terminal.text
					components.terminal.text_rendered = true
					Entity.edit(id, components)
	
	entities = Entity.get_entities_with("hud")
	for id in entities:
		if get_node("/root/Entity/" + str(id)):
			if Entity.get_component(id, "hud.rendered"):
				process_hud(id)
			else:
				Debug.msg("Creating HUD...", "Info")
				create_hud(id)

func process_child_components(id, container, component):
	var children = Entity.get_component(id, component + ".components").keys()
	
	for name in children:
		var type = name.split("0", false)[0]
		
		if type == "vertical_container":
			if Entity.get_component(id, component + ".components." + name + ".rendered"):
				process_vertical_container(id, container, component + ".components." + name)
			else:
				create_vertical_container(id, container, component + ".components." + name)
				
				Entity.set_component(id, component + ".components." + name + ".rendered", true)
		
		elif type == "horizontal_container":
			if Entity.get_component(id, component + ".components." + name + ".rendered"):
				process_horizontal_container(id, container, component + ".components." + name)
			else:
				create_horizontal_container(id, container, component + ".components." + name)
				
				Entity.set_component(id, component + ".components." + name + ".rendered", true)
		
		elif type == "joystick":
			if Entity.get_component(id, component + ".components." + name + ".interface_system"):
				process_joystick(container)
			else:
				create_joystick(container)
				
				Entity.set_component(id, component + ".components." + name + ".interface_system", true)
		
		elif type == "toolbox":
			if Entity.get_component(id, component + ".components." + name + ".rendered"):
				process_toolbox(container)
			else:
				create_toolbox(container)
				
				Entity.set_component(id, component + ".components." + name + ".rendered", true)
		
		#elif type == "terminal":
			#if Entity.get_component(id, component + ".components." + name + ".rendered"):
				#process_toolbox(container)
			#else:
				#create_toolbox(container)
				
				#Entity.set_component(id, component + ".components." + name + ".rendered", true)

func create_hud(id):
	var node = get_node("/root/Entity/" + str(id))
	
	var hud = Control.new()
	hud.name = "Hud"
	hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hud.anchor_right = 1
	hud.anchor_bottom = 1
	node.add_child(hud)
	
	process_child_components(id, hud, "hud")
	
	Entity.set_component(id, "hud.rendered", true)

func process_hud(id):
	process_child_components(id, get_node("/root/Entity/" + str(id) + "/Hud"), "hud")

func create_vertical_container(id, parent, path):
	var vertical_container = VBoxContainer.new()
	vertical_container.name = "VerticalContainer"
	vertical_container.rect_min_size.y = 300
	vertical_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vertical_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vertical_container.anchor_right = 1
	vertical_container.anchor_bottom = 1
	parent.add_child(vertical_container)
	
	process_child_components(id, vertical_container, path)

func process_vertical_container(id, parent, path):
	pass

func create_horizontal_container(id, parent, path):
	var horizontal_container = HBoxContainer.new()
	horizontal_container.name = "HorizontalContainer"
	horizontal_container.rect_min_size.y = 300
	horizontal_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_container.anchor_right = 1
	horizontal_container.anchor_bottom = 1
	parent.add_child(horizontal_container)
	
	process_child_components(id, horizontal_container, path)

func process_horizontal_container(id, parent, path):
	pass

func create_joystick(parent):
	var joystick = load("res://scenes/joystick.tscn").instance()
	parent.add_child(joystick)

func process_joystick(parent):
	pass

func create_toolbox(parent):
	var toolbox = load("res://scenes/toolbox.tscn").instance()
	parent.add_child(toolbox)

func process_toolbox(parent):
	pass

#################################### Main Menu stuff ####################################

onready var Home = get_node("/root/Main Menu/UI/Home")
onready var Leaderboard = get_node("/root/Main Menu/UI/Leaderboard")
onready var WorldSharing = get_node("/root/Main Menu/UI/WorldSharing")
onready var Credits = get_node("/root/Main Menu/UI/Credits")
onready var AccountPage = get_node("/root/Main Menu/UI/AccountPage")
onready var Options = get_node("/root/Main Menu/UI/Options")

onready var TitleScreenPlayer = get_node("TitleScreen/AnimationPlayer")




############################## public variables ###############################

onready var world_template = preload("res://scenes/world.tscn")
onready var dot_template = preload("res://scenes/dot.tscn")

const info = [ "changelog.md", "featured-worlds.md", "game-stats.md", "info.md", "news.md", "new-worlds.md", "top-users.md", "top-worlds.md" ]

var workspace = "home"
var positions = Dictionary()
var ui_snaped = true
var snaped_position = Vector2(0, 0)
var ui_just_moved = false
var ui_snaping = false
var distance_to_move = Vector2(0, 0)
var distance_moved = Vector2(0, 0)

var fetch_data_request = HTTPRequest.new()
var file_progress = 0

var loader
var wait_frames
var time_max = 100 # msec
var current_scene
var process = false
var main_menu = true
var background_pressed = false
var search_is_focused = false

const TITLE_SCREEN = 0
const HOME = 1
const LEADERBOARD = 2
const WORLD_SHARING = 3
const CREDITS = 4
const ACCOUNT = 5
const PAUSE = 10
const BUILD = 11
const PAINT = 12
const CHAT = 13
const NAVBAR = 14
const TOOLBOX = 15

var current_interface = [ TITLE_SCREEN ]

func change_interface(interfaces):
	for interface in interfaces:
		pass
		#load_scene interface/main_menui

func process_interface(): ################################################################
	
	
	
	
	
	if get_node("/root/MainMenu/TitleScreen").visible == false:
		get_node("/root/MainMenu/TitleScreen").visible = true
		get_node("/root/MainMenu/UI").visible = false
	
	
	#TitleScreenPlayer.play("TitleScreen")
	
	# get current scene for the scene loader
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	
	# initialize the background scene
	#World = world_template.instance()
	#World.map_seed = -1
	#add_child(World)
	#draw_dots()
	Debug.msg("Starting logs...", "Info")
	
	# fetch data from the website for the main menu
	#fetch_data()
	
	var world_data = Dictionary()
	world_data[1] = "New World"
	world_data[2] = "Test World"
	world_data[3] = "Direct City"
	
	var parent = get_node("UI/Home/VBoxContainer/TopContainer/Planets/Foreground")
	show_world_list(parent, world_data, true)


func process(delta): #########################################################
	#update_positions()
	if Input.is_action_just_pressed("action"):
		background_pressed = true
	if Input.is_action_just_released("action"):
		background_pressed = false
		if ui_just_moved:
			ui_snaped = false
	
	if ui_snaped == false:
		var closest_position = Vector2(0, 0)
		for position in positions.values():
			if abs(position.x - get_node("UI").rect_position.x) <= abs(closest_position.x - get_node("UI").rect_position.x):
				if abs(position.y - get_node("UI").rect_position.y) <= abs(closest_position.y - get_node("UI").rect_position.y):
					closest_position = position
		snaped_position = closest_position
		ui_snaped = true
	
	if distance_moved < distance_to_move:
		var distance_to_move_sub = Vector2(0, 0)
		distance_to_move_sub.x = round(distance_to_move.x / 4)
		distance_to_move_sub.y = round(distance_to_move.y / 4)
		if distance_to_move_sub < Vector2(1, 1):
			distance_to_move_sub = Vector2(1, 1)
	
	
	if process:
		if loader == null:
			Debug.msg("Loader was null!", "Debug")
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
				Debug.msg("Removing old scene...", "Debug")
				get_node("UI/LoadingContainer").visible = false
				current_scene.queue_free() # get rid of the old scene
				Debug.msg("Setting new scene...", "Debug")
				set_new_scene(resource)
				break
			elif err == OK:
				update_progress()
			else: # error during loading
				Debug.msg("Error during loading", "Error")
				loader = null
			break


func _on_AnimationPlayer_animation_finished(anim_name): #######################
	pass
	#if anim_name == "TitleScreen":
		#get_node("TitleScreen/AnimationPlayer").play("TitleScreenFlashingText")
	#if anim_name == "TitleScreenFlashingText":
		#get_node("TitleScreen/AnimationPlayer").play("TitleScreenFlashingText")


func _on_CreateServerButton_pressed(): ########################################
	World.create_server("server")


func _on_JoinServerButton_pressed(): ##########################################
	pass
	#var address = get_node("UI/Home/VBoxContainer/TopContainer/Chat/VBoxContainer/Row1/Column1/Input").text
	#World.join_server("player", address)


func _on_SendButton_pressed(): ################################################
	Debug.msg("Sending message...", "Info")
	World.send_message("Hello!")


func _on_SharedWorlds_released(): #############################################
	Debug.msg("Shared worlds are not implemented yet!", "Warn")
	


func _on_OptionsButton_pressed(): #############################################
	Home.visible = false
	Options.visible = true
	workspace = "options"


func _on_OptionsBackButton_pressed(): #########################################
	Options.visible = false
	Home.visible = true
	workspace = "home"


func _input(event): ###########################################################
	if event is InputEventScreenDrag:
		#get_node("UI").rect_position += event.relative
		#music_player.translation += Vector3(event.relative.x, event.relative.y, 0) / 100
		ui_just_moved = true
	if event is InputEventMouseMotion:
		if background_pressed:
			#get_node("UI").rect_position += event.relative
			#music_player.translation += Vector3(event.relative.x, event.relative.y, 0) / 100
			ui_just_moved = true
	if event is InputEventScreenTouch:
		if get_node("TitleScreen").visible:
			
			var music_player = AudioStreamPlayer3D.new()
			var audio = load("res://sounds/engineer/271945__rodincoil__stingers-001.ogg")
			audio.loop = false
			music_player.stream = audio
			music_player.unit_db = 1
			music_player.connect("finished", self, "_stop_player", [music_player])
			add_child(music_player)
			music_player.play()
			
			get_node("TitleScreen").visible = false
			get_node("UI").visible = true
			
	if event.is_action_pressed("action"):
		pass
		#if get_node("TitleScreen").visible:
			
			#var music_player = AudioStreamPlayer3D.new()
			#var audio = load("res://sounds/engineer/271945__rodincoil__stingers-001.ogg")
			#audio.loop = false
			#music_player.stream = audio
			#music_player.unit_db = 1
			#music_player.connect("finished", self, "_stop_player", [music_player])
			#add_child(music_player)
			#music_player.play()
			
			#get_node("TitleScreen").visible = false
			#get_node("UI").visible = true
	if event.is_action_pressed("ui_accept"):
		if search_is_focused:
			pass



################################## functions ##################################

func update_positions():
	var screen_size = get_node("UI").rect_size
	positions["home"] = Vector2(0, 0)
	positions["leaderboard"] = Vector2(0, screen_size.y)
	positions["world_sharing"] = Vector2(-screen_size.x, 0)
	positions["credits"] = Vector2(0, -screen_size.y)
	positions["account_page"] = Vector2(+screen_size.x, 0)

func show_world_list(parent, world_data, is_downloaded):
	for path in world_data.keys():
		var content = HBoxContainer.new()
		content.rect_min_size = Vector2(0, 125)
		#parent.add_child(content)
		
		var button = TextureButton.new()
		button.texture_normal = load("res://textures/tnt_side.png")
		button.texture_hover = load("res://textures/fireworks_side.png")
		button.texture_pressed = load("res://textures/steel.png")
		button.rect_min_size = Vector2(120, 0)
		button.expand = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		content.add_child(button)
		if is_downloaded:
			button.connect("pressed", self, "world_button", [path])
		else:
			button.connect("pressed", self, "download_world_button", [path])
		
		var seperator = VSeparator.new()
		seperator.rect_min_size = Vector2(20, 0)
		content.add_child(seperator)
		
		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_FILL
		label.text = world_data[path]
		label.set("custom_fonts/font", load("res://fonts/header.tres"))
		content.add_child(label)

func create_new_world():
	Debug.msg("World creation menu", "Debug")
	add_child(load("res://scenes/new_world_panel.tscn").instance())

func draw_dots(): #############################################################
	for x in range(OS.get_window_size().x / 10):
		for y in range(OS.get_window_size().y / 10):
			var dot = dot_template.instance()
			get_node("/root/Main Menu/UI/Background").add_child(dot)
			dot.rect_position = Vector2(x*40, y*40)


func update_progress(): #######################################################
	Debug.msg("Updating progress...", "Debug")
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# Update your progress bar?
	#get_node("progress").set_progress(progress)
	
	# ... or update a progress animation?
	var length = get_node("AnimationPlayer").get_current_animation_length()
	
	# Call this on a paused animation. Use "true" as the second argument to force the animation to update.
	get_node("AnimationPlayer").seek(progress * length, true)


func set_new_scene(scene_resource): ###########################################
	current_scene = scene_resource.instance()
	#current_scene.map_seed = map_seed
	#current_scene.map_path = map_path
	#current_scene.map_name = map_name
	get_node("/root").add_child(current_scene)


func load_world(): ############################################################
	Debug.msg("Changing scene to world.tscn...", "Info")
	var path = "res://scenes/world.tscn"
	
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		Debug.msg("Loader was null!", "Error")
		return
	process = true
	
	get_node("UI/LoadingContainer").visible = true
	
	# start your "loading..." animation
	Debug.msg("Starting animation...", "Debug")
	get_node("AnimationPlayer").play("Loading")
	
	wait_frames = 10

func _on_SwipeDetector_swiped(direction): #####################################
	Debug.msg("Swipe signal received!", "Info")


func _on_search_focus_entered():
	search_is_focused = true


func _on_search_focus_exited():
	search_is_focused = false