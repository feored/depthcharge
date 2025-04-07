extends Node2D

var enemy_prefab = preload("res://enemy/enemy.tscn")
var elapsed = 0.0

var enemy_prefabs = {
	"Drone": preload("res://enemy/Drone/drone.tscn"),
	# "Conqueror": preload("res://enemy/Conqueror/conqueror.tscn"),
	# "Cannibal": preload("res://enemy/Cannibal/cannibal.tscn"),
	# "Gasbag": preload("res://enemy/Gasbag/gasbag.tscn"),
	"Hulk": preload("res://enemy/Hulk/hulk.tscn"),
	# "Scrambler": preload("res://enemy/Scrambler/scrambler.tscn"),
	"Sidewinder": preload("res://enemy/Sidewinder/sidewinder.tscn"),
}

var level_data: Dictionary


func _ready():
	# Initialize level data
	level_data = Data.LEVELS[GameState.current_wave]
	print("Level data: ", level_data)


func _physics_process(delta):
	elapsed += delta
	if elapsed > GameState.enemy_spawn_rate * level_data.spawn_rate_mult:
		var random_enemy_name = pick_enemy()
		print("Random enemy name: ", random_enemy_name)
		spawn_enemy(random_enemy_name)
		elapsed = 0.0


func pick_enemy():
	var value = Utils.rng.randf()
	for key in enemy_prefabs.keys():
		if value < level_data["enemies"][key]:
			return key
		value -= level_data["enemies"][key]


func random_enemy():
	var enemy_type = enemy_prefabs.keys()[Utils.rng.randi() % enemy_prefabs.size()]
	return enemy_prefabs[enemy_type]


func spawn_enemy(name: String):
	#var enemy_instance = random_enemy().instantiate()
	var enemy_instance = enemy_prefabs[name].instantiate()
	enemy_instance.position = Vector2(
		randf() * Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y + 50
	)
	add_child(enemy_instance)
