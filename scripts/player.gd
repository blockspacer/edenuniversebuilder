extends KinematicBody

############################## public variables ###############################

onready var World
onready var Hud


var camera_angle = 0
var mouse_sensitivity = 0.3


var velocity = Vector3()
var direction = Vector3()


var build_range = 1000
var building = 0


var move_mode = "walk"
var action_mode = "nothing"


# fly variables
const FLY_SPEED = 40
const FLY_ACCEL = 4


# walk variables
var gravity = -9.8 * 3
const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 30
const ACCEL = 2
const DEACCEL = 6


# jumping
var jump_height = 15




################################### signals ###################################

func _ready(): ################################################################
	Hud = World.Hud
	World.total_players += 1
	#camera_width_center = OS.get_window_size().x / 2
	#camera_height_center = OS.get_window_size().y / 2

func _physics_process(delta):
	if move_mode == "fly":
		fly(delta)
	else:
		walk(delta)
	
	#Hud.msg("Highlighting block...2", "Trace")
	#cast_ray(false)
	
	if building > 0:
		Hud.msg("building...", "Debug")
		cast_ray(true)
		building = 0


func _input(event): ###########################################################
	if event is InputEventMouseMotion:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
	
	if Input.is_action_pressed("fly"):
		if move_mode == "walk":
			move_mode = "fly"
		else:
			move_mode = "walk"
	
	if Input.is_action_pressed("action"):
		var camera = $Head/Camera
		#build_origin = camera.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		#build_normal = camera.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * build_range
		building = 1
	
	if Input.is_action_pressed("burn"):
		action_mode = "burn"
	if Input.is_action_pressed("mine"):
		action_mode = "mine"
	if Input.is_action_pressed("build"):
		action_mode = "build"
	if Input.is_action_pressed("paint"):
		action_mode = "paint"




################################## functions ##################################

func get_orientation(): #######################################################
	var camera = $Head/Camera
	var looking_at = camera.project_ray_normal(OS.get_window_size() / 2)
	#Hud.msg(str(looking_at), "Trace")
	if looking_at.x > 0.5:
		return "north"
	elif looking_at.x < -0.5:
		return "south"
	elif looking_at.y > 0.5:
		return "up"
	elif looking_at.y < -0.5:
		return "down"
	elif looking_at.z > 0.5:
		return "east"
	elif looking_at.z < -0.5:
		return "west"
	else:
		return "invaild"


func get_looking_at(): ########################################################
	#var camera = $Head/Camera
	#var from = camera.project_ray_origin(event.position)
	#var to = from + camera.project_ray_normal(event.position) * 1000
	
	var camera = $Head/Camera
	var space_state = get_world().direct_space_state
	var build_origin = camera.project_ray_origin(OS.get_window_size() / 2)
	var build_normal = camera.project_ray_normal(OS.get_window_size() / 2) * 1000
	
	var result = space_state.intersect_ray(build_origin, build_normal, [self], 1)
	if result:
		#Hud.msg(str(result.position), "Debug")
		return result.position
	else:
		return Vector3(0, 0, 0)


func cast_ray(click): #########################################################
	pass
