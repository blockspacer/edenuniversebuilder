extends MeshInstance

############################## public variables ###############################

#onready var blocks = preload("res://block.meshlib").duplicate()
var World
var Hud


var block_data = Dictionary()
var mesh_data = []
var blocks_loaded = 0

var chunk_location = Vector3(0, 0, 0)
var chunk_address = 0




################################### signals ###################################

func _ready(): ################################################################
	if chunk_location.y != 0:
		return
	Hud = World.Hud
	Hud.msg("wow", "Debug")
	
	place_block(0, 0, 0, 0)
	
	# tex order = right, front, back, left, top, bottom
	generate_block_mesh(1, "bedrock", single_sided_block("bedrock"))
	generate_block_mesh(2, "stone", single_sided_block("grey_stone"))
	generate_block_mesh(3, "dirt", single_sided_block("dirt"))
	generate_block_mesh(4, "sand", single_sided_block("sand"))
	generate_block_mesh(5, "leaves", single_sided_block("leaves_green"))
	generate_block_mesh(6, "trunk", two_sided_block("tree_side", "tree_top"))
	generate_block_mesh(7, "wood", single_sided_block("wood"))
	generate_block_mesh(8, "grass", [ "grass_side", "grass_side", "grass_side", "grass_side", "grass_top", "dirt" ])
	generate_block_mesh(9, "tnt", two_sided_block("tnt_side", "tnt_top"))
	generate_block_mesh(10, "rock", single_sided_block("dark_stone"))
	
	generate_block_mesh(11, "weeds", [ "grass_side", "grass_side", "grass_side", "grass_side", "grass_top", "dirt" ])
	generate_block_mesh(12, "flowers", [ "grass_side", "grass_side", "grass_side", "grass_side", "grass_top", "dirt" ])
	generate_block_mesh(13, "brick", single_sided_block("brick"))
	generate_block_mesh(14, "slate", single_sided_block("bedrock"))
	generate_block_mesh(15, "ice", single_sided_block("ice"))
	generate_block_mesh(16, "wallpaper", single_sided_block("crystal_white"))
	generate_block_mesh(17, "trampoline", single_sided_block("trampoline"))
	generate_block_mesh(18, "ladder", two_sided_block("ladder_side", "wood"))
	generate_block_mesh(19, "cloud", single_sided_block("cloud"))
	generate_block_mesh(20, "water", single_sided_block("water"))
	
	generate_block_mesh(21, "fence", single_sided_block("weave"))
	generate_block_mesh(22, "ivy", single_sided_block("vine"))
	generate_block_mesh(23, "lava", single_sided_block("lava"))
	
	# Triangles
	
	generate_block_mesh(24, "rock .S", single_sided_block("grey_stone"))
	generate_block_mesh(25, "rock .W", single_sided_block("grey_stone"))
	generate_block_mesh(26, "rock .N", single_sided_block("grey_stone"))
	generate_block_mesh(27, "rock .E", single_sided_block("grey_stone"))
	
	generate_block_mesh(28, "wood .S", single_sided_block("wood"))
	generate_block_mesh(29, "wood .W", single_sided_block("wood"))
	generate_block_mesh(30, "wood .N", single_sided_block("wood"))
	generate_block_mesh(31, "wood .E", single_sided_block("wood"))
	
	generate_block_mesh(32, "shing .S", single_sided_block("shingle"))
	generate_block_mesh(33, "shing .W", single_sided_block("shingle"))
	generate_block_mesh(34, "shing .N", single_sided_block("shingle"))
	generate_block_mesh(35, "shing .E", single_sided_block("shingle"))
	
	generate_block_mesh(36, "ice .S", single_sided_block("ice"))
	generate_block_mesh(37, "ice .W", single_sided_block("ice"))
	generate_block_mesh(38, "ice .N", single_sided_block("ice"))
	generate_block_mesh(39, "ice .E", single_sided_block("ice"))
	
	generate_block_mesh(40, "rock SE", single_sided_block("grey_stone"))
	generate_block_mesh(41, "rock SW", single_sided_block("grey_stone"))
	generate_block_mesh(42, "rock NW", single_sided_block("grey_stone"))
	generate_block_mesh(43, "rock NE", single_sided_block("grey_stone"))
	
	generate_block_mesh(44, "wood SE", single_sided_block("wood"))
	generate_block_mesh(45, "wood SW", single_sided_block("wood"))
	generate_block_mesh(46, "wood NW", single_sided_block("wood"))
	generate_block_mesh(47, "wood NE", single_sided_block("wood"))
	
	generate_block_mesh(48, "shing SE", single_sided_block("shingle"))
	generate_block_mesh(49, "shing SW", single_sided_block("shingle"))
	generate_block_mesh(50, "shing NW", single_sided_block("shingle"))
	generate_block_mesh(51, "shing NE", single_sided_block("shingle"))
	
	generate_block_mesh(52, "ice SE", single_sided_block("ice"))
	generate_block_mesh(53, "ice SW", single_sided_block("ice"))
	generate_block_mesh(54, "ice NW", single_sided_block("ice"))
	generate_block_mesh(55, "ice NE", single_sided_block("ice"))
	
	# =====
	
	generate_block_mesh(56, "shingles", single_sided_block("shingle"))
	generate_block_mesh(57, "tile", single_sided_block("gradient"))
	generate_block_mesh(58, "glass", single_sided_block("glass"))
	
	# Liquid
	
	generate_block_mesh(59, "water 3/4", single_sided_block("water"))
	generate_block_mesh(60, "water 1/2", single_sided_block("water"))
	generate_block_mesh(61, "water 1/4", single_sided_block("water"))
	
	generate_block_mesh(62, "lava 3/4", single_sided_block("lava"))
	generate_block_mesh(63, "lava 1/2", single_sided_block("lava"))
	generate_block_mesh(64, "lava 1/4", single_sided_block("lava"))
	
	# ======
	
	generate_block_mesh(65, "fireworks", two_sided_block("fireworks_side", "tnt_top"))
	generate_block_mesh(66, "door N", single_sided_block("bedrock"))
	generate_block_mesh(67, "door E", single_sided_block("bedrock"))
	generate_block_mesh(68, "door S", single_sided_block("bedrock"))
	generate_block_mesh(69, "door W", single_sided_block("bedrock"))
	generate_block_mesh(70, "door top", single_sided_block("bedrock"))
	
	generate_block_mesh(71, "transcube", single_sided_block("bedrock"))
	generate_block_mesh(72, "light", single_sided_block("bedrock"))
	generate_block_mesh(73, "newflower", single_sided_block("bedrock"))
	generate_block_mesh(74, "steel", single_sided_block("bedrock"))
	
	generate_block_mesh(75, "pN portal N", single_sided_block("bedrock"))
	generate_block_mesh(76, "pE portal E", single_sided_block("bedrock"))
	generate_block_mesh(77, "pS portal S", single_sided_block("bedrock"))
	generate_block_mesh(78, "pW portal W", single_sided_block("bedrock"))
	generate_block_mesh(79, "pT portal top", single_sided_block("bedrock"))
	
	# assign mesh library to the chunk
	#cell_size = Vector3(1, 1, 1)
	#cell_center_x = true
	#cell_center_y = true
	#cell_center_z = true
	#mesh_library = blocks
	
	if World.map_seed == 0:
		if chunk_location.y == 0:
			Hud.msg("translation is equal to " + str(chunk_location), "Info")
			generate_flat_terrain()
			#load_terrain()
	
	elif World.map_seed == -1:
		pass
		#if chunk_location.y == 0:
			#generate_random_terrain()




