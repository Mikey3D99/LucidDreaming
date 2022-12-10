extends CharacterBody3D

@onready var floater_animations := $Floater/AnimationPlayer
@onready var target_location = $"../YumePlayer"
@export var speed = 1
@export var turn_speed = 0.33 + speed
@export var volume = 0.2
@onready var eyes = $Eyes
@onready var walk = true
@onready var start_turning = false
@onready var yume_camera = $"../YumePlayer/neck/feet" # wysyla wiazke do stop zeby nie wykrywal zza rogu
@onready var audio = $AudioStreamPlayer3d
@onready var sounds: Array
@onready var sounds_path = "res://assets/jumpscares/Floater/Sounds/Lament/"
@onready var player_seen = false
@onready var player_death = false
@onready var jumpscare_scene = "res://assets/jumpscares/scenes/FloaterJumpscare.tscn"
@onready var player_screen = $"../YumePlayer/neck/feet/Camera3d/Jumpscare/CanvasLayer/Vignette"
@onready var curr_amount
@onready var tween: Tween
@onready var nav_agent = $"../NavigationAgent3D"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
enum States{
	patrol,
	chasing,
	hunting,
	seeking
}
var currentState: States
@export var waypoints : Array
var waypointIndex : int


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
		
func randomize_sounds():
	if not audio.is_playing():
		var choice = sounds[randi() % sounds.size()]
		var pitch = (float)(20 + randi() % 60) / 100
		audio.set_pitch_scale(pitch)
		#print(pitch, choice, audio.get_volume_db())
		var sfx = load(choice)
		if sfx:
			audio.stream = sfx
			audio.play()
	
func darken_the_world( interval, amount):
	var temp_timer = Timer.new()
	var curr_intensity = player_screen.material.get_shader_parameter("vignette_intensity")
	temp_timer.set_wait_time(interval)
	if temp_timer.is_stopped():
		player_screen.material.set_shader_parameter("vignette_intensity", curr_intensity + amount )
	
func _ready():
	nav_agent = $NavigationAgent3d
	currentState = States.patrol
	audio.set_volume_db(linear_to_db(volume)) 
	load_sounds(sounds_path)
	curr_amount = 0
	tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	waypoints = get_tree().get_nodes_in_group("EnemyWaypoint")
	waypointIndex = 0
	tween.stop()
	
	pass

func observe(target):
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))

func follow(delta, target):
	if target.global_position:
		nav_agent.set_target_location(target.global_position)
	if nav_agent.is_target_reachable():
		var next_location = nav_agent.get_next_location()
		var direction = global_position.direction_to(next_location)
		global_position += direction * delta * speed * 2

		
func walk_forward(delta):
	var direction = (transform.basis * Vector3.FORWARD).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	
func _on_sight_range_body_entered(body):
	if body.is_in_group("Player"):
		player_seen = true

func _on_sight_range_body_exited(body):
	if body.is_in_group("Player"):
		currentState = States.seeking

func _on_turn_range_body_entered(body):
	
	if currentState == States.patrol and not body.is_in_group("SightFloater"):
		walk = false
		start_turning = true
		
	elif currentState == States.chasing and body.is_in_group("Player"): # death with jumpscare
		currentState = States.hunting
		player_death = true
		
func _on_turn_range_body_exited(_body):
	walk = true
	
func _on_jumpscare_range_body_entered(body):
	if body.is_in_group("Player"):
		player_death = true
	pass # Replace with function body.
	
# wyslij ray z enemy do player kamery i zrob cos
func ray_to_player():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, yume_camera.global_position, 1, []))
	#print(result)
	if result.size() > 0:
		if result["collider"].is_in_group("Player"):
			if player_seen and player_death == false:
				currentState = States.chasing
			elif player_seen and player_death == true:
				currentState = States.hunting
		else:
			currentState = States.patrol
			
func follow_path(delta):
	#print(waypoints[waypointIndex])
	follow(delta, waypoints[waypointIndex])
	observe(waypoints[waypointIndex])
	if nav_agent.is_target_reached():
		waypointIndex += 1
		if waypointIndex > waypoints.size() - 1:
				waypointIndex = 0
	
func _physics_process(delta):
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	ray_to_player()
	
	floater_animations.play("Armature|mixamocom|Layer0001")
	randomize_sounds()
	#print(currentState)
	match currentState:
		
		States.patrol: # patrol
			follow_path(delta)
			pass
		States.chasing: # goni gracza
			observe(target_location)
			follow(delta, target_location)
			speed = 2
			pass
		States.hunting: # zabija gracza jumpsacre itp
			observe(target_location)
			get_tree().change_scene_to_file(jumpscare_scene)
			pass
		States.seeking: # obraca sie szukajac gracza przez iles sekund i wraca do stanu patrol
			follow(delta, target_location)
			pass
	move_and_slide()
	#var pos = $"../YumePlayer".get_position()
	#shadow_hunt(delta)

