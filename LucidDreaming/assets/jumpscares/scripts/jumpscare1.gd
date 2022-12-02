extends Node3D

@export var speed = 5
@export var jump_vol = 0.2
@onready var animations = $Floater/AnimationPlayer
@onready var floater = $Floater
@onready var marker = $Marker3d
@onready var audio = $AudioStreamPlayer
@onready var sounds: Array
@onready var main_scene = "res://rooms/startingRoom.tscn"
@onready var timer = $Timer


func load_sounds(path, sounds_array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.ends_with(".wav"):
					sounds_array.append(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func randomize_jumpscare_sounds(sounds_array, pitch_bot, pitch_top, volume):
	var choice = sounds_array[randi() % sounds_array.size()]
	var pitch = (float)(pitch_bot + randi() % pitch_top) / 100
	audio.set_pitch_scale(pitch)
	#print(pitch)
	var sfx = load(choice)
	if sfx:
		audio.stream = sfx
		#audio.set_volume_db(linear_to_db(volume))
		audio.set_volume_db(linear_to_db(volume))
		audio.play()

func follow_path(delta, speed, model, where_to, offset, function):
	#print(where_to.global_position.z,' ', model.global_position.z)
	if snapped(where_to.global_position.z, 0.1) != snapped(model.global_position.z, 0.1):
		model.global_position += -Vector3.FORWARD * delta * speed
	else:
		animations.stop()
		#if not audio.playing:
		if !audio.is_playing(): # death
			if timer.is_stopped():
				randomize_jumpscare_sounds(sounds,30, 50, jump_vol)
			timer.start()
			if not audio.playing:
				get_tree().change_scene_to_file(main_scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_sounds("res://assets/jumpscares/Floater/Sounds/Scream/", sounds)
	timer.set_wait_time(0.1)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animations.play("Armature|mixamocom|Layer0001")
	animations.playback_speed = speed
	follow_path(delta, speed, floater, marker, 3, 0)
	
	pass
#AudioStreamPlayer3D
