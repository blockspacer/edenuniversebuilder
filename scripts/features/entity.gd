# manages and stores entity data
extends Node

var objects = Dictionary()
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