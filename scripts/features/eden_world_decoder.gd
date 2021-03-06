# By JosephTheEngineer ¯\_(ツ)_/¯
# Based on code from Vuenctools for Eden || http://forum.edengame.net/index.php?/topic/295-vuenctools-for-eden-eden-world-manipulation-tool/
# with help from Robert Munafo || http://www.mrob.com/pub/vidgames/eden-file-format.html

extends Node
var Debug = load("res://scripts/features/debug.gd")
onready var ServerSystem = get_node("/root/World/Systems/Server")

############################## public variables ###############################

var map_file = File.new()
var chunk_metadata = Dictionary()


var worldAreaX = 0
var worldAreaY = 0
var world_width = 0
var world_height = 0




################################## functions ##################################

func create_world():
	Debug.msg("We are online. Starting eden2 world file creation...", "Info")
	
	if ServerSystem.map_path == null:
		Debug.msg("InitializeWorld: WorldPath is null", "Error")
		return false
	else:
		Debug.msg("WorldPath is: " + ServerSystem.map_path, "Info")

func load_world(): ############################################################
	Debug.msg("We are online. Starting eden2 world file loading...", "Info")
	
	if ServerSystem.map_path == null:
		Debug.msg("InitializeWorld: WorldPath is null", "Error")
		return false
	else:
		Debug.msg("WorldPath is: " + ServerSystem.map_path, "Info")
	
	if not map_file.file_exists(ServerSystem.map_path):
		Debug.msg("World file does not exist!", "Warn")
		Debug.msg("Creating file " + ServerSystem.map_path, "Info")
		create_world()
	elif map_file.open(ServerSystem.map_path, File.READ) != 0:
		Debug.msg("Error opening file", "Error")
		return false
	elif read_int(0) == null:
		Debug.msg("Couldn't open input file for reading", "Error")
		return false
	
	# Check if world file is compressed
	map_file.seek(0)
	if map_file.get_buffer(1)[0] == 0x1f and map_file.get_buffer(2)[0] == 0x8b:
		Debug.msg("Map file is compressed... Decompressing", "Debug")
		if map_file.open_compressed(ServerSystem.map_path, File.READ, File.COMPRESSION_GZIP) != 0:
			Debug.msg("Error opening file", "Error")
			return false
	else:
		Debug.msg("Map file is uncompressed", "Debug")
		if map_file.open(ServerSystem.map_path, File.READ) != 0:
			Debug.msg("Error opening file", "Error")
			return false
	
	Debug.msg("File is loaded! Length is " + str(map_file.get_len()), "Info")
	
	return get_metadata()


func read_int(position): ######################################################
	map_file.seek(position)
	var buffer = map_file.get_buffer(1)
	return buffer[0]

func read_float(position): ####################################################
	map_file.seek(position)
	return map_file.get_float()


func get_metadata(): ##########################################################
	var chunk_pointer = read_int(35) * 256 * 256 * 256 + read_int(34) * 256 * 256 + read_int(33) * 256 + read_int(32)
	Debug.msg("Chunk Pointer: " + str(chunk_pointer), "Debug")
	
	ServerSystem.last_location = Vector3(read_float(4), read_float(8), read_float(12))
	ServerSystem.home_location = Vector3(read_float(16), read_float(20), read_float(24))
	ServerSystem.home_rotation = read_float(28)
	
	
	Debug.msg("World file path is vaid. All systems are go for launch.", "Info")
	world_width = 0
	world_height = 0
	while chunk_pointer + 11 < map_file.get_len():
		# Find chunk address
		var address = read_int(chunk_pointer + 11) * 256 * 256 * 256 + read_int(chunk_pointer + 10) * 256 * 256 + read_int(chunk_pointer + 9) * 256 + read_int(chunk_pointer + 8)
		# Find the position of the chunk
		var x = (read_int(chunk_pointer + 1) * 256 + read_int(chunk_pointer)) - 4000     # Minus 4000 to center the world around 0, 0
		
		var y = (read_int(chunk_pointer + 5) * 256 + read_int(chunk_pointer + 4)) - 4000 # This shouldn't brake anything
		
		if worldAreaX > x:
			worldAreaX = x
		if worldAreaY > y:
			worldAreaY = y
		
		if world_width < x:
			world_width = x
		if world_height < y:
			world_height = y
		
		var chunk_data  = {
			"address": address, 
			"x": x, 
			"y": y, 
		}
		
		chunk_metadata[Vector3(x, 0, y)] = (chunk_data)
		chunk_metadata[Vector3(x, 1, y)] = (chunk_data)
		chunk_metadata[Vector3(x, 2, y)] = (chunk_data)
		chunk_metadata[Vector3(x, 3, y)] = (chunk_data)
		
		chunk_pointer += 16
	
	
	Debug.msg("Found " + str(chunk_metadata.size()) + " chunks", "Info");
	#Debug.msg(str(chunk_metadata), "Trace")
	ServerSystem.total_chunks = chunk_metadata.size()
	
	# Get the total world width | max - min + 1
	world_width = world_width - worldAreaX + 1;
	
	# Get the total world height | max - min + 1
	world_height = world_height - worldAreaY + 1;
	
	if chunk_metadata.size() < 1:
		Debug.msg("GetWorldMetadata: ChunkLocations was null!", "Error");
		return false;
	return true;


func get_chunk_data(location): ################################################
	if chunk_metadata.size() < 0:
		Debug.msg("Invaild world data!", "Error");
		return false
	if !chunk_metadata.has(location):
		Debug.msg("Chunk data does not exist!", "Warn");
		return false
	
	var chunk_data = Dictionary()
	var chunk_address = chunk_metadata[location].address
	#Debug.msg("Chunk Address: " + str(chunk_address), "Debug")
	
	var baseHeight = location.y
	for x in range(16):
		for y in range(16):
			for z in range(16):
				var id = read_int(chunk_address + baseHeight * 8192 + x * 256 + y * 16 + z)
				var color = read_int(chunk_address + baseHeight * 8192 + x * 256 + y * 16 + z + 4096)
				
				var RealX = (x + (location.x*16))
				var RealY = (y + (location.z*16))
				var RealZ = (z + (16 * baseHeight))
				
				#var position = Vector3(x, z + 16 * baseHeight, y)
				var position = Vector3(x, z, y)
				
				#Logger.LogInt("=== Id: ", Id, " ===", "Debug");
				#Logger.LogInt("Color: ", Color, "", "Debug");
				#Logger.LogFloat("X: ", (x + (globalChunkPosX*16)) * 100, "", "Debug");
				#Logger.LogFloat("Y: ", (y + (globalChunkPosY*16)) * 100, "", "Debug");
				#Logger.LogFloat("Z: ", (z + (16 * baseHeight)) * 100, "", "Debug");
				
				if id != 0 && id <= 79 && id > 0:
					# Logger.Log("Block is valid", "Debug");
					#Debug.msg(id, "Trace")
					var block_data  = {
						"id": id, 
						"color": color
					}
					
					chunk_data[position] = block_data;
					#Debug.msg(["id: ", id], "Trace")
					#Debug.msg(["Adding Block ", chunk_data.size()], "Debug");
				#Debug.msg(["Chunk data tmp: ", chunk_data.size(), " blocks"], "Debug");
	#Debug.msg(str("Chunk data contains ", chunk_data.size(), " blocks"), "Debug");
	return chunk_data;