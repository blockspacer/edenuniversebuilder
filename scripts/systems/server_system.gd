extends Node

var map_seed = 0
var map_path = "res://worlds/direct_city.eden2"
var map_name = "direct_city.eden2"

func start():
	#create_world()
	Debug.msg("Server System ready.", "Info")

func create_world():
	# Needs to create chunk data but not chunk render
	# ChunkSystem.create_chunk(Vector3(0, 0, 0))
	pass

func create_server(username): #################################################
	Debug.msg("Creating server...", "Info")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(8888, 100)
	get_tree().set_network_peer(network)
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().set_meta("network_peer", network)

func _peer_connected(id): #####################################################
	Debug.msg("User " + str(id) + " connected", "Info")
	Debug.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")


func _peer_disconnected(id): ##################################################
	Debug.msg("User " + str(id) + " disconnected", "Info")
	Debug.msg("Total users: " + str(get_tree().get_network_connected_peers().size()), "Info")

func load_world(object, method):
	connect("world_loaded", object, method)
	Debug.msg("Loading world...", "Info")
	Debug.msg("Running demo preset...", "Info")
	Debug.msg("Removing all entities...", "Debug")
	for id in Entity.objects:
		Entity.destory(id)
	
	Debug.msg("Starting terrain generator...", "Info")
	TerrainGenerator.setup_vars()
	var chunk_data = TerrainGenerator.generate_flat_terrain()
	
	var chunk = Dictionary()
	chunk.rendered = false
	chunk.position = Vector3(0, 0, 0)
	chunk.address = 0
	chunk.gen_seed = 0
	chunk.block_data = chunk_data
	chunk.blocks_loaded = 0
	chunk.mesh = null
	chunk.vertex_data = Array()
	chunk.shape = null
	chunk.materials = Dictionary()
	chunk.entities = Dictionary()
	chunk.object = object
	chunk.method = method
	
	var id = Entity.create({"chunk" : chunk})