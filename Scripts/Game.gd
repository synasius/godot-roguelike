extends Node

export var window_zoom = 1

onready var __board = self.get_node("Board")

func _ready():
	self.__board.fetch_tiles('res://Scenes/TileSet.tscn', 'Exit')
	self.__board.make_board()
	self.__set_screen()

func __set_screen():
	var board_size = self.__board.get_size()
	self.get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, board_size)
	OS.set_window_size(self.window_zoom * board_size)