extends Node2D

var enemy_prefab = preload("res://enemy/enemy.tscn")
var elapsed = 0.0


func _physics_process(delta):
	elapsed += delta
	if elapsed > 1.0:
		spawn_enemy()
		elapsed = 0.0


func spawn_enemy():
	var enemy_instance = enemy_prefab.instantiate()
	enemy_instance.position = Vector2(
		randf() * Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y + 50
	)
	add_child(enemy_instance)
