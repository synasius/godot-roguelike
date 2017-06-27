extends 'Base.gd'

export var energy_cost = 5
export var duration = 0.25
var __time_elapsed = 0
var __pos_start
var delta_xy
onready var __board = self.get_node('/root/Game/Board')

func enter(entity):
	entity.set_fixed_process(true)
	entity.set_process_input(false)

	self.__time_elapsed = 0
	self.__pos_start = entity.get_pos()

	if entity.ray_casts[delta_xy].is_colliding():
		var state_name
		if entity.is_in_group('player'):
			state_name = 'IdlePlayer'
		elif entity.is_in_group('enemy'):
			state_name = 'IdleEnemy'
		entity.transition_to(self.__parent.get_node(state_name))

func update(entity, delta_time):
	# compute the movement delta in pixels and the end position
	var delta_xy_px = self.delta_xy * self.__board.get_tile_size()
	var end_pos = self.__pos_start + delta_xy_px

	var pos = self.__pos_start.linear_interpolate(end_pos, self.__time_elapsed / self.duration)

	if self.__time_elapsed > self.duration:
		pos = end_pos
		var state_name
		if entity.is_in_group('player'):
			state_name = 'IdlePlayer'
			entity.energy -= self.energy_cost
		elif entity.is_in_group('enemy'):
			state_name = 'IdleEnemy'
		entity.transition_to(self.__parent.get_node(state_name))

	self.__time_elapsed += delta_time
	entity.set_pos(pos)
