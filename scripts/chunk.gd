extends GridMap

onready var blocks = preload("res://block.meshlib").duplicate()
onready var World = get_node("/root/World")

onready var Debug = preload("res://scripts/debug.gd").new()

var chunk_location = Vector3(0, 0, 0)
var chunk_address = 0

func _ready():
	
	if World == null:
		World = get_node("/root/Main Menu/World")
	
	# tex order = right, front, back, left, top, bottom
	generate_block_mesh(1, "bedrock", single_sided_block("dark_stone"))
	generate_block_mesh(2, "stone", single_sided_block("greystone"))
	generate_block_mesh(3, "dirt", single_sided_block("dirt"))
	generate_block_mesh(4, "sand", single_sided_block("sand"))
	generate_block_mesh(5, "leaves", single_sided_block("leaves_green"))
	generate_block_mesh(6, "trunk", single_sided_block("tree_exterior"))
	generate_block_mesh(7, "wood", single_sided_block("wood"))
	generate_block_mesh(8, "grass", [ "grass_side", "grass_side", "grass_side", "grass_side", "grass", "dirt" ])
	generate_block_mesh(9, "tnt", single_sided_block("tnt"))
	generate_block_mesh(10, "rock", single_sided_block("bedrock"))
	
	# assign mesh library to the chunk
	cell_size = Vector3(1, 1, 1)
	cell_center_x = true
	cell_center_y = true
	cell_center_z = true

	if World.map_seed == 0:
		if chunk_location.y == 0:
			print("translation is equal to ", chunk_location)
			#generate_flat_terrain()
			load_terrain()
	elif World.map_seed == -1:
		if chunk_location.y == 0:
			generate_random_terrain()
		#print(blocks.find_item_by_name("grass"))
		#print(get_meshes())
		#print(theme.get_item_list())

func generate_flat_terrain():
	for x in range(16):
		for y in range(16):
			for z in range(16):
				if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
					if y >= 15:
						set_cell_item(x, y, z, 8, 0)
					elif y > 10:
						set_cell_item(x, y, z, 3, 0)
					else:
						set_cell_item(x, y, z, 2, 0)
					#print(str(x, ", ", y, ", ", z))

func load_terrain():
	# Get the chunk data from the WORLD FILE.
	#Debug.msg("Running GetChunkData on chunk ", ChunkMetadata[i].Address, "...", "Debug")
	var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
	EdenWorldDecoder.World = World
	EdenWorldDecoder.init_world()
	var ChunkData = EdenWorldDecoder.get_chunk_data(chunk_address)
	
	Debug.msg("Creating the chunk mesh... ", "Debug")
	#CreateChunk(ChunkMetadata[i].Address, x, y, z)
	
	#Debug.msg("Registering blocks... ", "Debug")
	#for Blocks in range(ChunkData.size()):
		#Indexer.RegisterBlock(ChunkData[Blocks].Id, ChunkData[Blocks].Position.X, ChunkData[Blocks].Position.Y, ChunkData[Blocks].Position.Z, ChunkMetadata[i].Address, 0);
	
	# ==============================================================================
	Debug.msg(["Chunk data contains ", ChunkData.size(), " blocks"], "Debug")
	Debug.msg("Placing blocks... ", "Debug")
	# Place all the blocks contained in the chunk data.
	for Blocks in range(ChunkData.size()):
		var x = ChunkData[Blocks].position.x
		var y = ChunkData[Blocks].position.y
		var z = ChunkData[Blocks].position.z
		var id = ChunkData[Blocks].id
		
		set_cell_item(x, z, y, id, 0)
		
		#Logger.Log("Checking block...", "Debug");
		#Logger.LogFloat("X: ", X, "", "Debug");
		#Logger.LogFloat("Y: ", Y, "", "Debug");
		#Logger.LogFloat("Z: ", Z, "", "Debug");
		
		#if !(Indexer.CheckBlock(X, Y+100, Z) && Indexer.CheckBlock(X, Y-100, Z) && Indexer.CheckBlock(X+100,Y, Z) && Indexer.CheckBlock(X-100, Y, Z) && Indexer.CheckBlock(X, Y, Z+100) && Indexer.CheckBlock(X, Y, Z-100)):
			# Logger.LogInt("Placing block ", ChunkData[Blocks].Id, "...", "Debug");
			#CreateBlock(ChunkData[Blocks].Id, ChunkMetadata[i].Address, X, Y, Z);
			#LoadedBlocks++;
	# ==============================================================================
	#Status+=1
	#LoadedChunks+=1

func generate_random_terrain():
	for x in range(16):
		for y in range(16):
			for z in range(16):
				randomize()
				if floor(rand_range(0, 3)) == 1:
					set_cell_item(x, y, z, floor(rand_range(1, 11)), 0)
				#if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
				#if x == 0 and y == 0 and z == 0:
					#if y >= 15:
						#set_cell_item(x, y, z, 8, 0)
					#elif y > 10:
						#set_cell_item(x, y, z, 3, 0)
					#else:
						#set_cell_item(x, y, z, 2, 0)
						#print(str(x, ", ", y, ", ", z))

func generate_matrix_terrain():
	for x in range(16):
		for y in range(16):
			for z in range(16):
				#if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
				if x == 0 and y == 0 and z == 0:
					if y >= 15:
						set_cell_item(x, y, z, 8, 0)
					elif y > 10:
						set_cell_item(x, y, z, 3, 0)
					else:
						set_cell_item(x, y, z, 2, 0)
						#print(str(x, ", ", y, ", ", z))

func generate_block_mesh(id, block_name, textures):
	var item_mesh = blocks.get_item_mesh(0).duplicate()
	var item_shapes = blocks.get_item_shapes(0).duplicate()
	blocks.create_item(id)
	
	for i in range(0, textures.size()):
		var mat = SpatialMaterial.new()
		#print("res://textures/" + textures[i] + ".png")
		var tex = load("res://textures/" + textures[i] + ".png")
		mat.albedo_texture = tex
		mat.uv1_scale = Vector3(3, 3, 3)
		item_mesh.surface_set_material(i, mat)
	
	# create navmesh
	blocks.set_item_mesh(id, item_mesh)
	blocks.set_item_shapes(id, item_shapes)
	blocks.set_item_name(id, block_name)
	theme = blocks

func single_sided_block(data):
	var arr = Array()
	for i in range(6):
		arr.append(data)
	return arr

func break_block(x, y, z):
	var location = Vector3(x, y, z) - translation
	print("Removing block from chunk location ", location)
	set_cell_item(location.x, location.y, location.z, -1, 0)
	print("Chunk was", chunk_location)

func place_block(id, x, y, z):
	var location = Vector3(x, y, z) - translation
	print("Removing block from chunk location ", location)
	set_cell_item(location.x, location.y, location.z, id, 0)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
