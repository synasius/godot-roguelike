extends 'Base.gd'

func enter(entity):
	entity.set_fixed_process(false)
	entity.set_process_input(true)

func input(entity, event):
	var delta_xy

	if event.is_action_pressed('ui_right'):
		delta_xy = entity.UNIT_RIGHT
	elif event.is_action_pressed('ui_left'):
		delta_xy = entity.UNIT_LEFT
	elif event.is_action_pressed('ui_down'):
		delta_xy = entity.UNIT_DOWN
	elif event.is_action_pressed('ui_up'):
		delta_xy = entity.UNIT_UP

	if event.is_action_pressed('ui_right') or event.is_action_pressed('ui_left') \
	   or event.is_action_pressed('ui_down') or event.is_action_pressed('ui_up'):
		var state = self.__parent.get_node('Moving')
		state.delta_xy = delta_xy
		entity.transition_to(state)