################################## functions ##################################

func generate_flat_terrain(): #################################################
	for x in range(16):
		for y in range(16):
			for z in range(16):
				#if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
				if y == 0:
					pass
					place_block(2, x, y, z)
					#if y >= 15:
						#place_block(8, x, y, z)
					#elif y > 10:
						#place_block(3, x, y, z)
					#else:
						#place_block(x, y, z, 2)
	#place_block(2, 0, 0, 0)
	compile()


func load_terrain(): ##########################################################
	# Get the chunk data from the WORLD FILE.
	#Hud.msg("Running GetChunkData on chunk ", ChunkMetadata[i].Address, "...", "Debug")
	var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
	EdenWorldDecoder.World = World
	EdenWorldDecoder.set_vars()
	var ChunkData = EdenWorldDecoder.get_chunk_data(Vector2(chunk_location.x, chunk_location.z))
	World.loaded = true
	if typeof(ChunkData) == 1:
		generate_flat_terrain()
		return false
	
	Hud.msg("Creating the chunk mesh... ", "Debug")
	#CreateChunk(ChunkMetadata[i].Address, x, y, z)
	
	#Hud.msg("Registering blocks... ", "Debug")
	#for Blocks in range(ChunkData.size()):
		#Indexer.RegisterBlock(ChunkData[Blocks].Id, ChunkData[Blocks].Position.X, ChunkData[Blocks].Position.Y, ChunkData[Blocks].Position.Z, ChunkMetadata[i].Address, 0);
	
	# ==============================================================================
	Hud.msg(["Chunk data contains ", ChunkData.size(), " blocks"], "Debug")
	Hud.msg("Placing blocks... ", "Debug")
	# Place all the blocks contained in the chunk data.
	for Blocks in range(ChunkData.size()):
		var x = ChunkData[Blocks].position.x
		var y = ChunkData[Blocks].position.y
		var z = ChunkData[Blocks].position.z
		var id = ChunkData[Blocks].id
		
		place_block(x, z, y, id)
		
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


