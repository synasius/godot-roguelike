extends CanvasLayer

signal started
signal finished(clear)

onready var __label_energy = self.get_node('LabelEnergy')
onready var __panel = self.get_node('Panel')
onready var __panel_label = self.get_node('Panel/Label')
onready var __animation_player = self.get_node('AnimationPlayer')

var __board
var __uis = preload('res://Scripts/UIStr.gd')


func __on_board_finished(board):
	"""
	Here we setup the connections when the board is ready.
	"""
	if not self.__board:
		self.__board = board
	self.__board.player.connect('energy_changed', self, '__on_player_energy_changed')
	self.__board.player.connect('exited', self, '__on_player_exited')
	self.__panel_label.set_text(self.__uis.DAY % Globals.get('day'))
	self.__label_energy.set_text(self.__uis.ENG % self.__board.player.energy)


func __on_player_energy_changed(by):
	# the player gained some energy
	if by > 0:
		self.__animation_player.play('LabelEnergyRestore')
	elif by < 0:
		self.__animation_player.play('LabelEnergyLoose')
	# now we need to change the label
	self.__label_energy.set_text(self.__uis.ENG % self.__board.player.energy)
	# check whether the player is dying to start the fade-in  transition and
	# show the end game text
	if self.__board.player.energy <= 0:
		var day = Globals.get('day')
		self.__panel_label.set_text(self.__uis.END % [day, '' if day == 1 else 'S'])
		self.__animation_player.play('PanelFadeInDie')


func __on_player_exited():
	self.__panel_label.set_text(self.__uis.DAY % Globals.get('day'))
	self.__animation_player.play('PanelFadeIn')