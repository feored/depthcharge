extends Node

var current_wave = 0
var mayhem = 0
var upgrades = []
var level_time = Constants.LEVEL_TIME
var available_upgrades = Data.Upgrades.duplicate()
var enemy_spawn_rate = Constants.ENEMY_SPAWN_RATE
var barghest_activated = false


func reinitialize():
	# Reset the game state
	current_wave = 0
	mayhem = 0
	upgrades.clear()
	level_time = Constants.LEVEL_TIME
	available_upgrades = Data.Upgrades.duplicate()
	enemy_spawn_rate = Constants.ENEMY_SPAWN_RATE
	barghest_activated = false
