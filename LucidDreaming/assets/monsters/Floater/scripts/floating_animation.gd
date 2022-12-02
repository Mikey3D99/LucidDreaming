extends Node3D

@onready var model = $Armature
@onready var tween: Tween

func _ready():
	tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.stop()
	
func floating_animation(amount, time):
	if !tween.is_running():
		tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		tween.tween_property(model, "position:y", amount , time)
		tween.tween_property(model, "position:y", -amount , time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(position.y)
	floating_animation(0.25, 2)
	pass
