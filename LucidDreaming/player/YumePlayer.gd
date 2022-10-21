extends CharacterBody3D

const SPEED = 10
const JUMP_VELOCITY = 16
const SNEAK = SPEED / 1.5
@export var mouse_sensitivity = 0.01
@export var camera_up_max = 55
@export var camera_down_max = -60

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $neck
@onready var camera := $neck/Camera3d
@onready var vignette := $neck/Camera3d/Sneak/CanvasLayer/Vignette
@onready var yume_animations := $neck/yumejump2/AnimationPlayer


# _unhandled_input was blocking mouse movement when sneaking
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * mouse_sensitivity * 0.2)
			camera.rotate_x(-event.relative.y * mouse_sensitivity * 0.2)
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(camera_down_max),deg_to_rad(camera_up_max))


func set_vignette(visible_on_off) -> void:
	vignette.visible = visible_on_off

func _physics_process(delta):
	#fps check
	print(Engine.get_frames_per_second())    
	
	#vignette turned off when started
	set_vignette(false)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		yume_animations.play("YumeJump")
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if direction:
		
		# Handle Sneak.
		if Input.is_action_pressed("sneak") and is_on_floor():
			# turn vignette on
			set_vignette(true)
			velocity.x = direction.x * SNEAK
			velocity.z = direction.z * SNEAK
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
