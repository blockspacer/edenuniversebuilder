extends GridMap

onready var blocks = preload("res://block.meshlib").duplicate()
onready var World = get_node("/root/World")

var chunk_location = Vector3(0, 0, 0)

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

	if World.world_seed == 0:
		if chunk_location.y == 0:
			print("translation is equal to ", chunk_location)
			generate_flat_terrain()
	elif World.world_seed == -1:
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
