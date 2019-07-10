extends Node

var version = "EdenUniverseBuilder v3.0.0 beta5"
var loaded = false
var player_teleported = false
var total_players = 0
var players = Array()
var total_entities = 0
var first_chunk = Vector3(0, 0, 0)
var blocks_loaded = 0
var blocks_found = 0
var total_chunks = 0
var chunks_cache_size = 0
var loaded_chunks = 0
var chunk_index = []
var temp_player_chunk = Vector3(0, 0, 0)


var map_file = File.new()
var ChunkLocations = Dictionary()
var ChunkAddresses = Dictionary()
var ChunkMetadata = Array()


var worldAreaX = 0
var worldAreaY = 0
var worldAreaWidth = 0
var worldAreaHeight = 0

var player_move_forward = false


var local_data = {}
const DEFAULT_HOST = "josephtheengineer.ddns.net"
const DEFAULT_IP = "101.183.54.6"
const DEFAULT_PORT = 8888
const DEFAULT_MAX_PLAYERS = 100

const MAIN_MENU_SEED = -1


# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Ari", color = Color8(255, 0, 255) }

################################### signals ###################################

func _ready(): #################################################################
	Debug.msg("Client System ready.", "Info")
	Debug.msg("Logs stored at user://logs/", "Info")
	Debug.init()
	Diagnostics.run(self, "diagnostics_finised")
	
	#if ServerSystem.map_seed == MAIN_MENU_SEED:
	#	init_main_menu()
	#else:
	#	init_world()
	#
	#InterfaceSystem.process_interface()
	
	# Networking
	#get_tree().connect("network_peer_connected", self, "_player_connected")
	#get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	#get_tree().connect("connected_to_server", self, "_connected_ok")
	#get_tree().connect("connection_failed", self, "_connected_fail")
	#get_tree().connect("server_disconnected", self, "_server_disconnected")

func diagnostics_finised():
	ServerSystem.start()
	ServerSystem.load_world(self, "world_loaded")

func world_loaded():
	Debug.msg("World loaded!", "Info")
	
	var player = Dictionary()
	player.rendered = false
	player.position = Vector3(0, 60, 0)
	player.username = "JosephTheEngineer"
	player.object = Player
	
	var player_id = Entity.create({"player" : player})
	
	# Create HUD
	var hud = Dictionary()
	var hud_id = Entity.create({"hud" : hud})
	
	
	var horizontal_container = Dictionary()
	horizontal_container.parent = Dictionary()
	horizontal_container.parent.id = hud_id
	horizontal_container.parent.component = "hud"
	var horizontal_id = Entity.create({"horizontal_container" : horizontal_container})
	
	var vertical_container = Dictionary()
	vertical_container.parent = Dictionary()
	vertical_container.parent.id = horizontal_id
	vertical_container.parent.component = "horizontal_container"
	var vertical_id = Entity.create({"vertical_container" : vertical_container})
	
	var toolbox = Dictionary()
	toolbox.parent = Dictionary()
	toolbox.parent.id = horizontal_id
	toolbox.parent.component = "horizontal_container"
	var toolbox_id = Entity.create({"toolbox" : toolbox})
	
	
	var navbox = Dictionary()
	navbox.min_size = Vector2(0, OS.get_screen_size().y * 1/3)
	navbox.parent = Dictionary()
	navbox.parent.id = vertical_id
	navbox.parent.component = "vertical_container"
	var navbox_id = Entity.create({"horizontal_container" : navbox})
	
	var gamearea = Dictionary()
	gamearea.parent = Dictionary()
	gamearea.parent.id = vertical_id
	gamearea.parent.component = "vertical_container"
	var gamearea_id = Entity.create({"horizontal_container" : gamearea})
	
	
	var joystick = Dictionary()
	joystick.parent = Dictionary()
	joystick.parent.id = navbox_id
	joystick.parent.component = "horizontal_container"
	var joystick_id = Entity.create({"joystick" : joystick})

func init_main_menu():
	ChunkSystem.create_chunk(Vector3(0, 0, 0))

