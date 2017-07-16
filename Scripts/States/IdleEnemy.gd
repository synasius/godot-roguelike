extends 'Base.gd'

const EPSILON = 1e-8

func enter(entity):
    var delta_xy
    var player = entity.get_node('../Player')
    var player_pos = player.get_pos()
    var self_pos = entity.get_pos()
    if abs(self_pos.x - player_pos.x) < EPSILON:
        if self_pos.y < player_pos.y:
            delta_xy = entity.UNIT_DOWN
        else:
            delta_xy = entity.UNIT_UP
    else:
        if self_pos.x < player_pos.x:
            delta_xy = entity.UNIT_RIGHT
        else:
            delta_xy = entity.UNIT_LEFT
    var state = self.__parent.get_node('Moving')
    state.delta_xy = delta_xy
    entity.transition_to(state)