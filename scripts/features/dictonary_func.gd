extends Node

# Get a given data from a dictionary with position provided as a list
func getFromDict(dataDict, mapList):    
	for k in mapList: 
		dataDict = dataDict[k]
	return dataDict

# Set a given data in a dictionary with position provided as a list
func setInDict(dataDict, mapList, value):
	var dict = mapList
	dict.remove(dict.size() - 1)
	
	for k in dict: 
		dataDict = dataDict[k]
	dataDict[mapList[-1]] = value

static func merge_dict(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge_dict(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]