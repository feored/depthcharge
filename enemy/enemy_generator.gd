extends Node2D

var enemy_prefab = preload("res://enemy/enemy.tscn")
var elapsed = 0.0

var enemy_prefabs = {
	"Drone": preload("res://enemy/Drone/drone.tscn"),
	# "Conqueror": preload("res://enemy/Conqueror/conqueror.tscn"),
	# "Cannibal": preload("res://enemy/Cannibal/cannibal.tscn"),
	# "Gasbag": preload("res://enemy/Gasbag/gasbag.tscn"),
	"Hulk:": preload("res://enemy/Hulk/hulk.tscn"),
	# "Scrambler": preload("res://enemy/Scrambler/scrambler.tscn"),
	"Sidewinder": preload("res://enemy/Sidewinder/sidewinder.tscn"),
}


func _physics_process(delta):
	elapsed += delta
	if elapsed > 1.0:
		spawn_enemy()
		elapsed = 0.0


func random_enemy():
	var enemy_type = enemy_prefabs.keys()[Utils.rng.randi() % enemy_prefabs.size()]
	return enemy_prefabs[enemy_type]


func spawn_enemy():
	var enemy_instance = random_enemy().instantiate()
	enemy_instance.position = Vector2(
		randf() * Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y + 50
	)
	add_child(enemy_instance)
