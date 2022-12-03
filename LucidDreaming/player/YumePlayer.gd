extends CharacterBody3D

const SPEED = 5
const JUMP_VELOCITY = 8
const SNEAK = SPEED / 1.5
@export var mouse_sensitivity = 0.01
@export var camera_up_max = 55
@export var camera_down_max = -60
@export var allow_mouse = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $neck
@onready var feet := $neck/feet
@onready var camera := $neck/feet/Camera3d
@onready var vignette := $neck/feet/Camera3d/Sneak/CanvasLayer/Vignette
@onready var yume_animations := $neck/feet/GIGACHADYume/AnimationPlayer
@onready var yume_tween
@onready var door = $"../NavigationRegion3d/DOORS/openableDoor"
@onready var is_near_door: bool
@onready var is_near_wall: bool

#audio
@onready var yumeMovementAudio =  $neck/feet/YumeMovementSounds
@onready var ambient = $Ambient
@export var pitch: float
@export var running_volume: float
@onready var currentDoor
signal interact_with_door()
enum movementAudio{
	running,
	walking,
	sneaking,
	jumping,
	standing
}
var currentState = movementAudio.running

#AudioStreamPlayer3D

func _ready():
	door.set_tween(door.create_tween())
	is_near_door = false
	is_near_wall = false
	pass

# _unhandled_input was blocking mouse movement when sneaking
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion and allow_mouse:
			neck.rotate_y(-event.relative.x * mouse_sensitivity * 0.2)
			camera.rotate_x(-event.relative.y * mouse_sensitivity * 0.2)
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(camera_down_max),deg_to_rad(camera_up_max))

func peek(how_long, rotation_amount, r_or_l, _direction):
	allow_mouse = false
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(feet, "rotation:z", deg_to_rad(rotation_amount * r_or_l) , how_long)
	if is_near_wall:
		tween.pause()
		
	
func set_vignette(visible_on_off) -> void:
	vignette.visible = visible_on_off
	
func _on_openable_door_player_near_door(which_door):
	currentDoor = which_door
	is_near_door = true
	pass # Replace with function body.

func _on_wall_detector_body_entered(body): # maska i layer scianowy (2)
	is_near_wall = true
	
func _on_wall_detector_body_exited(body):
	is_near_wall = false

func yume_running_sounds(choice, volume, pitch_h, audio):
	audio.set_pitch_scale(pitch_h)
	var sfx = load(choice)
	if sfx and !audio.playing:
		audio.stream = sfx
		audio.set_volume_db(linear_to_db(volume))
		audio.play()

func _physics_process(delta):
	#fps check
	print(Engine.get_frames_per_second())    
	
	#vignette turned off when started
	set_vignette(false)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#print((neck.transform.basis.x + neck.transform.basis.z).normalized())
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if	Input.is_action_pressed("forward") and not yume_animations.is_playing() and is_on_floor():
			
			yume_animations.playback_speed = 1
			yume_animations.play("Armature|mixamocom|Layer0001")
			currentState = movementAudio.running
			
		elif Input.is_action_pressed("back") and not yume_animations.is_playing() and is_on_floor():
			
			yume_animations.playback_speed = 1
			yume_animations.play_backwards("Armature|mixamocom|Layer0001")
			currentState = movementAudio.running
				# Handle Sneak
		if Input.is_action_pressed("sneak") and is_on_floor():
			# turn vignette on
			yume_animations.playback_speed = 0.5
			yume_animations.play("Armature|mixamocom|Layer0001")
			currentState = movementAudio.sneaking
			set_vignette(true)
			velocity.x = direction.x * SNEAK
			velocity.z = direction.z * SNEAK
	else: #stanie w miejscu
		currentState = movementAudio.standing
		if Input.is_action_pressed("sneak") and is_on_floor(): # wychylanie sie
			set_vignette(true)
			if Input.is_action_pressed("peek_right") and is_on_floor():
				peek(0.5, 100, -1, direction)
				peek(0.5, 0, 1,direction)
			if Input.is_action_pressed("peek_left") and is_on_floor():
				peek(0.5, 100, 1,direction)
				peek(0.5, 0, -1,direction)
			#print(rad_to_deg(feet.rotation.z))
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_released("interact") and is_on_floor() and is_near_door:
		print(currentDoor)
		var callable = Callable(currentDoor, "_on_yume_player_interact_with_door")
		# Option 2: Object.connect() with a constructed Callable using a target object and method name.
		self.interact_with_door.connect(callable)
		emit_signal("interact_with_door")
		if self.is_connected("interact_with_door", callable):
			self.disconnect("interact_with_door", callable)
	if rad_to_deg(feet.rotation.z) > -30  and rad_to_deg(feet.rotation.z) < 30: # allow mouse movement after peek
				allow_mouse = true	
		# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		currentState = movementAudio.jumping
		yume_animations.playback_speed = 1.35
		#yume_animations.play("YumeWalk")
		velocity.y = JUMP_VELOCITY			
	
	move_and_slide()
	# handle audio
	yume_running_sounds("res://player/ambient.wav", 0.01, 0.4, ambient)
	match currentState:
		movementAudio.running:
			yume_running_sounds("res://player/running.wav", 0.3, pitch, yumeMovementAudio)
		movementAudio.standing:
			yumeMovementAudio.stop()
		movementAudio.sneaking:
			yume_running_sounds("res://player/running.wav", 0.1, 0.45, yumeMovementAudio)
		movementAudio.jumping:
			yumeMovementAudio.stop()
	


