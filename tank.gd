extends CharacterBody2D

@export var speed = 100
@export var ground: TileMapLayer

@onready var radar : Node2D = %Radar
@onready var sprite : AnimatedSprite2D = %TankSprite

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

var last_bullet = {
	Slot.Left: null,
	Slot.Right: null,
}

func get_input():
	var direction_x: float = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	var input_direction = Vector2(direction_x, 0).normalized()
	velocity = input_direction * speed

func _physics_process(delta):
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
		fire_bullet(slot, equipped_weapons[slot])

	

func fire_bullet(slot:Slot, weapon: String) -> void:
	var weapon_instance = weapon_prefab.instantiate()
	weapon_instance.ground = ground
	weapon_instance.position = self.position + Vector2(-weapon_instance.SIZE.x / 2 if not sprite.flip_h else weapon_instance.SIZE.x / 2 , weapon_instance.SIZE.y + 10)
	weapon_instance.rotation = rotation
	weapon_instance.set_weapon(equipped_weapons[slot])
	self.add_child(weapon_instance)
	last_bullet[slot] = weapon_instance

func remote_weapon(slot: Slot) -> void:
	if last_bullet[slot] != null:
		last_bullet[slot].remote_explode()
		last_bullet[slot] = null
		return
	fire_bullet(slot, equipped_weapons[slot])
