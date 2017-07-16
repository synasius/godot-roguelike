extends AnimatedSprite

signal exited
signal energy_changed(by)
signal turn_end

const UNIT_RIGHT = Vector2(1, 0)
const UNIT_DOWN = Vector2(0, 1)
const UNIT_LEFT = Vector2(-1, 0)
const UNIT_UP = Vector2(0, -1)

onready var ray_casts = {
	UNIT_RIGHT: self.get_node('RayCast2DRight'),
	UNIT_DOWN: self.get_node('RayCast2DDown'),
	UNIT_LEFT: self.get_node('RayCast2DLeft'),
	UNIT_UP: self.get_node('RayCast2DUp')
}
onready var __states = self.get_node('/root/Game/States')
onready var __area = self.get_node('Area2D')

var __state

export var damage = 1
export var energy = 100

var dead = false


func transition_to(state):
	"""
	Helper function that sets the state and triggers the `enter` method.
	"""
	self.__state = state
	self.__state.enter(self)

func activate():
	"""
	Move to the initial 'Idle' state.
	"""
	var state_name
	if self.is_in_group('player'):
		state_name = 'IdlePlayer'
	elif self.is_in_group('enemy'):
		state_name = 'IdleEnemy'
	self.transition_to(self.__states.get_node(state_name))

func _ready():
	if Globals.has('player_energy') and self.is_in_group('player'):
		self.energy = Globals.get('player_energy')
	for key in self.ray_casts:
		self.ray_casts[key].add_exception(self.__area)

func _input(event):
	self.__state.input(self, event)

func _fixed_process(delta_time):
	self.__state.update(self, delta_time)