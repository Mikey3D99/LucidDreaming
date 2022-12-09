extends Area3D

@onready var audio : AudioStreamPlayer
@onready var warning = "res://assets/monsters/Floater/run.wav"
@onready var entered = false
@onready var sfx
@export var volume = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	sfx = load(warning)
	audio = $AudioStreamPlayer
	pass # Replace with function body.

func _on_body_entered(body):
	entered = true
	pass # Replace with function body.

func _on_body_exited(body):
	entered = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if entered:
		if sfx and not audio.is_playing():
			audio.stream = sfx
			audio.set_volume_db(linear_to_db(volume))
			audio.play()
	pass