func generate_random_terrain(): ###############################################
	for x in range(16):
		for y in range(16):
			for z in range(16):
				randomize()
				if floor(rand_range(0, 3)) == 1:
					place_block(x, y, z, floor(rand_range(1, 80)))
				#if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
				#if x == 0 and y == 0 and z == 0:
					#if y >= 15:
						#place_block(x, y, z, 8)
					#elif y > 10:
						#place_block(x, y, z, 3)
					#else:
						#place_block(x, y, z, 2)


func generate_matrix_terrain(): ###############################################
	for x in range(16):
		for y in range(16):
			for z in range(16):
				#if x == 15 or x == 0 or z == 15 or z == 0 or y == 15:
				if x == 0 and y == 0 and z == 0:
					if y >= 15:
						place_block(x, y, z, 8)
					elif y > 10:
						place_block(x, y, z, 3)
					else:
						place_block(x, y, z, 2)


func generate_block_mesh(id, block_name, textures): ###########################
	pass
	#var item_mesh = blocks.get_item_mesh(0).duplicate()
	#var item_shapes = blocks.get_item_shapes(0).duplicate()
	#blocks.create_item(id)
	
	#for i in range(0, textures.size()):
		#var mat = SpatialMaterial.new()
		#var mat = load("res://block.material").duplicate()
		#var tex = load("res://textures/" + textures[i] + ".png")
		#mat.albedo_texture = tex
		#mat.uv1_scale = Vector3(3, 3, 3)
		#item_mesh.surface_set_material(i, mat)
	
	# create navmesh
	#blocks.set_item_mesh(id, item_mesh)
	#blocks.set_item_shapes(id, item_shapes)
	#blocks.set_item_name(id, block_name)


func single_sided_block(data): ################################################
	var arr = Array()
	for i in range(6):
		arr.append(data)
	return arr


func two_sided_block(side_tex, top_bot_tex): ##################################
	var arr = Array()
	for i in range(4):
		arr.append(side_tex)
	for i in range(2):
		arr.append(top_bot_tex)
	return arr


func break_block(x, y, z): ####################################################
	var location = Vector3(x, y, z) - translation
	#Hud.msg("Removing block from chunk location " + str(location), "Info")
	#set_cell_item(location.x, location.y, location.z, -1, 0)
	#Hud.msg("Chunk was" + str(chunk_location), "Debug")


