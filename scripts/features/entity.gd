# manages and stores entity data
extends Node

var objects = Dictionary()

func create(components):
	var entity = Dictionary()
	
	entity.id = objects.size() + 1
	entity.components = components
	
	objects[entity.id] = entity
	
	return entity.id

func destory(id):
	objects.erase(id)

func get_entities_with(component):
	var searched = Dictionary()
	for entity in objects.values():
		if entity.components.keys().find(component) != -1:
			searched[entity.id] = entity
	return searched