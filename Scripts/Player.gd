extends CharacterBody3D


const SPEED = 3.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
var crouch = false
var isFlashlightOut = false
@export var sensitivity = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$AnimationPlayer.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with czzustom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = SPEED
	if Input.is_action_just_pressed("crouch"):
		if !crouch:
			speed = CROUCH_SPEED
			$AnimationPlayer.play("crouch")
			crouch = !crouch
		else:
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0, 2, 0), 1, [self]))
			if result.size() == 0:
				speed = SPEED
				$AnimationPlayer.play("uncrouch")
				crouch = !crouch
	if Input.is_action_just_pressed("flashlight"):
		if isFlashlightOut:
			$AnimationPlayer.play("FlashlightHide")
		else : 
			$AnimationPlayer.play("FlashlightShow")
		isFlashlightOut = !isFlashlightOut
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event):
	if (event is InputEventMouseMotion):
		rotation.y -= event.relative.x / 1000 * sensitivity
		$Camera3D.rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.x = clamp(rotation.x, PI/-2, PI/2)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -2, 2)

