extends CharacterBody2D

@export var speed = 100
@export var ground: TileMapLayer

@onready var radar : Node2D = %Radar
@onready var sprite : AnimatedSprite2D = %TankSprite

var weapon_prefab = preload("res://weapons/weapon.tscn")
var last_velocity : Vector2 = Vector2.ZERO

func get_input():
	var direction_x: float = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	var input_direction = Vector2(direction_x, 0).normalized()
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	if velocity.x < 0 && last_velocity.x >= 0 or velocity.x > 0 && last_velocity.x <= 0:
		sprite.flip_h = velocity.x < 0
	move_and_slide()

	if Input.is_action_just_pressed("shoot"):
		shoot_weapon()

func shoot_weapon():
	var rocket_instance = weapon_prefab.instantiate()
	rocket_instance.ground = ground
	rocket_instance.position = self.position + Vector2(-rocket_instance.SIZE.x / 2 if not sprite.flip_h else rocket_instance.SIZE.x / 2 , rocket_instance.SIZE.y + 10)
	rocket_instance.rotation = rotation
	add_child(rocket_instance)
