extends CharacterBody3D

@onready var camera = $camera
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals
@onready var camera_3d = $camera/Camera3D

const JUMP_VELOCITY = 4.5
var SPEED = 3.0
var RUN_SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func ScreenPointToRay():
	var spaceState = get_world_3d().direct_space_state
	
	var mousePos = get_viewport().get_mouse_position()
	#var camera1 = get_tree().root.get_camera_3d()
	var rayOrigin = camera_3d.project_ray_origin(mousePos)
	var rayEnd = rayOrigin - camera_3d.project_ray_normal(mousePos*2000)
	var rayArray = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd))
	if rayArray.has("position"):
		return rayArray["position"]
	return Vector3()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if 	Input.is_action_pressed("sprint"):
			if animation_player.current_animation != "running":
				animation_player.play("running")
			visuals.look_at(position+direction)
			velocity.x = direction.x * RUN_SPEED
			velocity.z = direction.z * RUN_SPEED
		else:
			if animation_player.current_animation != "walking":
				animation_player.play("walking")
			visuals.look_at(position+direction)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	visuals.look_at(ScreenPointToRay(),Vector3.UP)
