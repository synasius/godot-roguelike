extends 'Base.gd'

export var energy_cost = 5
export var duration = 0.10

var delta_xy

onready var __board = self.get_node('/root/Game/Board')
onready var __sample_player = self.get_node('/root/Game/SamplePlayer')

var __time_elapsed = 0
var __pos_start


func enter(entity):
	entity.set_fixed_process(true)
	entity.set_process_input(false)

	self.__time_elapsed = 0
	self.__pos_start = entity.get_pos()

	if entity.ray_casts[delta_xy].is_colliding():
		var collider = entity.ray_casts[delta_xy].get_collider()
		var state_name
		if (entity.is_in_group('player') and (collider.is_in_group('obstacle') or collider.parent.is_in_group('enemy'))) or \
		   (entity.is_in_group('enemy') and (collider.is_in_group('obstacle') or collider.parent.is_in_group('player'))):
			collider.take_damage(entity.damage)
			state_name = 'Chopping'
		elif entity.is_in_group('player'):
			state_name = 'IdlePlayer'
		elif entity.is_in_group('enemy'):
			self.delta_xy = Vector2(0, 0)

		if state_name:
			entity.transition_to(self.__parent.get_node(state_name))
	else:
		self.__sample_player.play('footsteps%02d' % int(rand_range(1, 3)))


func update(entity, delta_time):
	# compute the movement delta in pixels and the end position
	var delta_xy_px = self.delta_xy * self.__board.get_tile_size()
	var end_pos = self.__pos_start + delta_xy_px

	var pos = self.__pos_start.linear_interpolate(end_pos, self.__time_elapsed / self.duration)

	if self.__time_elapsed >= self.duration:
		pos = end_pos
		var state = self.__parent.get_node('Inactive')
		if entity.is_in_group('player'):
			entity.energy -= self.energy_cost
			entity.emit_signal('energy_changed', 0) # change the energy label in the UI

			if entity.__area.overlaps_area(self.__board.exit.get_node('Area2D')) and entity.energy > 0:
				# if player is on the `exit` tile at the end of the move, then set `turn_end` (check `Inactive.gd`)
				# to false to break the usual flow of `__start` function from the `Game` node
				state.turn_end = false
				# finally emit the `exited` signal which is used by the UI
				entity.emit_signal('exited')

		entity.transition_to(state)

	self.__time_elapsed += delta_time
	entity.set_pos(pos)
