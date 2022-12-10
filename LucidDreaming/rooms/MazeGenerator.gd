extends Node
@export var width = 10
@export var height = 10
@export var cellObject = preload("res://assets/rooms/room1/scenes/anothawall.tscn")
@export var space_between : float
var cells : Array
var currentCell
var backTrackStack = []


func populateCells(): # 1
	
	for row in range(height):
		var current_row = []
		for cell in range(width):
			current_row.append([row, cell, true, true, true, true, false]) # coords, walls, visited
		cells.append(current_row)
	
func spawnCellObjects(): # 2
	#print(cells)
	if cellObject:
		for row in cells:
			for cell in row:
				var instance = cellObject.instantiate()
				var x = 0.0
				var z = 0.0 
				x += instance.position.x + cell[1] * space_between
				z += instance.position.z + cell[0] * space_between
				instance.transform.origin = Vector3(x, 0, z)
				cell.append(instance) # 7 index is object ref
				add_child(instance)
				#instance.deleteWall(instance.WEST)

func allVisited() -> bool:
	for row in cells:
		for cell in row:
			if cell[6] == false:
				return false
	return true
	
func hasUnvisitedNeighbours(currentRow, currentCol):
	var nswe = {
		"north" : false,
		"south" : false,
		"west" : false,
		"east" : false
	}
	
	var indexEast = currentCol + 1
	var indexWest = currentCol - 1
	var indexNorth = currentRow - 1
	var indexSouth = currentRow + 1
	
	if indexEast > len(cells[currentRow]) - 1: # current zawsze visited wiec da na true edge case'y
		indexEast = currentCol
	if indexWest < 0:
		indexWest = currentCol
	if indexNorth < 0:
		indexNorth = currentRow
	if indexSouth > len(cells) - 1:
		indexSouth = currentRow
	
	nswe.east = cells[currentRow][indexEast][6]
	nswe.west = cells[currentRow][indexWest][6]
	nswe.north = cells[indexNorth][currentCol][6]
	nswe.south = cells[indexSouth][currentCol][6]
	
	return !(nswe.east and nswe.west and nswe.south and nswe.north)
	
func chooseRandomUnvisitedNeighbour(currentRow, currentCol):
	var nswe = {
		"north" : false,
		"south" : false,
		"west" : false,
		"east" : false
	}
	var indexEast = currentCol + 1
	var indexWest = currentCol - 1
	var indexNorth = currentRow - 1
	var indexSouth = currentRow + 1
	var unvisitedNeighbours = []
		
	if indexEast > len(cells[currentRow]) - 1: # current zawsze visited wiec da na true edge case'y
		indexEast = currentCol
	if indexWest < 0:
		indexWest = currentCol
	if indexNorth < 0:
		indexNorth = currentRow
	if indexSouth > len(cells) - 1:
		indexSouth = currentRow
		
	var temp  = [ 
	[currentRow, indexEast],
	[currentRow, indexWest],
	[indexNorth, currentCol],
	[indexSouth, currentCol]]
	
	for x in temp:
		var i = x[0]
		var j = x[1]
		if !cells[i][j][6]:
			unvisitedNeighbours.append(x)
			
	return unvisitedNeighbours[randi() % unvisitedNeighbours.size()]
	

func removeWallBetweenCurrentAndChosen(currentCell, chosen):
	var currObject = cells[currentCell[0]][currentCell[1]][7]
	var chosenObject = cells[chosen[0]][chosen[1]][7]
	#print(currentCell, chosen)
	if chosen[0] - currentCell[0] == 1:
		cells[chosen[0]][chosen[1]][2] = false
		currObject.deleteWall(currObject.SOUTH)
		chosenObject.deleteWall(chosenObject.NORTH)
		
	elif chosen[0] - currentCell[0] == -1:
		currObject.deleteWall(currObject.NORTH)
		cells[chosen[0]][chosen[1]][3] = false
		chosenObject.deleteWall(chosenObject.SOUTH)
	elif chosen[1] - currentCell[1] == 1:
		currObject.deleteWall(currObject.EAST)
		chosenObject.deleteWall(chosenObject.WEST)
		cells[chosen[0]][chosen[1]][5] = false
	elif chosen[1] - currentCell[1] == -1:
		currObject.deleteWall(currObject.WEST)
		chosenObject.deleteWall(chosenObject.EAST)
		cells[currentCell[0]][currentCell[1]][5] = false
	
func generateMaze():
	var currentRow = 0
	var currentCol = 0
	cells[currentRow][currentCol][6] = true
	backTrackStack.push_front([0, 0])
	
	while len(backTrackStack) != 0: #there are unvisited nodes
		
		var curr = backTrackStack.pop_front()
		currentRow = curr[0]
		currentCol = curr[1]
		
		if hasUnvisitedNeighbours(currentRow, currentCol):
			backTrackStack.push_front([currentRow, currentCol])
			var nextIndices = chooseRandomUnvisitedNeighbour(currentRow,  currentCol)
			removeWallBetweenCurrentAndChosen([currentRow, currentCol], nextIndices)
			cells[nextIndices[0]][nextIndices[1]][6] = true
			backTrackStack.push_front(nextIndices)
			
func probability(p):
	var rN = randi() % 100
	return  rN < p * 100
			
func addDoors(p):
	for row in cells:
		for cell in row:
			for indx in range(2, 6):
				if cell[indx] == false and probability(p):
					if indx == 2: #north
						cell[7].addDoor(cell[7].NORTH)
					if indx == 3: #south
						cell[7].addDoor(cell[7].SOUTH)
					if indx == 4: #east
						cell[7].addDoor(cell[7].EAST)
					if indx == 5: #west
						cell[7].addDoor(cell[7].WEST)
# Called when the node enters the scene tree for the first time.
func _ready():
	populateCells()
	spawnCellObjects()
	generateMaze()
	addDoors(0.25)
	
	#print(hasUnvisitedNeighbours(0, 0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	pass