func init_world():
	var t = OS.get_unix_time()
	Debug.msg("Init took " + str(OS.get_unix_time()-t), "Info")

func _process(delta): #########################################################
	var entities = Entity.get_entities_with("player")
	for id in entities:
		var components = entities[id].components
		if components.player.rendered == false:
			var node = get_node("/root/Entity/" + str(id))
			
			var player = load("res://scenes/player.tscn").instance()
			node.add_child(player)
			
			player.translation = components.player.position
			components.player.rendered = true
			Entity.edit(id, components)
	
	
	
#	if ServerSystem.map_seed != -1 and Player != null:
#		if loaded == true and player_teleported == false:
#			Player.translation =  first_chunk
#			player_teleported = true
#
#		var player_chunk = get_chunk(Player.translation)
#		if player_chunk != temp_player_chunk:
#			print(player_chunk)
#			temp_player_chunk = player_chunk
		
		#if !(chunk_index.has(get_chunk(Player.translation))):
		#create_surrounding_chunks(get_chunk(Player.translation))
		#create_surrounding_chunks(get_chunk(Player.translation))
	#else:
		#pass
		#create_surrounding_chunks(get_chunk(Vector3(0, 0, 0)))


func _player_connected(id): ###################################################
	Debug.msg("User " + str(id) + " connected", "Info")
	Debug.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _player_disconnected(id): ################################################
	player_info.erase(id) # Erase player from info
	
	Debug.msg("User " + str(id) + " connected", "Info")
	Debug.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _connected_ok(): #########################################################
	# Only called on clients, not server. Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected(): ##################################################
	Debug.msg("Kicked from server!", "Info")


func _connected_fail(): #######################################################
	Debug.msg("Error connecting to server! ", "Error")


func _on_packet_received(id, packet): #########################################
	Debug.msg(packet.get_string_from_ascii(), "Chat")


func _on_ForwardButton_pressed(): #############################################
	player_move_forward = true


func _on_ForwardButton_released(): ############################################
	player_move_forward = false




################################## functions ##################################




############################ networking functions #############################


func join_server(username, address): ###################################################
	Debug.msg("Joining server...", "Info")
	var host = address.rsplit(":")[0]
	var port = null
	if address.rsplit(":").size() > 1:
		port = address.rsplit(":")[1]
	
	if host == null or host == "":
		host = DEFAULT_HOST
	if port == null or host == "":
		port = DEFAULT_PORT
	
	var network = NetworkedMultiplayerENet.new()
	Debug.msg("Connecting to host " + str(host) + ":" + str(port), "Info")
	Debug.msg("Client status: " + str(network.create_client(host, port)), "Debug")
	
	get_tree().set_network_peer(network)
	network.connect("connection_failed", self, "_on_connection_failed")
	
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received")
	get_tree().set_meta("network_peer", network)


func leave_server(): ##########################################################
	get_tree().set_network_peer(null)


func _on_connection_failed(error):
	Debug.msg("Error connecting to server: " + error, "Error")


func send_message(msg): #######################################################
	rpc("send_data", msg)




############################## remote functions ###############################

remote func send_data(data): ##################################################
	Debug.msg(data, "Chat")


remote func register_player(id, info): ########################################
	Debug.msg("Player info: " + str(info), "Info")
	# Store the info
	player_info[id] = info
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
		#Send my info to new player
		rpc_id(id, "register_player", 1, my_info)
		# Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])

func world_button(world):
	pass
	#if world == 1:
		#Debug.msg("Opening world creation menu...", "Info")
		#create_new_world()
		#Debug.msg("Loading a new flat terrain world...", "Info")
		#map_path = ""
		#map_name = "New Flat Terrain World"
		#map_seed = 0
		#load_world()
	#elif world == 3:
		#pass
	#else:
		#Debug.msg("Loading a new natural terrain world...", "Info")
		#map_path = ""
		#map_name = "New Natural Terrain World"
		#map_seed = floor(rand_range(0, 9999999))
		#load_world()