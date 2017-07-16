extends 'Base.gd'

var turn_end = true


func enter(entity):
	entity.set_fixed_process(false)
	entity.set_process_input(false)
	entity.play('idle')

	if turn_end:
		entity.emit_signal('turn_end')