#		var space_state = get_world().direct_space_state
#		var result = space_state.intersect_ray(build_origin, build_normal, [self], 1)
#		if result:
#			Hud.msg("Hit: " + str(result.position), "Debug")
#
#			var x = int(round(result.position.x))
#			var y = int(round(result.position.y))
#			var z = int(round(result.position.z))
#
#			if x - result.position.x >= 0.4: 
#				x -= 1
#			if y - result.position.y >= 0.4: 
#				y -= 1
#			if z - result.position.z >= 0.4: 
#				z -= 1
#
#			#Hud.msg("Removing block " + str(Vector3(x, y, z)) + "...", "Debug")
#			Hud.msg("Normal: " + str(result.normal), "Debug")
#
#			var normal_x = int(round(result.normal.x))
#			var normal_y = int(round(result.normal.y))
#			var normal_z = int(round(result.normal.z))
#
#			if click == true:
#				Hud.msg("click is true", "Debug")
#				# ================================================================================================================
#				if action_mode == "burn":
#					pass
#				# ================================================================================================================
#				elif action_mode == "mine":
#					if normal_x == 1 and normal_y == 0 and normal_z == 0:
#						x -= 1
#					elif normal_x == 0 and normal_y == 1 and normal_z == 0:
#						y -= 1
#					elif normal_x == 0 and normal_y == 0 and normal_z == 1:
#						x -= 1
#						y -= 1
#						z -= 1
#					elif normal_x == -1 and normal_y == 0 and normal_z == 0:
#						z -= 1
#					elif normal_x == 0 and normal_y == 0 and normal_z == -1:
#						x -= 1
#						y -= 1
#
#					var location = World.get_chunk(Vector3(x, y, z))
#
#					if World.chunk_index.has(location):
#						var Chunk = get_node("/root/World/" + str(location.x) + ", " + str(location.y) + ", " + str(location.z))
#						Chunk.break_block(x, y, z)
#					else:
#						Hud.msg("Invalid chunk!", "Error")
#				# ==================================================================================================================
#				elif action_mode == "build":
#					if normal_x == 1 and normal_y == 0 and normal_z == 0:
#						x -= 1
#					elif normal_x == 0 and normal_y == 1 and normal_z == 0:
#						y -= 1
#					elif normal_x == 0 and normal_y == 0 and normal_z == 1:
#						x -= 1
#						y -= 1
#						z -= 1
#					elif normal_x == -1 and normal_y == 0 and normal_z == 0:
#						z -= 1
#					elif normal_x == 0 and normal_y == 0 and normal_z == -1:
#						x -= 1
#						y -= 1
#
#					var location = World.get_chunk(Vector3(x, y, z))
#
#					if World.chunk_index.has(location):
#						var Chunk = get_node("/root/World/" + str(location.x) + ", " + str(location.y) + ", " + str(location.z))
#						Chunk.place_block(3, x, y, z)
#					else:
#						Hud.msg("Invalid chunk!", "Error")
#				# ==================================================================================================================
#				elif action_mode == "paint":
#					pass
#			# ======================================================================================================================
#			elif click == false:
#				Hud.msg("click is false", "Debug")
#				if normal_x == 1 and normal_y == 0 and normal_z == 0:
#					x -= 1
#				elif normal_x == 0 and normal_y == 1 and normal_z == 0:
#					y -= 1
#				elif normal_x == 0 and normal_y == 0 and normal_z == 1:
#					x -= 1
#					y -= 1
#					z -= 1
#				elif normal_x == -1 and normal_y == 0 and normal_z == 0:
#					z -= 1
#				elif normal_x == 0 and normal_y == 0 and normal_z == -1:
#					x -= 1
#					y -= 1
#
#				var location = World.get_chunk(Vector3(x, y, z))
#
#				if World.chunk_index.has(location):
#					var Chunk = get_node("/root/World/" + str(location.x) + ", " + str(location.y) + ", " + str(location.z))
#					Chunk.place_block(3, x, y, z)
#				else:
#					Hud.msg("Invalid chunk!", "Error")
#			# ======================================================================================================================
#


func walk(delta): #############################################################
	# reset the direction of  the player
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	if Input.is_action_pressed("move_forward") or World.player_move_forward:
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
		
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		
	direction = direction.normalized()
	
	velocity.y += gravity * delta
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else :
		speed = MAX_SPEED
	
	# where would the player go at max speed
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# calcuate a portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	# move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_height


func fly(delta): ##############################################################
	# reset the direction of  the player
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
		
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		
	direction = direction.normalized()
	
	# where would the player go at max speed
	var target = direction * FLY_SPEED
	
	# calcuate a portion of the distance to go
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
	# move
	move_and_slide(velocity)



