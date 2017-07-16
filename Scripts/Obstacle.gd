extends 'Area2D.gd'

const SPRITE_PATH = 'res://Assets/Sprites/TileSet/%s%s.png'

export var sprite = ''
export var hp = 3

onready var __pos_start = self.parent.get_pos()

var __sprite_damage_set = false
var __time = 0
var __time_total = 0.1
var __amplitude = 3


func _ready():
	pass
	#self.parent.set_texture(load(SPRITE_PATH % [self.sprite, '']))

func _process(delta):
	self.__time += delta
	self.parent.set_pos(self.__pos_start + Vector2(randf(), randf()) \
						* 2 * self.__amplitude - Vector2(1, 1) * self.__amplitude)
	if self.__time >= self.__time_total:
		self.parent.set_pos(self.__pos_start)
		self.set_process(false)

func take_damage(damage):
	self.set_process(true)
	self.__time = 0
	self.hp -= damage
	if self.hp < 0:
		self.parent.queue_free()
	if not self.__sprite_damage_set:
		self.parent.set_texture(load(SPRITE_PATH % [self.sprite, '_dmg']))