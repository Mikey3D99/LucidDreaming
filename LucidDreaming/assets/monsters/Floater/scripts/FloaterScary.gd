extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var floater_animations := $Floater/AnimationPlayer

@onready var target_location = $"../YumePlayer"
@export var speed = 1
@export var turn_speed = 0.33 + speed
@export var volume = 1
@onready var nav_agent = $NavigationAgent3d
@onready var eyes = $Eyes
@onready var walk = true
@onready var start_turning = false
@onready var timer = $Timer
@onready var yume_camera = $"../YumePlayer/neck/Camera3d"
@onready var audio = $AudioStreamPlayer3d
@onready var sounds: Array
@onready var player_seen = false
@onready var player_death = false
@onready var jumpscare_scene = "res://assets/jumpscares/scenes/FloaterJumpscare.tscn"
@onready var player_screen = $"../YumePlayer/neck/Camera3d/Jumpscare/CanvasLayer/Vignette"
@onready var curr_amount

enum States{
	patrol,
	chasing,
	hunting,
	seeking
}
var currentState: States
var navigationAgent: NavigationAgent3D

func load_sounds(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.ends_with(".wav"):
					sounds.append(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
func randomize_jumpscare_sounds():
	var choice = sounds[randi() % sounds.size()]
	var pitch = (float)(20 + randi() % 60) / 100
	audio.set_pitch_scale(pitch)
	#print(pitch)
	var sfx = load(choice)
	if sfx:
		audio.stream = sfx
		audio.play()
	
func darken_the_world( interval, amount):
	var temp_timer = Timer.new()
	var curr_intensity = player_screen.material.get_shader_parameter("vignette_intensity")
	print(curr_intensity)
	temp_timer.set_wait_time(interval)
	if temp_timer.is_stopped():
		player_screen.material.set_shader_parameter("vignette_intensity", curr_intensity + amount )
	
func _ready():
	#nav_agent.set_target_location(target_location.position)
	currentState = States.patrol
	navigationAgent = $NavigationAgent3d
	timer.set_wait_time(1)
	#load_sounds("res://assets/monsters/floater_assets/")
	curr_amount = 0
	#audio.set_unit_db(volume)
	pass

func observe(target):
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	#print(target.global_transform.origin)
	rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))

func follow(delta):
	if target_location.position:
		nav_agent.set_target_location(target_location.position)
	if nav_agent.is_target_reachable():
		var next_location = nav_agent.get_next_location()
		var direction = global_position.direction_to(next_location)
		global_position += direction * delta * speed
		
		
func walk_forward(delta):
	if walk:
		transform.origin += Vector3(-global_transform.basis.z.x,0,-global_transform.basis.z.z) * delta * speed /2
	
func _on_sight_range_body_entered(body):
	if body.is_in_group("Player"):
		player_seen = true

func _on_sight_range_body_exited(body):
	if body.is_in_group("Player"):
		currentState = States.seeking

func turn(delta):
	rotation.y += clamp(delta * turn_speed, 0, abs(20)) * sign(20)

func _on_turn_range_body_entered(body):
	if currentState == States.patrol and not body.is_in_group("SightFloater"):
		walk = false
		start_turning = true
		timer.set_wait_time((float)(20 + randi() % 60) / 100)
		timer.start()
	if currentState == States.chasing and body.is_in_group("Player"): # death with jumpscare
		currentState = States.hunting
		player_death = true
		
func _on_turn_range_body_exited(body):
	walk = true

func _on_timer_timeout():
	start_turning = false
	timer.stop()
	
# wyslij ray z enemy do player kamery i zrob cos
func ray_to_player():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, yume_camera.global_position, 1, [self]))
	#print(result)
	if result.size() > 0:
		if result["collider"].is_in_group("Player"):
		#	print(result)
			if player_seen and player_death == false:
				currentState = States.chasing
			elif player_seen and player_death == true:
				currentState = States.hunting
		else:
			currentState = States.patrol
	
func _physics_process(delta):
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	ray_to_player()
	
	floater_animations.play("Armature|mixamocom|Layer0001")
	#print(currentState)
	match currentState:
		
		States.patrol: # patrol
			player_seen = false
			walk_forward(delta)
			if start_turning == true:
				turn(delta)
			pass
		States.chasing: # goni gracza
			observe(target_location)
			follow(delta)
			speed = 10
			pass
		States.hunting: # zabija gracza jumpsacre itp
			darken_the_world(0.05, 0.7)
			if player_screen.material.get_shader_parameter("vignette_intensity") >= 100:
				get_tree().change_scene_to_file(jumpscare_scene)
			pass
		States.seeking: # obraca sie szukajac gracza przez iles sekund i wraca do stanu patrol
			follow(delta)
			pass
	#var pos = $"../YumePlayer".get_position()
	#shadow_hunt(delta)