func place_block(id, x, y, z): ################################################
	var location = Vector3(x, y, z) - translation
	Hud = World.Hud
	Hud.msg("Placing block from chunk location " + str(location), "Info")
	
	block_data[Vector3(x, y, z)] = id
	
	#set_surface_material(0, "texture")
	
	#set_cell_item(location.x, location.y, location.z, id, 0)
	#Hud.msg("Chunk was" + str(chunk_location), "Debug")

func compile():
	Hud.msg("Compiling chunk...", "Info")
	var st = SurfaceTool.new()
	#st.create_from(mesh, 0)
	#var mesh = Mesh.new()
	
	#mat.albedo_color = Color(1, 0, 0, 1)
	#var mat = SpatialMaterial.new()
	var mat = load("res://block.material").duplicate()
	var tex = load("res://textures/bedrock.png")
	mat.albedo_texture = tex
	#mat.uv1_scale = Vector3(3, 3, 3)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	#st.add_color(Color(1, 0, 0))
	
	for position in block_data.keys():
		create_horizontal_plane(st, position)
		#create_cube(st, position)
	
	#create_vertical_plane(st, Vector3(0, 0, 0))
	#create_vertical_plane(st, Vector3(1, 0, 0))
	#create_vertical_plane(st, Vector3(2, 0, 0))
	#create_vertical_plane(st, Vector3(4, 0, 0))
	#create_horizontal_plane(st, Vector3(0, 0, 0))
	
	st.generate_normals(true)
	st.index()
	
	mesh = st.commit()
	
	var shape = ConcavePolygonShape.new()
	shape.set_faces(mesh_data)
	
	var collision_shape = get_node("StaticBody/CollisionShape")
	collision_shape.shape = shape
	
	#collision_shape.shape = mesh.create_trimesh_shape() # Broken on Android!

func create_vertical_plane(st, position):
	# top-left
	st.add_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, 0, 0) + position)
	
	# top-right
	st.add_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 0, 0) + position)
	
	# bottom-left
	st.add_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, -1, 0) + position)
	
	
	
	# bottom-right
	st.add_uv(Vector2(1, 0))
	st.add_vertex(Vector3(1, -1, 0) + position)
	
	# bottom-left
	st.add_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, -1, 0) + position)
	
	# top-right
	st.add_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 0, 0) + position)


func create_horizontal_plane(st, position):
	# top-left
	st.add_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, 0, 0) + position)
	mesh_data.append(Vector3(0, 0, 0) + position)
	
	# top-right
	st.add_uv(Vector2(1, 0))
	st.add_vertex(Vector3(1, 0, 0) + position)
	mesh_data.append(Vector3(1, 0, 0) + position)
	
	# bottom-left
	st.add_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, 0, 1) + position)
	mesh_data.append(Vector3(0, 0, 1) + position)
	
	
	# bottom-right
	st.add_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 0, 1) + position)
	mesh_data.append(Vector3(1, 0, 1) + position)
	
	# bottom-left
	st.add_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, 0, 1) + position)
	mesh_data.append(Vector3(0, 0, 1) + position)
	
	# top-right
	st.add_uv(Vector2(1, 0))
	st.add_vertex(Vector3(1, 0, 0) + position)
	mesh_data.append(Vector3(1, 0, 0) + position)

