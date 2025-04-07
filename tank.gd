extends CharacterBody2D
class_name Tank

@export var speed = 100
@export var ground: TileMapLayer

@onready var radar : Node2D = %Radar
@onready var sprite : AnimatedSprite2D = %TankSprite


var left_weapon_bar = null
var right_weapon_bar = null
var left_weapon_icon = null
var right_weapon_icon = null

var weapon_prefab = preload("res://weapons/weapon.tscn")
var last_velocity : Vector2 = Vector2.ZERO

var idle = true
var last_move_sfx = 0.0
var time_elapsed = 0.0


enum Slot{
	Left,
	Right,
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
	if GameState.upgrades.has("BiggerEngine"):
		speed = speed * 1.2
	# Initialize weapon bars
	left_weapon_bar = Utils.getLevel().get_node("%LWep")
	right_weapon_bar = Utils.getLevel().get_node("%RWep")
	left_weapon_icon = Utils.getLevel().get_node("%LWepIcon")
	right_weapon_icon = Utils.getLevel().get_node("%RWepIcon")

	# Set weapon icons
	if GameState.equipped_weapons[Slot.Left] != null:
		left_weapon_icon.texture = Data.Weapons[GameState.equipped_weapons[Slot.Left]].icon
	if GameState.equipped_weapons[Slot.Right] != null:
		right_weapon_icon.texture = Data.Weapons[GameState.equipped_weapons[Slot.Right]].icon
	
func get_cd(slot: Slot) -> float:
	var base_cd = Data.Weapons[GameState.equipped_weapons[slot]].cooldown
	if GameState.upgrades.has("BiggerGenerator"):
		base_cd = base_cd * 0.8
	if GameState.upgrades.has("LastStand") and GameState.mayhem > 4:
		base_cd = base_cd * 0.8
	return base_cd

func switch_weapon(slot, new_weapon):
	GameState.equipped_weapons[slot] = new_weapon
	current_cd[slot] = 0
	last_bullet[slot] = null
	
	if slot == Slot.Left:
		left_weapon_icon.texture = Data.Weapons[GameState.equipped_weapons[Slot.Left]].icon
	else:
		right_weapon_icon.texture = Data.Weapons[GameState.equipped_weapons[Slot.Right]].icon


func get_input():
	var direction_x: float = Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left")
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	var input_direction = Vector2(direction_x, 0).normalized()
	velocity = input_direction * speed

func _physics_process(delta):
	time_elapsed += delta
	# Update cooldowns
	current_cd[Slot.Left] -= delta
	current_cd[Slot.Right] -= delta
	if current_cd[Slot.Left] < 0:
		current_cd[Slot.Left] = 0
	if current_cd[Slot.Right] < 0:
		current_cd[Slot.Right] = 0
	if left_weapon_bar != null:
		left_weapon_bar.value = float(current_cd[Slot.Left]) / get_cd(Slot.Left)*100
	if right_weapon_bar != null:
		right_weapon_bar.value = float(current_cd[Slot.Right]) / get_cd(Slot.Right)*100


	get_input()

	if velocity.x < 0 && last_velocity.x >= 0 or velocity.x > 0 && last_velocity.x <= 0:
		sprite.flip_h = velocity.x > 0
	if velocity.x == 0:
		sprite.play("idle")
		idle = true
	else:
		# if idle:
		# 	last_move_sfx = time_elapsed
		# 	Sfx.play(Sfx.Track.Movement)
		# 	idle = false
		# elif time_elapsed - last_move_sfx > 0.35:
		# 	last_move_sfx = time_elapsed
		# 	Sfx.play(Sfx.Track.Movement)
		sprite.play("move")
	
	if velocity.x < 0 and position.x < 0:
		velocity.x = 0
	if velocity.x > 0 and position.x > Constants.SCREEN_SIZE.x:
		velocity.x = 0

	if last_bullet[Slot.Left] != null and Data.Weapons[GameState.equipped_weapons[Slot.Left]].timed:
		if not last_bullet[Slot.Left].timed_launched:
			last_bullet[Slot.Left].position = self.position + get_bullet_offset(last_bullet[Slot.Left])
	
