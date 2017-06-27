extends Area2D

export var scale = 1.0
onready var __board = self.get_node('/root/Game/Board')

func _ready():
	self.__set_shape()

func __set_shape():
	var dimension = self.__board.get_tile_size() * 0.5
	self.set_pos(dimension)
	self.get_node('CollisionShape2D') \
		.get_shape() \
		.set_extents(dimension * scale)