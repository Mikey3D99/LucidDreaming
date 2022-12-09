extends Node3D
@export var NORTH: Node3D
@export var SOUTH : Node3D
@export var EAST : Node3D
@export var WEST : Node3D

func deleteWall(NSWE):
	print(NSWE)
	if NSWE:
		$walls.remove_child(NSWE)
	else:
		print("no wall object; perhaps remove a wall after adding it to the tree")

func _ready():
	NORTH = $walls/NORTH
	SOUTH = $walls/SOUTH
	WEST = $walls/WEST
	EAST = $walls/EAST
