extends Control
@onready var tween: Tween
@onready var player_screen = $CanvasLayer/ColorRect
@export var curr_spread : float

func _ready():
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_EXPO)
	tween.stop()
	curr_spread = 0.01
	pass # Replace with function body.

func animate_abberation():
	if not tween.is_running():
		print("animuj sie")
		var curr_spread = player_screen.material.get_shader_parameter("spread")
		tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(player_screen, "material:shader_param/spread", 0.3, 0.01)
		tween.tween_property(player_screen, "material:shader_param/spread", 0.1, 0.01)
		tween.parallel().tween_property(player_screen, "material:shader_param/levels", 50, 0.01)
		tween.tween_property(player_screen, "material:shader_param/levels", 10, 0.01)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animate_abberation()
	pass
