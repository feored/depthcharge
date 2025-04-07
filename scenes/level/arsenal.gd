extends Sprite2D


@onready var arsenal_panel = $ArsenalPanel
@onready var weapon_slot_1_texture = %WeaponSlot1Texture
@export var is_left = true

var slot = Tank.Slot.Left
var tank = null

func _ready():
	tank = Utils.getLevel().get_node("%Tank")
	if not is_left:
		slot = Tank.Slot.Right

func _physics_process(delta: float) -> void:
	if tank == null:
		return
	if tank.position.distance_to(self.position) < 50:
		if Input.is_action_just_pressed("arsenal"):
			next_weapon()
		

func toggle_panel():
	if arsenal_panel.visible:
		hide_panel()
	else:
		show_panel()


func next_weapon():
	Sfx.play(Sfx.Track.Cursor)
	var cur_weapon = Data.WeaponsList.find(tank.equipped_weapons[slot])
	var next_weapon_id = (cur_weapon + 1) % Data.WeaponsList.size()
	tank.switch_weapon(slot, Data.WeaponsList[next_weapon_id])
	weapon_slot_1_texture.texture = Data.Weapons[tank.equipped_weapons[slot]].icon

func prev_weapon():
	Sfx.play(Sfx.Track.Cursor)
	var cur_weapon = Data.WeaponsList.find(tank.equipped_weapons[slot])
	var next_weapon_id = (cur_weapon - 1) % Data.WeaponsList.size()
	tank.switch_weapon(slot, Data.WeaponsList[next_weapon_id])
	weapon_slot_1_texture.texture = Data.Weapons[tank.equipped_weapons[slot]].icon

func show_panel():
	weapon_slot_1_texture.texture = Data.Weapons[tank.equipped_weapons[slot]].icon
	arsenal_panel.show()

func hide_panel():
	arsenal_panel.hide()
