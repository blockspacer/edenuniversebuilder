extends KinematicBody

onready var World = get_node("/root/World")

var camera_angle = 0
var mouse_sensitivity = 0.3

var velocity = Vector3()
var direction = Vector3()

var build_range = 1000
var camera_width_center = 0
var camera_height_center = 0
var build_origin = Vector3()
var build_normal = Vector3()
var building = 0

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

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	camera_width_center = OS.get_window_size().x / 2
	camera_height_center = OS.get_window_size().y / 2

func _physics_process(delta):
	walk(delta)
	
	if building > 0:
		print("building...")
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(build_origin, build_normal, [self], 1)
		var impulse
		var impact_position
		if result:
			#impulse = (result.position - global_transform.origin).normalised()
			#impact_position = result.position
			#var position = result.positon - result.collider.global_transform.origin
			print("Hit: ", result.position)
			
			var x = int(round(result.position.x))
			var y = int(round(result.position.y))
			var z = int(round(result.position.z))
			
			print("Removing block ", x, ", ", y, ", ", z, "...")
			
			var chunk_x = World.get_chunk(Vector3(x, y, z))
			print("Edding chunk: ", chunk_x, ", ", 0)
			var Chunk = get_node("/root/World/" + str(chunk_x) + ", " + str(0))
			
			Chunk.break_block(x, y, z)
		building = 0

func walk(delta):
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

func fly(delta):
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

func _input(event):
	if event is InputEventMouseMotion:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
	
	if Input.is_action_pressed("build"):
		var camera = $Head/Camera
		build_origin = camera.project_ray_origin(Vector2(camera_width_center, camera_height_center))
		build_normal = camera.project_ray_normal(Vector2(camera_width_center, camera_height_center)) * build_range
		building = 1