	if last_bullet[Slot.Right] != null and Data.Weapons[GameState.equipped_weapons[Slot.Right]].timed:
		if not last_bullet[Slot.Right].timed_launched:
			last_bullet[Slot.Right].position = self.position + get_bullet_offset(last_bullet[Slot.Right])
	move_and_slide()

	if Input.is_action_just_pressed("shoot"):
		shoot_weapon(Slot.Left)

	if Input.is_action_just_pressed("shoot_2"):
		shoot_weapon(Slot.Right)

	if Input.is_action_just_released("shoot"):
		if Data.Weapons[GameState.equipped_weapons[Slot.Left]].remote or Data.Weapons[GameState.equipped_weapons[Slot.Left]].timed:
			shoot_weapon(Slot.Left)

	if Input.is_action_just_released("shoot_2"):
		if Data.Weapons[GameState.equipped_weapons[Slot.Right]].remote or Data.Weapons[GameState.equipped_weapons[Slot.Right]].timed:
			shoot_weapon(Slot.Right)

func shoot_weapon(slot: Slot):
	if GameState.equipped_weapons[slot] == null:
		return
	if Data.Weapons[GameState.equipped_weapons[slot]].remote:
		print("Weapon " + GameState.equipped_weapons[slot] + " is remote")
		remote_weapon(slot)
	elif Data.Weapons[GameState.equipped_weapons[slot]].timed:
		timed_weapon(slot)
	else:
		if current_cd[slot] > 0:
			print("Weapon " + GameState.equipped_weapons[slot] + " on cooldown")
			Sfx.play(Sfx.Track.Misfire)
			return
		else:		
			fire_bullet(slot, GameState.equipped_weapons[slot])
			if GameState.upgrades.has("TandemPylon"):
				if GameState.equipped_weapons[slot] == "Basic Driller":
					fire_bullet(slot, GameState.equipped_weapons[slot], true)
	

func fire_bullet(slot:Slot, weapon: String, double = false) -> void:
	if Data.Weapons[weapon].fire_sfx != null:
		Sfx.play(Data.Weapons[weapon].fire_sfx)
	
	var weapon_instance = weapon_prefab.instantiate()
	weapon_instance.ground = ground
	weapon_instance.position = self.position + get_bullet_offset(weapon_instance)
	if double:
		var bullet_offset = get_bullet_offset(weapon_instance)
		weapon_instance.position.x += bullet_offset.x * 2
	weapon_instance.rotation = rotation
	weapon_instance.set_weapon(GameState.equipped_weapons[slot])
	self.add_child(weapon_instance)
	last_bullet[slot] = weapon_instance
	current_cd[slot] = get_cd(slot)
	print("Weapon cooldown: " + str(get_cd(slot)))


func get_bullet_offset(weapon_instance):
	return Vector2(-weapon_instance.SIZE.x / 2 if not sprite.flip_h else weapon_instance.SIZE.x / 2 , weapon_instance.SIZE.y + 10)

func timed_weapon(slot: Slot) -> void:
	if last_bullet[slot] != null:
		if not last_bullet[slot].timed_launched:
			last_bullet[slot].launch()
			last_bullet[slot] = null
	elif current_cd[slot] > 0:
		print("Weapon " + GameState.equipped_weapons[slot] + " on cooldown")
		Sfx.play(Sfx.Track.Misfire)
		return
	else:
		fire_bullet(slot, GameState.equipped_weapons[slot])

func remote_weapon(slot: Slot) -> void:
	if last_bullet[slot] != null:
		last_bullet[slot].area_explode()
		last_bullet[slot] = null
		return
	if current_cd[slot] > 0:
		print("Weapon " + GameState.equipped_weapons[slot] + " on cooldown")
		Sfx.play(Sfx.Track.Misfire)
		return
	else:
		fire_bullet(slot, GameState.equipped_weapons[slot])
