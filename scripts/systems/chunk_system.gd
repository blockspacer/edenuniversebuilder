# manages chunk data
# classified as a system because it gets run every frame and scans entities
extends Node

#var commands = [ "create_chunk", "destroy_chunk" ]
var timer = 0
var chunks_processed_this_frame = 0
var chunk_wait_time = 0

var sur_chunk_x = 0
var sur_chunk_z = 0

func _ready():
	Debug.msg("Chunk System ready.", "Info")

func create_chunk(position):
	if position.y != 0:
		return true
	if chunks_processed_this_frame > 1:
		return false
	chunks_processed_this_frame+=1
	
	Debug.msg("Creating chunk " + str(position) + "...", "Debug")
	
	var chunk_data = EdenWorldDecoder.get_chunk_data(position)
	
	if !chunk_data:
		if ServerSystem.map_seed == 0:
			chunk_data = TerrainGenerator.generate_natural_terrain()
		else:
			chunk_data = TerrainGenerator.generate_flat_terrain()
	
	var chunk = Dictionary()
	chunk.rendered = false
	chunk.position = position
	chunk.address = 0
	chunk.gen_seed = 0
	chunk.block_data = chunk_data
	chunk.blocks_loaded = 0
	chunk.mesh = null
	chunk.vertex_data = Array()
	chunk.shape = null
	chunk.materials = Dictionary()
	chunk.entities = Dictionary()
	chunk.object = null
	chunk.method = null
	
	Entity.create({"chunk" : chunk})
	
	return true
	
	

func destroy_chunk(position):
	#var chunk = Dictionary()
	var list = Entity.get_entities_with("chunk")
	for entity in list.values():
		if entity.components.chunk.position == position:
			Entity.destory(entity.id)

signal rendered

func _process(delta):
	chunks_processed_this_frame = 0
	var entities = Entity.get_entities_with("chunk")
	for id in entities:
		var components = entities[id].components
		if components.chunk.rendered == false and chunk_wait_time > 60:
			chunk_wait_time=0
			var node = get_node("/root/World/" + str(id))
			
			var chunk = Spatial.new()
			chunk.name = "Chunk"
			node.add_child(chunk)
			
			var chunk_data = compile(components.chunk.block_data, BlockData.blocks()) # Returns blocks_loaded, mesh, vertex_data
			
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
			
			#Debug.msg("Materials: " + str(components.chunk.materials), "Debug")
			#Debug.msg(str(mesh_instance.mesh), "Debug")
			var pos = components.chunk.position
			chunk.translation = Vector3(pos.x * 16, pos.y * 16, pos.z * 16)
			components.chunk.rendered = true
			ClientSystem.chunk_index.append(pos)
			Entity.edit(id, components)
			
			if components.chunk.object != null or components.chunk.method != null:
				connect("rendered", components.chunk.object, components.chunk.method)
				emit_signal("rendered")
		else:
			chunk_wait_time+=1
	
	entities = Entity.get_entities_with("player")
	for id in entities:
		if get_tree().get_root().has_node("/root/World/" + str(id) + "/Player"):
			if timer >= 100:
				Debug.msg(str(get_chunk(get_node("/root/World/" + str(id) + "/Player").translation)), "Trace")
				Debug.msg("x: " + str(sur_chunk_x), "Debug")
				Debug.msg("z: " + str(sur_chunk_z), "Debug")
				timer=0
			timer+=1
			create_surrounding_chunks(get_chunk(get_node("/root/World/" + str(id) + "/Player").translation))
	
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
	if !(ClientSystem.chunk_index.has(Vector3(sur_chunk_x + center_chunk.x - 1, 0, sur_chunk_z + center_chunk.z - 1))):
		#print("Creating chunk... ")
		create_chunk(Vector3(sur_chunk_x + center_chunk.x - 1, 0, sur_chunk_z + center_chunk.z - 1))
	if sur_chunk_z < 4:
		if sur_chunk_x < 4:
			sur_chunk_x+=1
		else:
			sur_chunk_x=0
			sur_chunk_z+=1
	else:
		sur_chunk_x=0
		sur_chunk_z=0
	
	for x in range(6):
		for z in range(6):
			created_chunks.append(Vector3(x + center_chunk.x - 1, 0, z + center_chunk.z - 1))
	
	var entities = Entity.get_entities_with("chunk")
	for id in entities:
		var components = entities[id].components
		if !created_chunks.has(components.chunk.position):
			ClientSystem.chunk_index.erase(components.chunk.position)
			Entity.destory(id)
		
	for chunk in ClientSystem.chunk_index:
		if created_chunks.has(chunk) == false and ServerSystem.map_seed != -1:
			var path = "/root/World/" + str(chunk.x) + ", " + str(chunk.y) + ", " + str(chunk.z)
			if get_tree().get_root().has_node(path):
				get_node(path).queue_free()
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
		if Geometry.can_be_seen(position, block_data).size() != 6:# and position.y > 20:
			#Debug.msg("Compiling block in position " + str(position), "Trace")
			var cube_data = Geometry.create_cube(position, block_data[position].id, mesh, vertex_data, materials, block_data) # Returns mesh, vertex_data
			mesh = cube_data.mesh
			vertex_data = cube_data.vertex_data
			blocks_loaded += 1
	
	#st.generate_normals(false)
	#st.index()
	#mesh = st.commit()
	Debug.msg("Finished compiling!", "Debug")
	return {"blocks_loaded" : blocks_loaded, "mesh" : mesh, "vertex_data" : vertex_data}


