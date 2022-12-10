extends Node3D

@onready var left_door = $LEFT
@onready var right_door = $RIGHT

@onready var initial_pos
@export var door_size = -6
@export var time_of_closing_opening = 1.0
@export var is_opened = false
@onready var stopped = false
@onready var sound = $DoorSound
@export var vol: float
signal player_near_door(which_door)
var tween: Tween
var sfx

func _ready():
	initial_pos = left_door.position.x
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.stop()
	sfx = load("res://assets/rooms/doorsound.wav")
	sound.set_volume_db(linear_to_db(vol))

# in order to close the door just use negative "how_much" value	
func open_close_door(door1, door2, how_much, how_long):
	if !tween.is_running():
		tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(door1, "position:x", how_much, how_long)
		tween.parallel().tween_property(door2, "position:x", -how_much, how_long)
	
func open():
	open_close_door(left_door, right_door, door_size, time_of_closing_opening)
	
func close():
	open_close_door(left_door, right_door, initial_pos, time_of_closing_opening)
	
func set_tween(tween_usr: Tween) -> void:
	self.tween = tween_usr
	
func _on_yume_player_interact_with_door():
	print(self, "Kod drzwi")
	play_sound()
	is_opened = not is_opened
	
func play_sound():
	if sfx:
		print("halo")
		sound.stream = sfx
		sound.play(0)
		if sound.get_playback_position() > 0.3:
			sound.stop()
	
func _physics_process(_delta):
	if is_opened:
		open()
	elif !is_opened:
		close()
	
		#print(is_closed)
		#if is_closed and not tween.is_running():
		#	open_close_door(left_door, right_door, door_size, time_of_closing_opening)
		#elif !is_closed and not tween.is_running():
		#	open_close_door(left_door, right_door, initial_pos, time_of_closing_opening)
			
func _on_interaction_range_body_entered(body):
	if body.is_in_group("Player"):
		#print("WYKRYWA")
		emit_signal("player_near_door", self)



