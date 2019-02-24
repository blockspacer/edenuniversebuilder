extends GridMap

onready var blocks = preload("res://block.meshlib")
onready var World = get_node("/root/World")

func _ready():
	
	# tex order = right, front, back, left, top, bottom
	generate_block_mesh(1, "bedrock", single_sided_block("dark_stone"))
	generate_block_mesh(2, "stone", single_sided_block("greystone"))
	generate_block_mesh(3, "dirt", single_sided_block("dirt"))
	generate_block_mesh(4, "sand", single_sided_block("sand"))
	generate_block_mesh(5, "leaves", single_sided_block("leaves_green"))
	generate_block_mesh(6, "trunk", single_sided_block("tree_exterior"))
	generate_block_mesh(7, "wood", single_sided_block("wood"))
	generate_block_mesh(8, "grass", single_sided_block("grass"))
	generate_block_mesh(9, "tnt", single_sided_block("tnt"))
	generate_block_mesh(10, "rock", single_sided_block("bedrock"))

	# assign mesh library to the chunk
	theme = blocks
	cell_size = Vector3(1, 1, 1)
	cell_center_x = true
	cell_center_y = true
	cell_center_z = true

	if World.world_seed == 0:
		print(blocks.find_item_by_name("grass"))
		print(get_meshes())
		generate_flat_terrain()
		#set_cell_item(0, 0, 0, 8, 0)
		#set_cell_item(0, 2, 0, 1, 0)

func generate_flat_terrain():
	for x in range(16):
		for y in range(16):
			for z in range(16):
				set_cell_item(x, y, z, 1, 0)
				#print(str(x, ", ", y, ", ", z))
	make_baked_meshes()

func generate_block_mesh(id, block_name, textures):
	var item_mesh = blocks.get_item_mesh(0)
	var item_shapes = blocks.get_item_shapes(0)
	blocks.create_item(id)
	
	for i in range(0, textures.size()):
		var mat = SpatialMaterial.new()
		print("res://textures/" + textures[i] + ".png")
		var tex = load("res://textures/" + textures[i] + ".png")
		mat.albedo_texture = tex
		mat.uv1_scale = Vector3(3, 3, 3)
		item_mesh.surface_set_material(i, mat)
	
	# create navmesh
	blocks.set_item_mesh(id, item_mesh)
	blocks.set_item_shapes(id, item_shapes)
	blocks.set_item_name(id, block_name)

func single_sided_block(data):
	var arr = Array()
	for i in range(6):
		arr.append(data)
	return arr

func break_block(x, y, z):
	set_cell_item(x, y, z, -1, 0)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
