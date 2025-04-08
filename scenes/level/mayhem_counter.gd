extends HBoxContainer

const empty_texture = preload("res://assets/empty_mayhem.tres")
const filled_textures = [
	preload("res://assets/mayhem_4.png"),
	preload("res://assets/mayhem_3.png"),
	preload("res://assets/mayhem_2.png"),
	preload("res://assets/mayhem_1.png"),
	preload("res://assets/mayhem_5_1.png"),
]

@onready var mayhem_cases = [
	$PanelContainer/TextureRect,
	$PanelContainer2/TextureRect,
	$PanelContainer3/TextureRect,
	$PanelContainer4/TextureRect,
	$PanelContainer5/TextureRect,
]

func _ready():
	# Initialize all cases to empty
	empty_all()

func fill_all():
	for case in mayhem_cases.size():
		fill(case)

func empty_all():
	for case in mayhem_cases.size():
		empty(case)

func fill(case: int) -> void:
	if case < 0 or case >= mayhem_cases.size():
		print("Invalid case index: ", case)
		return
	mayhem_cases[case].texture = filled_textures[case]

func empty(case: int) -> void:
	if case < 0 or case >= mayhem_cases.size():
		print("Invalid case index: ", case)
		return
	mayhem_cases[case].texture = empty_texture

func set_level(case: int) -> void:
	for i in range(5):
		if i < case:
			fill(i)
		else:
			empty(i)
