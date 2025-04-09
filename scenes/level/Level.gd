extends Node2D

@onready var mayhemCounter = %MayhemCounter
@onready var flavorLabel = %FlavorLabel
@onready var gameOver = %GameOver
@onready var timerLabel = %TimerLabel
@onready var waveLabel = %WaveLabel
@onready var waveOver = %WaveOver
@onready var gameSuccess = %GameSuccess
@onready var upgrades = %Upgrades

var mayhem = GameState.mayhem
var level_time = GameState.level_time
var upgradePanel = preload("res://scenes/level/upgrade_panel.tscn")
var tensecwarning = false


func _physics_process(delta: float) -> void:
	# Update the timer label
	level_time -= delta
	timerLabel.set_text(str(int(level_time)))
	if level_time < 10 and not tensecwarning:
		tensecwarning = true
		var line = Utils.getLine("10_sec_warning")
		if line != "":
			flavorLabel.flavor_text(line)
	if level_time <= 0:
		next_wave()


func try_message(trigger: String):
	print("Trying message: ", trigger)
	var line = Utils.getLine(trigger)
	if line != "":
		flavorLabel.flavor_text(line)

func count_conquerors():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var conquerors = 0
	for enemy in enemies:
		if enemy.id == "Conqueror" and enemy.hits_left > 0:
			conquerors += 1
	return conquerors

func check_conquerors():
	var conquerors = count_conquerors()
	if conquerors > 0:
		return
	Music.play_loop(Music.Track.Gameplay)

func _ready():
	mayhemCounter.set_level(GameState.mayhem)
	if GameState.current_wave == 0:
		GameState.reinitialize()
	Music.play_loop(Music.Track.Gameplay)
	waveLabel.set_text("WAVE " + str(GameState.current_wave + 1))
	#flavorLabel.flavor_text("Don't mind that fire on the horizon. Everybody's just... having a big party.")
	pass

func remove_mayhem(amount: int = 1) -> void:
	GameState.mayhem -= amount
	if GameState.mayhem < 0:
		GameState.mayhem = 0
	mayhemCounter.set_level(GameState.mayhem)

func add_mayhem(amount: int = 1) -> void:
	GameState.mayhem += amount
	#GameState.mayhem = 1
	if GameState.mayhem > 5:
		game_over()
		return
	var trigger = ""
	match GameState.mayhem:
		1:
			trigger = "tectoid_escape_mayhem_1"
		2:
			trigger = "tectoid_escape_mayhem_2"
		3:
			trigger = "tectoid_escape_mayhem_3"
		4:
			trigger = "tectoid_escape_mayhem_4"
		5:
			trigger = "game_over"
	var line = Utils.getLine(trigger)
	if line != "":
		flavorLabel.flavor_text(line)

	print("Mayhem counter: ", GameState.mayhem)
	mayhemCounter.set_level(GameState.mayhem)

func game_over() -> void:
	# Reset the mayhem counter
	self.get_tree().paused = true
	
	Music.play_loop(Music.Track.GameOver)
	print("Game Over! Mayhem counter reset.")
	GameState.current_wave = 0
	GameState.mayhem = 0
	mayhemCounter.set_level(GameState.mayhem)
	# Show the game over screen
	gameOver.show()

func next_wave():
	self.get_tree().paused = true
	Music.play_loop(Music.Track.Victory)
	if GameState.current_wave == Data.LEVELS.size() - 1:
		gameSuccess.show()
	else:
		show_upgrades()
		
func apply_upgrade(upgrade):
	match upgrade.id:
		"Mayhem":
			self.remove_mayhem(1)
		"DiversionOperation":
			GameState.level_time -= 20
		"BiologicalWarfareOperation":
			GameState.enemy_spawn_rate = GameState.enemy_spawn_rate * 0.8

func choose_upgrade(upgrade):
	print("Upgrade chosen: ", upgrade.id)
	Sfx.play(Sfx.Track.PowerUpChosen)
	if upgrade.instant:
		apply_upgrade(upgrade)
	else:
		GameState.upgrades.push_back(upgrade.id)
	if upgrade.id != "Mayhem":
		GameState.available_upgrades.erase(upgrade)

	_on_next_wave_pressed()

func show_upgrades():
	var temp_available_upgrades = GameState.available_upgrades.duplicate()
	var picked_upgrades = []
	for i in range(2):
		var picked_upgrade = temp_available_upgrades[Utils.rng.randi() % temp_available_upgrades.size()]
		picked_upgrades.push_back(Utils.rng.randi() % temp_available_upgrades.size())
		temp_available_upgrades.erase(picked_upgrade)
	for i in range(2):
		var upgrade = upgradePanel.instantiate()
		upgrade.set_upgrade(GameState.available_upgrades[picked_upgrades[i]])
		upgrade.upgrade_selected.connect(choose_upgrade)
		upgrades.add_child(upgrade)
	var upgrade = upgradePanel.instantiate()
	upgrade.set_upgrade(Data.MAYHEM_UPGRADE)
	upgrade.upgrade_selected.connect(choose_upgrade)
	upgrades.add_child(upgrade)
	waveOver.show()

func _on_main_menu_pressed() -> void:
	self.get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)


func _on_next_wave_pressed() -> void:
	GameState.current_wave += 1
	self.get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_LEVEL)
