extends 'Area2D.gd'

export var energy_restored = 20
onready var animation_player = self.get_node('../AnimationPlayer')

func _ready():
	self.connect('area_enter', self, '__on_area_enter')

func __on_area_enter(player_area):
	self.animation_player.play('pick-feedback')
	player_area.get_node('..').energy += self.energy_restored
