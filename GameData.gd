extends Node

var tile_size = 16
var half_tile_size = 8
var grid_offset_x = 180
var grid_offset_y = 180

# Game globals
var grid_size
var grid_width
var grid_height

var tile_map = []

enum TowerType {
	BASIC_TOWER
}

enum CreepType {
	SLIME_CREEP,
	BEE_CREEP,
	GOBLIN_CREEP
}

enum BulletType {
	BASIC_BULLET
}

var bullet_scene_ref = {
	BulletType.BASIC_BULLET: "res://towers/basic/basic_bullet.tscn",
}

var creep_scene_ref = {
	CreepType.SLIME_CREEP: "res://creeps/slime/slime.tscn",
	CreepType.BEE_CREEP: "res://creeps/bee/bee.tscn",
	CreepType.GOBLIN_CREEP: "res://creeps/goblin/goblin.tscn"
}

var tower_scene_ref =  {
	TowerType.BASIC_TOWER: "res://towers/basic/basic.tscn"
}