func break_block(chunk_id, location): ####################################################
	#Hud.msg("Chunk translation: " + str(translation), "Debug")
	#Hud.msg("Removing block from chunk location " + str(location - translation), "Info")
	
	var block_data = Entity.get_component(chunk_id, "chunk.block_data")
	block_data.erase(location - Entity.get_component(chunk_id, "chunk.position"))
	Entity.set_component(chunk_id, "chunk.block_data", block_data)

	var chunk_data = compile(Entity.get_component(chunk_id, "chunk.block_data"), Entity.get_component(chunk_id, "chunk.materials")) # Returns blocks_loaded, mesh, vertex_data
	
	get_node("/root/World/" + str(chunk_id) + "/Chunk/MeshInstance").mesh = chunk_data.mesh
	
	var shape = ConcavePolygonShape.new()
	shape.set_faces(chunk_data.vertex_data)
	get_node("/root/World/" + str(chunk_id) + "/Chunk/MeshInstance/StaticBody/CollisionShape").shape = shape

func place_block(chunk_id, block_id, location): ####################################################
	if block_id == 0:
		return
	
	#Hud.msg("Chunk translation: " + str(translation), "Debug")
	#Hud.msg("Removing block from chunk location " + str(location - translation), "Info")
	
	var block_data = Entity.get_component(chunk_id, "chunk.block_data")
	block_data[location - Entity.get_component(chunk_id, "chunk.position")] = block_id
	Entity.set_component(chunk_id, "chunk.block_data", block_data)

	var chunk_data = compile(Entity.get_component(chunk_id, "chunk.block_data"), Entity.get_component(chunk_id, "chunk.materials")) # Returns blocks_loaded, mesh, vertex_data
	
	get_node("/root/World/" + str(chunk_id) + "/Chunk/MeshInstance").mesh = chunk_data.mesh
	
	var shape = ConcavePolygonShape.new()
	shape.set_faces(chunk_data.vertex_data)
	get_node("/root/World/" + str(chunk_id) + "/Chunk/MeshInstance/StaticBody/CollisionShape").shape = shape

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

func get_chunk_id(location):
	var entities = Entity.get_entities_with("chunk")
	for id in entities:
		if Entity.get_component(id, "chunk.position") == location:
			return id
	return false