# manages and stores entity data
extends Node

var objects = Dictionary()
var delayed = Dictionary()
var unique = 0

func create(components):
	var entity = Dictionary()
	
	entity.id = unique
	unique+=1
	entity.components = components
	
	var node = Node.new()
	node.name = str(entity.id)
	#node.anchor_right = 1
	#node.anchor_bottom = 1
	add_child(node)
	
	objects[entity.id] = entity
	
	return entity.id

func destory(id):
	objects.erase(id)
	get_node(str(id)).queue_free()

func get_entities_with(component):
	var searched = Dictionary()
	for entity in objects.values():
		if entity.components.keys().find(component) != -1:
			searched[entity.id] = entity
	return searched

func edit(id, components):
	var entity = Dictionary()
	
	entity.id = id
	entity.components = components
	
	objects.erase(id)
	objects[entity.id] = entity
	
	return entity.id

func get_component(id, path):
	var data = objects[id].components
	for i in path.split(".", false):
		if data.has(i):
			data = data[i]
		else:
			return false
	return data

func set_component(id, path, value):
	var components = objects[id].components
	DictonaryFunc.setInDict(components, path.split(".", false), value)
	edit(id, components)

func get_node_path(parent): # {id:int, component:string}
	if !parent:
		return "/root/Entity/"
	
	var parents = Array()
	var root = false
	while root == false:
		#Debug.msg("Parent = " + str(parent.id) + parent.component, "Debug")
		parents.append(parent)
		var woah = get_component(parent.id, parent.component + ".parent" )
		
		if woah:
			parent = woah
		else:
			root = true
	
	var path = "/root/Entity/"
	parents.invert()
	for entity in parents:
		var comp = entity.component.capitalize().split(" ").join("")
		
		path += str(entity.id) + "/" + comp + "/"
	
	return path

func add_node(id, component, node):
	var path = Entity.get_node_path(Entity.get_component(id, component + ".parent"))
	
	if get_tree().get_root().has_node(path):
		if !get_node(path).has_node(path + str(id)):
			var entity = Control.new()
			entity.name = str(id)
			entity.mouse_filter = Control.MOUSE_FILTER_PASS
			get_node(path).add_child(entity)
		
		get_node(path + str(id)).add_child(node)
	else:
		Debug.msg("Parent node doesn't exist yet!", "Warn")
		return false
	
	inherit_child_rect(id, component)
	Entity.set_component(id, component + ".rendered", true)
	return path

func inherit_child_rect(id, component): # component string
	var parent = get_node(get_node_path(get_component(id, component + ".parent")) + str(id))
	var child = get_node(get_node_path(get_component(id, component + ".parent")) + str(id) + "/" + component.capitalize().split(" ").join(""))
	if parent is Control:
		parent.size_flags_horizontal = Control.SIZE_FILL
		if component != "joystick":
			parent.size_flags_vertical = Control.SIZE_FILL
		parent.rect_min_size.y = child.rect_min_size.y
		parent.rect_size = child.rect_size
		parent.margin_bottom = 0
		parent.margin_left = 0
		parent.margin_right = 0 
		parent.margin_top = 0
		
	