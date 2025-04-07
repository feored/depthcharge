extends Node2D

@onready var mayhemCounter = %MayhemCounter
@onready var flavorLabel = %FlavorLabel
@onready var gameOver = %GameOver
@onready var timerLabel = %TimerLabel
@onready var waveLabel = %WaveLabel
@onready var waveOver = %WaveOver

var mayhem = Constants.mayhem
var level_time = Constants.LEVEL_TIME


func _physics_process(delta: float) -> void:
	# Update the timer label
	level_time -= delta
	timerLabel.set_text(str(int(level_time)))
	
	if level_time <= 0:
		next_wave()




func _ready():
	mayhemCounter.set_level(Constants.mayhem)
	Music.play_loop(Music.Track.Gameplay)
	waveLabel.set_text("Wave " + str(Constants.current_wave))
	#flavorLabel.flavor_text("Don't mind that fire on the horizon. Everybody's just... having a big party.")
	pass

func add_mayhem(amount: int = 1) -> void:
	#Constants.mayhem += amount
	Constants.mayhem = 1
	if Constants.mayhem > 5:
		game_over()
		return
	var trigger = ""
	match Constants.mayhem:
		1:
			trigger = "tectoid_escape_mayhem_1"
		2:
			trigger = "tectoid_escape_mayhem_2"
		3:
			trigger = "tectoid_escape_mayhem_3"
		4:
			trigger = "tectoid_escape_mayhem_4"
		5:
			trigger = "tectoid_escape_mayhem_4"
	var line = Utils.getLine(trigger)
	if line != "":
		flavorLabel.flavor_text(line)

	print("Mayhem counter: ", Constants.mayhem)
	mayhemCounter.set_level(Constants.mayhem)

func game_over() -> void:
	# Reset the mayhem counter
	self.get_tree().paused = true
	
	Music.play_loop(Music.Track.GameOver)
	print("Game Over! Mayhem counter reset.")
	Constants.current_wave = 0
	Constants.mayhem = 0
	mayhemCounter.set_level(Constants.mayhem)
	# Show the game over screen
	gameOver.show()

func next_wave():
	self.get_tree().paused = true
	Music.play_loop(Music.Track.Victory)
	waveOver.show()


func _on_main_menu_pressed() -> void:
	self.get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_MAIN_MENU)


func _on_next_wave_pressed() -> void:
	Constants.current_wave += 1
	self.get_tree().paused = false
	await SceneTransition.change_scene(SceneTransition.SCENE_LEVEL)
