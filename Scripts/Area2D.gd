extends Area2D

export var scale = 1.0
onready var parent = self.get_node('..')
onready var __board = self.get_node('/root/Game/Board')

onready var __sample_player = self.get_node('/root/Game/SamplePlayer')


func take_damage(damage):
	self.__sample_player.play('enemy%02d' % int(rand_range(1, 3)))
	self.parent.energy -= damage
	if self.parent.is_in_group('enemy') and self.parent.energy <= 0:
		# here we mark the enemy as dead and toggle its visibility.
		# The game loop (see __start in Game.gd) is responsible to remove
		# dead nodes from the tree
		self.parent.dead = true
		self.parent.hide()
	elif self.parent.is_in_group('player'):
		self.parent.emit_signal('energy_changed', -damage)


func _ready():
	self.__set_shape()
	if self.parent.is_in_group('player'):
		self.connect('area_enter', self, '__on_area_enter')


func __on_area_enter(area):
	if area.is_in_group('item'):
		var animation_player = area.get_node('../AnimationPlayer')
		animation_player.play('pick-feedback')
		self.parent.energy += area.energy_restored
		# we need to erase the 'item' group to resolve sample name
		# with the other group ('fruit', 'soda')
		var groups = area.get_groups()
		groups.erase('item')
		self.__sample_player.play('%s%02d' % [groups[0], int(rand_range(1, 3))])
		self.parent.emit_signal('energy_changed', area.energy_restored)


func __set_shape():
	var dimension = self.__board.get_tile_size() * 0.5
	self.set_pos(dimension)
	self.get_node('CollisionShape2D') \
		.get_shape() \
		.set_extents(dimension * scale)