extends Node2D

@onready var mayhemCounter = %MayhemCounter
@onready var flavorLabel = %FlavorLabel
var mayhem = 0

func _ready():
	flavorLabel.flavor_text("Hello this is a test yes")
	pass

func add_mayhem(amount: int = 1) -> void:
	mayhem += amount
	if mayhem > 5:
		game_over()
		return
	var trigger = ""
	match mayhem:
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

	print("Mayhem counter: ", mayhem)
	mayhemCounter.set_level(mayhem)

func game_over() -> void:
	# Reset the mayhem counter
	mayhem = 0
	mayhemCounter.set_level(mayhem)
	print("Game Over! Mayhem counter reset.")
