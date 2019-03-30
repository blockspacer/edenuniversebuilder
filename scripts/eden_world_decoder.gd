# By JosephTheEngineer ¯\_(ツ)_/¯
# Based on code from Vuenctools for Eden || http://forum.edengame.net/index.php?/topic/295-vuenctools-for-eden-eden-world-manipulation-tool/
# with help from Robert Munafo || http://www.mrob.com/pub/vidgames/eden-file-format.html

extends Spatial

############################## public variables ###############################

var World
var Hud


var map_file = File.new()
var ChunkLocations = Dictionary()
var ChunkAddresses = Dictionary()
var ChunkMetadata = Array()


var worldAreaX = 0
var worldAreaY = 0
var worldAreaWidth = 0
var worldAreaHeight = 0




################################## functions ##################################

func set_vars(): ##############################################################
	Hud = World.Hud
	map_file = World.map_file
	ChunkLocations = World.ChunkLocations
	ChunkAddresses = World.ChunkAddresses
	ChunkMetadata = World.ChunkMetadata

	worldAreaX = World.worldAreaX
	worldAreaY = World.worldAreaY
	worldAreaWidth = World.worldAreaWidth
	worldAreaHeight = World.worldAreaHeight


func init_world(): ############################################################
	Hud.msg("We are online. Starting world convertion...", "Info")
	if World.map_path == null:
		Hud.msg("InitializeWorld: WorldPath is null", "Error");
		return false;
	
	Hud.msg("WorldPath is: " + World.map_path, "Info");
	
	var file = File.new()
	if not file.file_exists(World.map_path):
		Hud.msg("Creating file " + World.map_path, "Info");
		World.create_chunk(Vector3(0, 0, 0))
		#create_metadata();
	
	Hud.msg("Geting world metadata...", "Info");
	return get_metadata();


func read_int(position): ######################################################
	map_file.seek(position)
	return map_file.get_buffer(1)[0]


func get_metadata(): ##########################################################
	# Open existing file
	if map_file.open(World.map_path, File.READ) != 0:
		Hud.msg("Error opening file", "Error")
	
	#while !file.eof_reached():
		#Hud.msg("Loading map_data...", "Trace")
		#map_data.append(file.get_buffer(1)[0])
	
	World.chunks_cache_size = 0
	
	if read_int(0) == null:
		Hud.msg("Couldn't open input file for reading", "Error")
		#Hud.msg("World file length is ", FileSize, "", "Error")
	
	Hud.msg(["WorldData[0]: ", read_int(0), "!"], "Debug")
	Hud.msg(["WorldData[1]: ", read_int(1), "!"], "Debug")
	Hud.msg(["WorldData[4]: ", read_int(4), "!"], "Debug")
	
	var chunkPointer = read_int(35) * 256 * 256 * 256 + read_int(34) * 256 * 256 + read_int(33) * 256 + read_int(32)
	var worldAreaWidthTemp = 0
	var worldAreaHeightTemp = 0
	
	Hud.msg(["chunkPointer: ", chunkPointer], "Debug")
	#Hud.msg(map_data.size(), "Debug")
	Hud.msg("World file path is vaid. All systems are go for launch.", "Info")
	while chunkPointer + 11 < map_file.get_len():
		# Find chunk address
		var address = read_int(chunkPointer + 11) * 256 * 256 * 256 + read_int(chunkPointer + 10) * 256 * 256 + read_int(chunkPointer + 9) * 256 + read_int(chunkPointer + 8)
		# Find the position of the chunk
		var x = (read_int(chunkPointer + 1) * 256 + read_int(chunkPointer)) - 4000     # Minus 4000 to center the world around 0, 0
		
		var y = (read_int(chunkPointer + 5) * 256 + read_int(chunkPointer + 4)) - 4000 # This shouldn't brake anything
		
		if worldAreaX > x:
			worldAreaX = x
		if worldAreaY > y:
			worldAreaY = y
		
		if worldAreaWidthTemp < x:
			worldAreaWidthTemp = x
		if worldAreaHeightTemp < y:
			worldAreaHeightTemp = y
		
		ChunkLocations[address] =  Vector2(x, y)
		
		ChunkAddresses[Vector2(x, y)] = address
		
		var ChunkData  = {
			"address": address, 
			"x": x, 
			"y": y, 
		}
		
		ChunkMetadata.append(ChunkData)
		
		chunkPointer += 16
	
	Hud.msg(["Found ", ChunkLocations.size(), " chunks"], "Info");
	World.total_chunks = ChunkLocations.size()
	Hud.msg("Starting chunk is at " + str(ChunkMetadata[0].x) + ", " + str(ChunkMetadata[0].y), "Info")
	Hud.msg("Spawning the player at " + str(ChunkMetadata[0].x * 16) + ", " + str(ChunkMetadata[0].y * 16), "Info")
	World.first_chunk = Vector3(ChunkMetadata[0].x * 16, 50, ChunkMetadata[0].y * 16)
	
	# Get the total world width | max - min + 1
	worldAreaWidth = worldAreaWidthTemp - worldAreaX + 1;
	
	# Get the total world height | max - min + 1
	worldAreaHeight = worldAreaHeightTemp - worldAreaY + 1;
	
	if ChunkLocations.size() < 1:
		Hud.msg("GetWorldMetadata: ChunkLocations was null!", "Error");
		return false;
	return true;


