# By JosephTheEngineer ¯\_(ツ)_/¯
# Based on code from Vuenctools for Eden || http://forum.edengame.net/index.php?/topic/295-vuenctools-for-eden-eden-world-manipulation-tool/
# with help from Robert Munafo || http://www.mrob.com/pub/vidgames/eden-file-format.html

extends Spatial

var World = null
var Debug = load("res://scripts/debug.gd").new()

var ChunkLocations = Dictionary()
var ChunkMetadata = Array()
var map_data = Array()

var worldAreaX = 0
var worldAreaY = 0

var worldAreaWidth = 0
var worldAreaHeight = 0

func _ready():
	pass

func _process(delta):
	pass

func init_world():
	Debug.msg("We are online. Starting world convertion...", "Info")
	if World.map_path == null:
		Debug.msg("InitializeWorld: WorldPath is null", "Error");
		return false;
	
	Debug.msg("WorldPath is: " + World.map_path, "Info");
	
	var file = File.new()
	if not file.file_exists(World.map_path):
		Debug.msg("Creating file " + World.map_path, "Info");
		World.create_chunk(Vector3(0, 0, 0))
		#create_metadata();
	
	Debug.msg("Geting world metadata...", "Info");
	return get_metadata();

func get_metadata():
	# Open existing file
	var file = File.new()
	if file.open(World.map_path, File.READ) != 0:
		Debug.msg("Error opening file", "Error")
	
	while !file.eof_reached():
		#Debug.msg("Loading map_data...", "Trace")
		map_data.append(file.get_buffer(1)[0])
	
	if map_data == null:
		Debug.msg("Couldn't open input file for reading", "Error")
		#Debug.msg("World file length is ", FileSize, "", "Error")
	
	Debug.msg(["WorldData[0]: ", map_data[0], "!"], "Debug")
	Debug.msg(["WorldData[1]: ", map_data[1], "!"], "Debug")
	Debug.msg(["WorldData[4]: ", map_data[4], "!"], "Debug")
	
	var chunkPointer = map_data[35] * 256 * 256 * 256 + map_data[34] * 256 * 256 + map_data[33] * 256 + map_data[32]
	var worldAreaWidthTemp = 0
	var worldAreaHeightTemp = 0
	
	Debug.msg(["chunkPointer: ", chunkPointer], "Debug")
	Debug.msg(map_data.size(), "Debug")
	Debug.msg("World file path is vaid. All systems are go for launch.", "Info")
	while chunkPointer + 11 < map_data.size():
		# Find chunk address
		var address = map_data[chunkPointer + 11] * 256 * 256 * 256 + map_data[chunkPointer + 10] * 256 * 256 + map_data[chunkPointer + 9] * 256 + map_data[chunkPointer + 8]
		# Find the position of the chunk
		var x = (map_data[chunkPointer + 1] * 256 + map_data[chunkPointer]) - 4000     # Minus 4000 to center the world around 0, 0
		
		var y = (map_data[chunkPointer + 5] * 256 + map_data[chunkPointer + 4]) - 4000 # This shouldn't brake anything
		
		if worldAreaX > x:
			worldAreaX = x
		if worldAreaY > y:
			worldAreaY = y
		
		if worldAreaWidthTemp < x:
			worldAreaWidthTemp = x
		if worldAreaHeightTemp < y:
			worldAreaHeightTemp = y
		
		ChunkLocations[address] =  Vector2(x, y)
		
		var ChunkData  = {
			"address": address, 
			"x": x, 
			"y": y, 
		}
		
		ChunkMetadata.append(ChunkData)
		
		chunkPointer += 16
	
	Debug.msg(["Found ", ChunkLocations.size(), " chunks"], "Info");
	
	# Get the total world width | max - min + 1
	worldAreaWidth = worldAreaWidthTemp - worldAreaX + 1;
	
	# Get the total world height | max - min + 1
	worldAreaHeight = worldAreaHeightTemp - worldAreaY + 1;
	
	if ChunkLocations.size() < 1:
		Debug.msg("GetWorldMetadata: ChunkLocations was null!", "Error");
		return false;
	return true;

func get_chunk_data(chunkn):
	var ChunkData = Array()
	var chunk = ChunkMetadata[floor(rand_range(0, 5))].address
	
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
		var x = 16
		while x > 0:
			var y = 16
			while y > 0:
				var z = 16
				while z > 0:
					var id = map_data[chunk + baseHeight * 8192 + x * 256 + y * 16 + z]
					var color = map_data[chunk + baseHeight * 8192 + x * 256 + y * 16 + z + 4096]
					
					var RealX = (x + (globalChunkPosX*16));
					var RealY = (y + (globalChunkPosY*16));
					var RealZ = (z + (16 * baseHeight));
					
					var Position = Vector3(x, y, z);
					
					#Logger.LogInt("=== Id: ", Id, " ===", "Debug");
					#Logger.LogInt("Color: ", Color, "", "Debug");
					#Logger.LogFloat("X: ", (x + (globalChunkPosX*16)) * 100, "", "Debug");
					#Logger.LogFloat("Y: ", (y + (globalChunkPosY*16)) * 100, "", "Debug");
					#Logger.LogFloat("Z: ", (z + (16 * baseHeight)) * 100, "", "Debug");
					
					if id != 0 && id <= 79 && id > 0:
						# Logger.Log("Block is valid", "Debug");
						#Debug.msg(id, "Trace")
						var BlockData  = {
							"position": Position, 
							"id": id, 
							"color": color, 
							"chunk": chunk
						}
						
						ChunkData.append(BlockData);
						Debug.msg(["id: ", id], "Trace")
						#Debug.msg(["Adding Block ", ChunkData.size()], "Debug");
					#Debug.msg(["Chunk data tmp: ", ChunkData.size(), " blocks"], "Debug");
					z-=1
				y-=1
			x-=1
	Debug.msg(["Chunk data contains ", ChunkData.size(), " blocks"], "Debug");
	return ChunkData;