func create_cube(st, position):
	st.add_uv(Vector2(0, 0.66))
	st.add_vertex(Vector3(0, 1, 0) + position)
	mesh_data.append(Vector3(0, 1, 0) + position)
	
	st.add_uv(Vector2(0.25, 0.66))
	st.add_vertex(Vector3(0, 0, 0) + position)
	mesh_data.append(Vector3(0, 0, 0) + position)
	
	st.add_uv(Vector2(0, 0.33))
	st.add_vertex(Vector3(1, 1, 0) + position)
	mesh_data.append(Vector3(0, 1, 0) + position)
	
	st.add_uv(Vector2(0.25, 0.33))
	st.add_vertex(Vector3(1, 0, 0) + position)
	mesh_data.append(Vector3(1, 0, 0) + position)
	
	
	st.add_uv(Vector2(0.5, 0.66))
	st.add_vertex(Vector3(0, 0, 1) + position)
	mesh_data.append(Vector3(0, 0, 1) + position)
	
	st.add_uv(Vector2(0.5, 0.33))
	st.add_vertex(Vector3(1, 0, 1) + position)
	mesh_data.append(Vector3(1, 0, 1) + position)
	
	st.add_uv(Vector2(0.75, 0.66))
	st.add_vertex(Vector3(0, 1, 1) + position)
	mesh_data.append(Vector3(0, 1, 1) + position)
	
	st.add_uv(Vector2(0.75, 0.33))
	st.add_vertex(Vector3(1, 1, 1) + position)
	mesh_data.append(Vector3(1, 1, 1) + position)
	
	
	st.add_uv(Vector2(1, 0.66))
	st.add_vertex(Vector3(0, 1, 0) + position)
	mesh_data.append(Vector3(0, 1, 0) + position)
	
	st.add_uv(Vector2(1, 0.33))
	st.add_vertex(Vector3(1, 1, 0) + position)
	mesh_data.append(Vector3(1, 1, 0) + position)
	
	
	st.add_uv(Vector2(0.25, 1))
	st.add_vertex(Vector3(0, 1, 0) + position)
	mesh_data.append(Vector3(0, 1, 0) + position)
	
	st.add_uv(Vector2(0.5, 1))
	st.add_vertex(Vector3(0, 1, 1) + position)
	mesh_data.append(Vector3(0, 1, 1) + position)
	
	
	st.add_uv(Vector2(0.25, 0))
	st.add_vertex(Vector3(1, 1, 0) + position)
	mesh_data.append(Vector3(1, 1, 0) + position)
	
	st.add_uv(Vector2(0.5, 0))
	st.add_vertex(Vector3(1, 1, 1) + position)
	mesh_data.append(Vector3(1, 1, 1) + position)
	
	# front
	st.add_index(0 + 14 * blocks_loaded)
	st.add_index(2 + 14 * blocks_loaded)
	st.add_index(1 + 14 * blocks_loaded)
	
	st.add_index(1 + 14 * blocks_loaded)
	st.add_index(2 + 14 * blocks_loaded)
	st.add_index(3 + 14 * blocks_loaded)
	
	# back
	st.add_index(4 + 14 * blocks_loaded)
	st.add_index(5 + 14 * blocks_loaded)
	st.add_index(6 + 14 * blocks_loaded)
	
	st.add_index(5 + 14 * blocks_loaded)
	st.add_index(7 + 14 * blocks_loaded)
	st.add_index(6 + 14 * blocks_loaded)
	
	# top
	st.add_index(6 + 14 * blocks_loaded)
	st.add_index(7 + 14 * blocks_loaded)
	st.add_index(8 + 14 * blocks_loaded)
	
	st.add_index(7 + 14 * blocks_loaded)
	st.add_index(9 + 14 * blocks_loaded)
	st.add_index(8 + 14 * blocks_loaded)
	
	# bottom
	st.add_index(1 + 14 * blocks_loaded)
	st.add_index(3 + 14 * blocks_loaded)
	st.add_index(4 + 14 * blocks_loaded)
	
	st.add_index(3 + 14 * blocks_loaded)
	st.add_index(5 + 14 * blocks_loaded)
	st.add_index(4 + 14 * blocks_loaded)
	
	# left
	st.add_index(1 + 14 * blocks_loaded)
	st.add_index(11 + 14 * blocks_loaded)
	st.add_index(10 + 14 * blocks_loaded)
	
	st.add_index(1 + 14 * blocks_loaded)
	st.add_index(4 + 14 * blocks_loaded)
	st.add_index(11 + 14 * blocks_loaded)
	
	# right
	st.add_index(3 + 14 * blocks_loaded)
	st.add_index(12 + 14 * blocks_loaded)
	st.add_index(5 + 14 * blocks_loaded)
	
	st.add_index(5 + 14 * blocks_loaded)
	st.add_index(12 + 14 * blocks_loaded)
	st.add_index(13 + 14 * blocks_loaded)
	
	blocks_loaded+= 1