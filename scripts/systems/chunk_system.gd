# manages chunk data
# classified as a system because it gets run every frame and scans entities
extends Node

#var commands = [ "create_chunk", "destroy_chunk" ]

func _ready():
	Debug.msg("Chunk System ready.", "Info")

func create_chunk(position):
	var chunk = Dictionary()
	chunk.position = position
	
	var components = Dictionary()
	components["chunk"] = chunk
	#init_chunk(Entity.create(components))

func destroy_chunk(position):
	#var chunk = Dictionary()
	var list = Entity.get_entities_with("chunk")
	for entity in list.values():
		if entity.components.chunk.position == position:
			Entity.destory(entity.id)

signal rendered

func _process(delta):
	var entities = Entity.get_entities_with("chunk")
	for id in entities:
		var components = entities[id].components
		if components.chunk.rendered == false:
			var node = get_node("/root/Entity/" + str(id))
			
			var chunk = Spatial.new()
			chunk.name = "Chunk"
			node.add_child(chunk)
			
			components.chunk.materials = BlockData.blocks()
			
			var chunk_data = compile(components.chunk.block_data, components.chunk.materials) # Returns blocks_loaded, mesh, vertex_data
			
			connect("rendered", components.chunk.object, components.chunk.method)
			
			var mesh_instance = MeshInstance.new()
			mesh_instance.name = "MeshInstance"
			chunk.add_child(mesh_instance)
			mesh_instance.mesh = chunk_data.mesh
			
			var body = StaticBody.new()
			body.name = "StaticBody"
			mesh_instance.add_child(body)
			
			var collision_shape = CollisionShape.new()
			var shape = ConcavePolygonShape.new()
			shape.set_faces(chunk_data.vertex_data)
			collision_shape.name = "CollisionShape"
			collision_shape.shape = shape
			body.add_child(collision_shape)
			
			Debug.msg("Materials: " + str(components.chunk.materials), "Debug")
			Debug.msg(str(mesh_instance.mesh), "Debug")
			
			chunk.translation = components.chunk.position
			components.chunk.rendered = true
			Entity.edit(id, components)
			emit_signal("rendered")
	
	pass
	# check if we should unload / load chunks
	#create_chunk(position)
	#destroy_chunk(position)
	
	# check if chunks are not compiled
	#compile_chunk()

#func compile_chunk(position):
	#pass

#VoxelTerrain._precalculate_priority_positions()
#VoxelTerrain._precalculate_neighboring()
#VoxelTerrain._update_pending_blocks()

func create_surrounding_chunks(center_chunk): #################################
	var created_chunks = []
	for x in range(3):
		for y in range(3):
			for z in range(3):
				if !(["chunk_index"].has(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))):
					#print("Creating chunk... ")
					create_chunk(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))
				created_chunks.append(Vector3(x + center_chunk.x - 1, y + center_chunk.y - 1, z + center_chunk.z - 1))
	
	for chunk in "chunk_index":
		if created_chunks.has(chunk) == false and ServerSystem.map_seed != -1:
			var node = get_node("/root/World/" + str(chunk.x) + ", " + str(chunk.y) + ", " + str(chunk.z))
			if node != null:
				node.queue_free()
				#chunk_index.erase(chunk)

#func init_chunk(id):
#	if World.map_seed == -1 and chunk_location == Vector3(0, 0, 0):
#		var chunk_data = TerrainGenerator.generate_random_terrain()
#		for position in chunk_data.keys():
#			place_block(chunk_data[position], position)
#		
#		compile()
#	elif World.map_seed == 0:
#		var chunk_data = TerrainGenerator.generate_flat_terrain()
#		for position in chunk_data.keys():
#			place_block(chunk_data[position], position)
#		
#		compile()
#	else:
#		var chunk_data = TerrainGenerator.generate_natural_terrain()
#		for position in chunk_data.keys():
#			place_block(chunk_data[position], position)
#		
#		compile()

func compile(block_data, materials): # Returns blocks_loaded, mesh, vertex_data
	var blocks_loaded = 0
	Debug.msg("Compiling chunk...", "Info")
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = null
	var mesh
	var vertex_data = PoolVector3Array()
	
	#mat.albedo_color = Color(1, 0, 0, 1)
	
	for position in block_data.keys():
	#	if Geometry.can_be_seen(position).size() != 6:
		Debug.msg("Compiling block in position " + str(position), "Trace")
		var cube_data = Geometry.create_cube(position, block_data[position], mesh, vertex_data, materials) # Returns mesh, vertex_data
		mesh = cube_data.mesh
		vertex_data = cube_data.vertex_data
		blocks_loaded += 1
	
	#st.generate_normals(false)
	#st.index()
	#mesh = st.commit()
	
	return {"blocks_loaded" : blocks_loaded, "mesh" : mesh, "vertex_data" : vertex_data}

func load_terrain(): ##########################################################
	# Get the chunk data from the WORLD FILE.
	#Hud.msg("Running GetChunkData on chunk ", ChunkMetadata[i].Address, "...", "Debug")
	var EdenWorldDecoder = load("res://scripts/eden_world_decoder.gd").new()
	EdenWorldDecoder.World = World
	EdenWorldDecoder.set_vars()
	var ChunkData# = EdenWorldDecoder.get_chunk_data(Vector2(chunk_location.x, chunk_location.z))
	World.loaded = true
	if typeof(ChunkData) == TYPE_BOOL:
		var TerrainGenerator = load("res://scripts/terrain_generator.gd").new()
		TerrainGenerator._ready()
		var chunk_data = TerrainGenerator.generate_flat_terrain()
		for position in chunk_data.keys():
			place_block(chunk_data[position], position)
		
		#compile()
		return false
	
	Debug.msg("Creating the chunk mesh... ", "Debug")
	#CreateChunk(ChunkMetadata[i].Address, x, y, z)
	
	# ==============================================================================
	Debug.msg(["Chunk data contains ", ChunkData.size(), " blocks"], "Debug")
	Debug.msg("Placing blocks... ", "Debug")
	# Place all the blocks contained in the chunk data.
	for Blocks in range(ChunkData.size()):
		var position = ChunkData[Blocks].position
		var id = ChunkData[Blocks].id
		
		if position.x < 4:
			place_block(id, position)
	#compile()
	#Status+=1
	#LoadedChunks+=1


func break_block(location): ####################################################
	#Hud.msg("Chunk translation: " + str(translation), "Debug")
	#Hud.msg("Removing block from chunk location " + str(location - translation), "Info")
	#block_data.erase(location - translation)
	pass


func place_block(id, location): ################################################
	#Hud.msg("Chunk translation: " + str(translation), "Debug")
	#Hud.msg("Placing block from chunk location " + str(location - translation), "Info")
	#if id != 0:
		#block_data[location - translation] = id
	
	#set_surface_material(0, "texture")
	pass