extends Spatial

############################## public variables ###############################

onready var chunk_template = preload("res://scenes/chunk.tscn")
onready var player_template = preload("res://scenes/player.tscn")


onready var Player = null
onready var World = null
onready var Hud = get_node("HUD")


var version = "Eden: Universe Builder v3.0.0 beta4"
var map_seed = 0
var map_path = "res://worlds/direct_city.eden2"
var map_name = "direct_city.eden2"
#var map_path = "res://worlds/test_world.eden2"
#var map_name = "test_world.eden2"
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
var chunk_index = {}
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
const DEFAULT_IP = "josephtheengineer.ddns.net";
const DEFAULT_PORT = 8888
const DEFAULT_MAX_PLAYERS = 100


# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Ari", color = Color8(255, 0, 255) }




################################### signals ###################################

func _ready(): #################################################################
	if map_seed != -1:
		var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
		World = get_node("/root/World")
		EdenWorldDecoder.World = World
		EdenWorldDecoder.set_vars()
		EdenWorldDecoder.init_world()
		
		Player = player_template.instance()
		Player.World = World
		add_child(Player)
	else:
		World = get_node("/root/Main Menu/World")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	create_world(2, 1)
	
	# Networking
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	
	Hud.msg("Staring...", "Debug")


func _process(delta): #########################################################
	if (Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
	
	if map_seed != -1 and Player != null:
		if loaded == true and player_teleported == false:
			Player.translation =  first_chunk
			player_teleported = true
		
		var player_chunk = get_chunk(Player.translation)
		if player_chunk != temp_player_chunk:
			print(player_chunk)
			temp_player_chunk = player_chunk
	
		#if !(chunk_index.has(get_chunk(Player.translation))):
		#create_surrounding_chunks(get_chunk(Player.translation))
		create_surrounding_chunks(get_chunk(Player.translation))
	else:
		create_surrounding_chunks(get_chunk(Vector3(0, 0, 0)))


func _player_connected(id): ###################################################
	Hud.msg("User " + str(id) + " connected", "Info")
	Hud.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _player_disconnected(id): ################################################
	player_info.erase(id) # Erase player from info
	
	Hud.msg("User " + str(id) + " connected", "Info")
	Hud.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _connected_ok(): #########################################################
	# Only called on clients, not server. Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected(): ##################################################
	Hud.msg("Kicked from server!", "Info")


func _connected_fail(): #######################################################
	Hud.msg("Error connecting to server! ", "Error")


func _peer_connected(id): #####################################################
	Hud.msg("User " + str(id) + " connected", "Info")
	Hud.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _peer_disconnected(id): ##################################################
	Hud.msg("User " + str(id) + " disconnected", "Info")
	Hud.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _on_packet_received(id, packet): #########################################
	Hud.msg(packet.get_string_from_ascii(), "Chat")


func _on_ForwardButton_pressed(): #############################################
	player_move_forward = true


func _on_ForwardButton_released(): ############################################
	player_move_forward = false




################################## functions ##################################

func create_world(distance, height): ##########################################
	for x in range(distance):
		for y in range(height):
			for z in range(distance):
				create_chunk(Vector3(x, y, z))


func create_chunk(location): ##################################################
	var chunk = chunk_template.instance()
	chunk.World = World
	chunk.chunk_location = location
	add_child(chunk)
	chunk.name = str(location.x) + ", " + str(location.y) + ", " + str(location.z)
	chunk.translate_object_local(Vector3(location.x*16, location.y*16, location.z*16))
	
	if map_seed != -1: 
		var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
		EdenWorldDecoder.World = World
		EdenWorldDecoder.set_vars()
		#EdenWorldDecoder.init_world()
		#chunk.chunk_address = EdenWorldDecoder.ChunkMetadata[floor(rand_range(0, 6))].address
	
	chunk_index[location] = chunk


func get_chunk_sub(location): #################################################
	var x = 0
	if location == 0:
		return 0
	elif location > 0:
		while !(location >= x and location < x*16):
			x += 1
	else:
		while !(location <= x and location > x*16):
			x -= 1
	return x - 1


func get_chunk(location): #####################################################
	var x = get_chunk_sub(int(round(location.x)))
	var y = get_chunk_sub(int(round(location.y)))
	var z = get_chunk_sub(int(round(location.z)))
	
	return Vector3(x, y, z)


func create_surrounding_chunks(center_chunk): #################################
	for x in range(3):
		for y in range(3):
			for z in range(3):
				if !(chunk_index.has(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))):
					#print("Creating chunk... ")
					create_chunk(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))




############################ networking functions #############################

func create_server(username): #################################################
	Hud.msg("Creating server...", "Info")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(8888, 100)
	get_tree().set_network_peer(network)
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().set_meta("network_peer", network)


func join_server(username): ###################################################
	Hud.msg("Joining server...", "Info")
	var network = NetworkedMultiplayerENet.new()
	network.create_client("101.183.54.6", 8888)
	get_tree().set_network_peer(network)
	network.connect("connection_failed", self, "_on_connection_failed")
	get_tree().multiplayer.connect("network_peer_packet", self, "_on_packet_received")
	get_tree().set_meta("network_peer", network)


func leave_server(): ##########################################################
	get_tree().set_network_peer(null)


func _on_connection_failed(error):
	Hud.msg("Error connecting to server: " + error, "Error")


func send_message(msg): #######################################################
	rpc("send_data", msg)




############################## remote functions ###############################

remote func send_data(data): ##################################################
	Hud.msg(data, "Chat")


remote func register_player(id, info): ########################################
	Hud.msg("Player info: " + str(info), "Info")
	# Store the info
	player_info[id] = info
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
		#Send my info to new player
		rpc_id(id, "register_player", 1, my_info)
		# Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])



