class_name FlowField
extends Reference

const UNWALKABLE := 255
const MAX_INTEGRATION := 65535

var _cost := []
var _integration := []
var _flow := []
var _x:int
var _y:int
var _len:int

func _init(rows, columns)->void:
	_x = rows
	_y = columns
	_len = _x * _y
	for _i in range(rows * columns):
		_cost.append(1)
		_integration.append(MAX_INTEGRATION)
		_flow.append(Vector2.ZERO)

func _1D_to_2D(i:int)->Vector2:
# warning-ignore:integer_division
	return Vector2(i % _x, i / _x)

func _2D_to_1D(x:int,y:int)->int:
	return x + y * _x

func set_cost(x:int, y:int, cost:int)->void:
	_cost[_2D_to_1D(x,y)] = cost

func get_cost(x:int,y:int)->int:
	return _cost[_2D_to_1D(x,y)]

func get_flow(x:int, y:int)->Vector2:
	return _flow[_2D_to_1D(x,y)] 

func _get_neighbors4(i:int)->Array:
	var p := _1D_to_2D(i)
	var n := []
	if p.x - 1 >= 0:
		n.append(i-1)
	if p.x + 1 < _x:
		n.append(i+1)
	if p.y + 1 < _y:
		n.append(i + _x)
	if p.y - 1 >= 0:
		n.append(i - _x)
	
	return n

func _get_neighbors8(i:int)->Array:
	var n := []
	for x in [-1,0,1]:
		for y in [-_x, 0, _x]:
			var c = i + x + y
			var p = _1D_to_2D(c)
			if p.x >= 0 and p.x < _x and p.y >= 0 and p.y < _y and c != i:
				n.append(c)
	return n

func _get_min_neighbor(neighbors:Array)->int:
	var min_cost := MAX_INTEGRATION
	var min_n := -1
	for n in neighbors:
		if _integration[n] < min_cost:
			min_cost = _integration[n]
			min_n = n
	return min_n

func calc_integration_field(targI:int)->void:
	for i in range(_x * _y):
		_integration[i] = MAX_INTEGRATION
	
	var open := [targI]
	_integration[targI] = 0
	
	while(len(open) > 0):
		var cur = open.pop_front()
		for n in _get_neighbors8(cur):
			if _cost[n] == UNWALKABLE:
				continue
			var total_cost = _integration[cur] + _cost[n]
			if total_cost < _integration[n]:
				_integration[n] = total_cost
				open.push_back(n)
		
	
func calc_flow_field(target:Vector2)->void:
	var targI = _2D_to_1D(int(target.x), int(target.y))
	calc_integration_field(targI)
	
	for i in range(_len):
#		if _cost[i] == UNWALKABLE:
#			return
		var neighbors = _get_neighbors8(i)
		var min_n = _get_min_neighbor(neighbors)
		var dir := _1D_to_2D(min_n) - _1D_to_2D(i)
		if dir.length() > 1:
			print("dir: %s, from: %s %s, to:%s %s" % [dir, i, _1D_to_2D(i), min_n, _1D_to_2D(min_n)])
		_flow[i] = dir