func get_chunk_data(location): ################################################
	if !ChunkAddresses.has(location):
		Hud.msg("Chunk data does not exist!", "Error");
		return false
	
	var ChunkData = Array()
	#var chunk = ChunkMetadata[floor(rand_range(0, 5))].address
	var chunk = ChunkAddresses[location]
	
	#gzFile File;
	#File = gzopen(TCHAR_TO_UTF8(*WorldPath), "rb");
	#if(File == NULL)
	#{
	#	Logger.Log("Couldn't open input file for reading", "Error");
	#}
	
	# Grabbing the chunk position
	var globalChunkPosX = ChunkLocations[chunk].x
	var globalChunkPosY = ChunkLocations[chunk].y
	
	var realChunkPosX = (globalChunkPosX*16) * 100
	var realChunkPosY = (globalChunkPosY*16) * 100
	
	# Gets the staring point for placing blocks in the chunk
	var baseX = (ChunkLocations[chunk].x - worldAreaX) * 16
	var baseY = (ChunkLocations[chunk].y - worldAreaY) * 16
	
	for baseHeight in range(4):
		for x in range(16):
			for y in range(16):
				for z in range(16):
					var id = read_int(chunk + baseHeight * 8192 + x * 256 + y * 16 + z)
					var color = read_int(chunk + baseHeight * 8192 + x * 256 + y * 16 + z + 4096)
					
					var RealX = (x + (globalChunkPosX*16));
					var RealY = (y + (globalChunkPosY*16));
					var RealZ = (z + (16 * baseHeight));
					
					var Position = Vector3(x, y, z + 16 * baseHeight);
					
					#Logger.LogInt("=== Id: ", Id, " ===", "Debug");
					#Logger.LogInt("Color: ", Color, "", "Debug");
					#Logger.LogFloat("X: ", (x + (globalChunkPosX*16)) * 100, "", "Debug");
					#Logger.LogFloat("Y: ", (y + (globalChunkPosY*16)) * 100, "", "Debug");
					#Logger.LogFloat("Z: ", (z + (16 * baseHeight)) * 100, "", "Debug");
					
					if id != 0 && id <= 79 && id > 0:
						# Logger.Log("Block is valid", "Debug");
						#Hud.msg(id, "Trace")
						var BlockData  = {
							"position": Position, 
							"id": id, 
							"color": color, 
							"chunk": chunk
						}
						
						ChunkData.append(BlockData);
						#Hud.msg(["id: ", id], "Trace")
						#Hud.msg(["Adding Block ", ChunkData.size()], "Debug");
					#Hud.msg(["Chunk data tmp: ", ChunkData.size(), " blocks"], "Debug");
	Hud.msg(["Chunk data contains ", ChunkData.size(), " blocks"], "Debug");
	return ChunkData;