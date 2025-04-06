extends CharacterBody2D

@export var speed = 100
@export var ground: TileMapLayer

@onready var radar : Node2D = %Radar
@onready var sprite : AnimatedSprite2D = %TankSprite

var left_weapon_bar = null
var right_weapon_bar = null

var weapon_prefab = preload("res://weapons/weapon.tscn")
var last_velocity : Vector2 = Vector2.ZERO

enum Slot{
	Left,
	Right,
}

var equipped_weapons = {
	Slot.Left: "Basic Driller",
	Slot.Right: "Remote Driller",
}

var current_cd = {
	Slot.Left: 0,
	Slot.Right: 0,
}

var last_bullet = {
	Slot.Left: null,
	Slot.Right: null,
}

func _ready():
	# Initialize weapon bars
	left_weapon_bar = Utils.getLevel().get_node("%LWep")
	right_weapon_bar = Utils.getLevel().get_node("%RWep")



func get_input():
	var direction_x: float = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	var input_direction = Vector2(direction_x, 0).normalized()
	velocity = input_direction * speed

func _physics_process(delta):
	# Update cooldowns
	current_cd[Slot.Left] -= delta
	current_cd[Slot.Right] -= delta
	if current_cd[Slot.Left] < 0:
		current_cd[Slot.Left] = 0
	if current_cd[Slot.Right] < 0:
		current_cd[Slot.Right] = 0
	if left_weapon_bar != null:
		left_weapon_bar.value = float(current_cd[Slot.Left]) / Data.Weapons[equipped_weapons[Slot.Left]].cooldown*100
	if right_weapon_bar != null:
		right_weapon_bar.value = float(current_cd[Slot.Right]) / Data.Weapons[equipped_weapons[Slot.Right]].cooldown*100


	get_input()

	if velocity.x < 0 && last_velocity.x >= 0 or velocity.x > 0 && last_velocity.x <= 0:
		sprite.flip_h = velocity.x > 0
	if velocity.x == 0:
		sprite.play("idle")
	else:
		sprite.play("move")

	move_and_slide()

	if Input.is_action_just_pressed("shoot"):
		shoot_weapon(Slot.Left)

	if Input.is_action_just_pressed("shoot_2"):
		shoot_weapon(Slot.Right)

func shoot_weapon(slot: Slot):
	if equipped_weapons[slot] == null:
		return
	if Data.Weapons[equipped_weapons[slot]].remote:
		print("Weapon " + equipped_weapons[slot] + " is remote")
		remote_weapon(slot)
	else:
		if current_cd[slot] > 0:
			print("Weapon " + equipped_weapons[slot] + " on cooldown")
			Sfx.play(Sfx.Track.Misfire)
			return
		else:
			fire_bullet(slot, equipped_weapons[slot])

	
	
	

func fire_bullet(slot:Slot, weapon: String) -> void:
	if Data.Weapons[weapon].fire_sfx != null:
		Sfx.play(Data.Weapons[weapon].fire_sfx)
	
	var weapon_instance = weapon_prefab.instantiate()
	weapon_instance.ground = ground
	weapon_instance.position = self.position + Vector2(-weapon_instance.SIZE.x / 2 if not sprite.flip_h else weapon_instance.SIZE.x / 2 , weapon_instance.SIZE.y + 10)
	weapon_instance.rotation = rotation
	weapon_instance.set_weapon(equipped_weapons[slot])
	self.add_child(weapon_instance)
	last_bullet[slot] = weapon_instance
	current_cd[slot] = Data.Weapons[equipped_weapons[slot]].cooldown


func remote_weapon(slot: Slot) -> void:
	if last_bullet[slot] != null:
		last_bullet[slot].remote_explode()
		last_bullet[slot] = null
		return
	if current_cd[slot] > 0:
		print("Weapon " + equipped_weapons[slot] + " on cooldown")
		Sfx.play(Sfx.Track.Misfire)
		return
	else:
		fire_bullet(slot, equipped_weapons[slot])
