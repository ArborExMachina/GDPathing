class_name FlowFollower
extends KinematicBody2D

var map:TileMap
var flow_field:FlowField

func _physics_process(delta):
	var cell = map.world_to_map(global_position)
	var dir = flow_field.get_flow(cell.x, cell.y)
	move_and_collide(dir)
