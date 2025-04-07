extends Node

var current_wave = 0
var mayhem = 2

var upgrades = []
var available_upgrades = Data.Upgrades.duplicate()


func reinitialize():
	# Reset the game state
	current_wave = 0
	mayhem = 2
	upgrades.clear()
	upgrades = ["MoraleBooster"]
	available_upgrades = Data.Upgrades.duplicate()
