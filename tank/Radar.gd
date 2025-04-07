extends Node2D

const max_radar_time : float = 3.0
const max_cooldown : float = 1.0
const rays = 50;

@onready var visionCone : VisionCone2D = $VisionCone2D

var cooldown : float = 0.0
var radar_held : bool = false
var radar_held_time : float = 0.0

var gauge = null


var collisions = []

func _ready() -> void:
	gauge = Utils.getLevel().get_node("%RadarGauge")
	self.visible = false

func check_inputs() -> void:
	if cooldown > 0 and (Input.is_action_just_pressed("radar") or Input.is_action_just_released("radar")):
		print("Radar on cooldown")
		Sfx.play(Sfx.Track.Misfire)
		return
	if Input.is_action_just_pressed("radar"):
		radar_held = true
		radar_held_time = 0.0
		visionCone.max_distance = 100
		visionCone.angle_deg = 160
		visionCone.recalc_angle()
		collisions.clear()
		print("Radar pressed")
	if Input.is_action_just_released("radar") and radar_held:
		release_radar()

func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
		if cooldown < 0:
			cooldown = 0
	if gauge != null:
		gauge.set_value(cooldown / max_cooldown * 100.0)
	check_inputs()
	if radar_held:
		radar_held_time += delta
		var power = lerpf(2.5, 1, radar_held_time /5)

		#print("Radar held time: ", radar_held_time, "power: ", power)
		var lerped_angle = lerp_angle(PI/2, 0, radar_held_time / (max_radar_time  + 0.5))
		visionCone.max_distance = lerpf(10.0, 450, radar_held_time / max_radar_time)

		#print("Radar lerp angle: ", lerped_angle, "radar lerp angle in deg: ", rad_to_deg(lerped_angle))
		visionCone.angle_deg = rad_to_deg(lerped_angle ** power)
		#print("Radar max distance: ", visionCone.max_distance, " radar held time: ", radar_held_time, "final angle: ", visionCone.angle_deg)
		#print("Radar angle: ", visionCone.angle_deg)
		visionCone.recalc_angle()
		
		if radar_held_time > max_radar_time: 
			print("Radar held too long")
			release_radar()
	self.visible = radar_held

func release_radar() -> void:
	Sfx.play(Sfx.Track.Radar)
	radar_held = false
	radar_held_time = 0.0
	print("Collisions: ", collisions)
	for collision in collisions:
		print("Enemy detected: ", collision)
		collision.glow()
	self.cooldown = max_cooldown

func _on_vision_cone_area_area_entered(area: Area2D) -> void:
	print("Area entered: ", area)
	if area.is_in_group("enemies"):
		print("Enemy detected: ", area)
		collisions.append(area)	

func _on_vision_cone_area_area_exited(area: Area2D) -> void:
	print("Area exited: ", area)
	if area.is_in_group("enemies"):
		print("Enemy lost: ", area)
		collisions.erase(area)
