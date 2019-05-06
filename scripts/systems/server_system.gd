extends Node

var map_seed = 0
var map_path = "res://worlds/direct_city.eden2"
var map_name = "direct_city.eden2"

func _ready():
	create_world()

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