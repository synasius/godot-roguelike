extends Node

export var window_zoom = 1

onready var __board = self.get_node("Board")
onready var __actors = self.get_node('Board/Actors')

var __stop = false
var __enemy_turn_skip = false
var __ui


func _ready():
	# we call randomize to reset the seed of random generator
	# otherwise the board would be the same every time we play.
	randomize()

	# set the day global to track the number of days the player survives
	if not Globals.has('day'):
		Globals.set('day', 1)

	self.__ui = self.get_node('UI')
	self.__connect_ui()

	self.__board.fetch_tiles('res://Scenes/TileSet.tscn', 'Exit')
	self.__board.make_board()
	self.__set_screen()


func _input(event):
	if event.is_action_pressed('ui_quit'):
		self.get_tree().quit()
	elif event.is_action_pressed('ui_reload'):
		self.__reload_scene(true)


func __reload_scene(clear):
	if clear:
		Globals.clear('player_energy')
		Globals.clear('day')
	self.get_tree().reload_current_scene()


func __connect_ui():
	"""
	Here we connect the signals related to ui changes we proper handlers.
	"""
	self.__board.connect('finished', self.__ui, '__on_board_finished')
	self.__ui.connect('finished', self, '__reload_scene')
	self.__ui.connect('started', self, '__start')


func __set_screen():
	var board_size = self.__board.get_size()
	self.get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, board_size)
	OS.set_window_size(self.window_zoom * board_size)


func __start():
	"""
	Starts the game loop
	"""
	self.__board.player.connect('exited', self, '__on_player_exited')

	while not self.__stop:
		var actors = self.__actors.get_children()
		for actor in actors:
			if weakref(actor).get_ref() != null and actor.dead:
				actor.queue_free()
				continue

			if weakref(actor).get_ref() \
				and (actor.is_in_group('player') or \
					(actor.is_in_group('enemy') and not self.__enemy_turn_skip)):
				if actor.is_in_group('player') and actor.energy <= 0:
					self.__stop = true
					break
				actor.activate()
				yield(actor, 'turn_end')
		self.__enemy_turn_skip = not self.__enemy_turn_skip

	self.set_process_input(true)


func __on_player_exited():
	"""
	Update `player_energy` & `day` after `player`'s `exited` signal is emitted.
	"""
	Globals.set('player_energy', self.__board.player.energy)
	Globals.set('day', Globals.get('day') + 1)