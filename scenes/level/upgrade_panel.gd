extends PanelContainer

signal upgrade_selected(upgrade: Dictionary)

@onready var title = %Title
@onready var description = %Description

var upgrade : Dictionary

func set_upgrade(upgrade: Dictionary) -> void:
	self.upgrade = upgrade
	

func display() -> void:
	title.text = upgrade["title"]
	description.text = upgrade["description"]
	self.show()

func _ready() -> void:
	display()

func _on_button_pressed() -> void:
	upgrade_selected.emit(upgrade)
