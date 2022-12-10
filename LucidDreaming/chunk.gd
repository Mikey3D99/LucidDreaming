extends Node3D
@export var NORTH: Node3D
@export var SOUTH : Node3D
@export var EAST : Node3D
@export var WEST : Node3D

const door = preload("res://assets/rooms/room1/scenes/openableDoor.tscn")

func deleteWall(NSWE):
	#print(NSWE)
	if NSWE:
		NSWE.get_node("walls").queue_free()
	else:
		print("no wall object; perhaps remove a wall after adding it to the tree")
	
func addDoor(NSWE):
	if NSWE:
		print("halo")
		var instance = door.instantiate()
		instance.look_at(self.global_transform.origin, Vector3.UP)
		var node = get_node("/root/startingRoom/YumePlayer")
		var callable = Callable(node, "_on_openable_door_player_near_door")
		instance.player_near_door.connect(callable)
		NSWE.add_child(instance)
		

func _ready():
	NORTH = $walls/NORTH
	SOUTH = $walls/SOUTH
	WEST = $walls/WEST
	EAST = $walls/EAST
