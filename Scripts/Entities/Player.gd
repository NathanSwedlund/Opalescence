extends KinematicBody2D

export var speed = 4.0
export var starting_health = 3
export var shrink_scalar = 0.99

onready var default_light_size = $OuterLight.scale
export var min_scale = 0.5

# Gravity Variables
export var gravity_radius = 100
export var gravity_pull_scale = 1
var default_gravity_radius = gravity_radius
var default_gravity_pull_scale = gravity_pull_scale
var default_bullets_burst_wait_time = 0.1

export var respawn_position = Vector2.ZERO
export var is_active = true

var play_time = 0
var points = 0
var point_get_label_scene = load("res://Scenes/HelperScenes/UI/PointGetLabel.tscn")

var mouse_direction_from_player = Vector2.ZERO

# bomb variables
export var can_bomb = true
const MAX_BOMBS = 3
var current_health
var current_bombs
var bomb_scene = load("res://Scenes/HelperScenes/Powerups/Bomb.tscn")
export var default_bullets_per_burst = 3
var bullets_to_shoot
var bullets_per_burst
var gravity_well_pull_scale = 6.0
var gravity_well_radius = 100000
var barrage_burst_time = 0.04
var unmaker_scale = 2.3
var shield:Node2D

# locomotion variables
var velocity = Vector2.ZERO
var point_explosion = load("res://Scenes/HelperScenes/Explosions/GetPointExplosion.tscn")
var heads_up_display

# Primary fire variables
var directions = {"LEFT":Vector2(-1,0), "RIGHT":Vector2(1,0), "UP":Vector2(0,-1), "DOWN":Vector2(0,1)}
var bullet_scene = load("res://Scenes/HelperScenes/Bullet.tscn")
var small_bullet_explosion_scene = load("res://Scenes/HelperScenes/Explosions/SmallBulletExplosion.tscn")
var can_shoot = true
export var starting_bombs = 3
var inf_bombs = false

var bullet_audio_default_pitch = 1.0
var incendiary_audio_pitch = 0.7

# Powerup variables
export var powerup_times = {
	"Barrage":5.0,
	"Bombastic":3.0,
	"BulletTime":1.0,
	"GravityWell":10.0,
	"Incendiary":5.0,
	"Opalescence":10.0,
	"OpalescenceColorShift":0.05,
	"Unmaker":3.0,
	"Vision":15.0
	}

var transformative_powerups = ["Barrage", "Bombastic", "BulletTime", "GravityWell", "Incendiary", "Opalescence", "OverShield", "Unmaker", "Vision"]
var has_powerup = {}
var powerup_point_value = 1000
var bullet_time_time_scale = 0.2
var bullet_time_player_speed_mult = 2.0
var vision_light_scale = 3.0

# Secondary fire variables
var is_charging_laser = false
var laser_scene = load("res://Scenes/HelperScenes/Laser.tscn")
var can_shoot_laser = true
var is_shooting_indendiary = false

export var use_global_settings = true
export var can_collect_points = true
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/EnemyDeathExplosion.tscn")
var opalescence_shift_speed = 0.5
export var default_bullets_cooldown_wait_time = 0.3

func _ready():
	speed *= global_scale.x
	for c in $SoundFX.get_children():
		c.add_to_group("FX")

	Settings.apply_sound_settings()

	if(use_global_settings):
		speed = Settings.get_setting_if_exists(Settings.player, "speed", speed) * Settings.get_setting_if_exists(Settings.player, "player_speed_scale", 1.0)
		starting_health = Settings.get_setting_if_exists(Settings.player, "starting_health", starting_health)
		shrink_scalar = Settings.get_setting_if_exists(Settings.player, "shrink_scalar", shrink_scalar)
		shrink_scalar = 1 + (shrink_scalar - 1) *  Settings.get_setting_if_exists(Settings.player, "light_fade_scale", 1.0)
		min_scale = Settings.get_setting_if_exists(Settings.player, "min_scale", min_scale)
		gravity_radius = Settings.get_setting_if_exists(Settings.player, "gravity_radius", gravity_radius)
		gravity_pull_scale = Settings.get_setting_if_exists(Settings.player, "gravity_pull_scale", gravity_pull_scale)
		default_gravity_radius = Settings.get_setting_if_exists(Settings.player, "default_gravity_radius", default_gravity_radius)
		default_gravity_pull_scale = Settings.get_setting_if_exists(Settings.player, "default_gravity_pull_scale", default_gravity_pull_scale)
		default_bullets_burst_wait_time = Settings.get_setting_if_exists(Settings.player, "default_bullets_burst_wait_time", default_bullets_burst_wait_time)
		is_active = Settings.get_setting_if_exists(Settings.player, "is_active", is_active)
		can_bomb = Settings.get_setting_if_exists(Settings.player, "can_bomb", can_bomb)
		starting_bombs = Settings.get_setting_if_exists(Settings.player, "starting_bombs", starting_bombs)
		powerup_point_value = Settings.get_setting_if_exists(Settings.player, "powerup_point_value", powerup_point_value)
		bullet_time_time_scale = Settings.get_setting_if_exists(Settings.player, "bullet_time_time_scale", bullet_time_time_scale)
		vision_light_scale = Settings.get_setting_if_exists(Settings.player, "vision_light_scale", vision_light_scale)
		gravity_well_pull_scale = Settings.get_setting_if_exists(Settings.player, "gravity_well_pull_scale", gravity_well_pull_scale)
		gravity_well_radius = Settings.get_setting_if_exists(Settings.player, "gravity_well_radius", gravity_well_radius)
		barrage_burst_time = Settings.get_setting_if_exists(Settings.player, "barrage_burst_time", barrage_burst_time)
		unmaker_scale = Settings.get_setting_if_exists(Settings.player, "unmaker_scale", unmaker_scale)
		can_shoot = Settings.get_setting_if_exists(Settings.player, "can_shoot", can_shoot)
		default_bullets_per_burst = Settings.get_setting_if_exists(Settings.player, "default_bullets_per_burst", default_bullets_per_burst)
		can_shoot_laser = Settings.get_setting_if_exists(Settings.player, "can_shoot_laser", can_shoot_laser)
		default_bullets_cooldown_wait_time = Settings.get_setting_if_exists(Settings.player, "default_bullets_cooldown_wait_time", default_bullets_cooldown_wait_time)
		scale *= Settings.get_setting_if_exists(Settings.player, "player_scale", 1.0)
		default_light_size *= Settings.get_setting_if_exists(Settings.player, "light_scale", 1.0)
		$OuterLight.scale = default_light_size
		
	Global.player = self
	for tp in transformative_powerups:
		has_powerup[tp] = false

	for pt in powerup_times:
		$PowerupTimers.find_node(pt).wait_time = powerup_times[pt]

	$BulletCooldownTimer.wait_time = default_bullets_cooldown_wait_time
	bullets_per_burst = default_bullets_per_burst
	bullets_to_shoot = default_bullets_per_burst
	reset()

var shift_speed = 1
var colors = Settings.get_setting_if_exists(Settings.saved_settings, "colors", [Color.white])
var target_color = colors[randi()%len(colors)]
func _process(delta):
	if("Opalescence" in has_powerup.keys() and has_powerup["Opalescence"]):
		modulate.r = move_toward(modulate.r, target_color.r, shift_speed * delta)
		modulate.g = move_toward(modulate.g, target_color.g, shift_speed * delta)
		modulate.b = move_toward(modulate.b, target_color.b, shift_speed * delta)
		change_color(modulate)
		if(modulate == target_color):
			target_color = colors[randi()%len(colors)]

func reset():
	$Cursor.player = self
	points = 0
	play_time = 0
	current_health = starting_health
	current_bombs = starting_bombs
	heads_up_display = get_parent().find_node("HeadsUpDisplay")
	if(heads_up_display != null):
		heads_up_display.update_bombs(current_bombs)
		heads_up_display.update_health(current_health, 	has_powerup["OverShield"])
		heads_up_display.update_points(points)
	respawn()

func add_points(points_num):
	if(can_collect_points):
		points += points_num * Settings.world["points_scale"]
		if(heads_up_display != null):
			heads_up_display.update_points(points)

		if(Settings.world["has_point_goal"] and points >= Settings.world["point_goal"]):
			game_over()

func spawn_get_point_label(points_num):
	var gpl = point_get_label_scene.instance()
	gpl.points_num = points_num
	gpl.color = modulate
	gpl.position = position
	get_parent().add_child(gpl)

func gain_point(_color):
	if(powerup_count() == 0 or (has_powerup["OverShield"] and powerup_count() == 1)):
		change_color(_color)

	if(has_powerup["Vision"]):
		$OuterLight.scale = default_light_size * vision_light_scale
	else:
		$OuterLight.scale = default_light_size

	add_points(200)
	spawn_get_point_label(200)

	var explosion = point_explosion.instance()
	explosion.modulate = modulate
	explosion.position = position
	explosion.scale = scale
	explosion.emitting = true
	get_parent().add_child(explosion)

export var can_change_color = true
func change_color(new_color):
	if(!can_change_color):
		return
		
	modulate = new_color
	$OuterLight.color = new_color
	$InnerLight.color = new_color
	$CanvasLayer/PowerupLabel.modulate = Color(new_color.r, new_color.g, new_color.b, $CanvasLayer/PowerupLabel.modulate.a)
	if(heads_up_display != null):
		heads_up_display.change_color(new_color)

func get_input():
	velocity = Vector2.ZERO

	if(Input.is_action_pressed("ui_left")):
		velocity += directions["LEFT"]*speed*Input.get_action_strength("ui_left")
	if(Input.is_action_pressed("ui_right")):
		velocity += directions["RIGHT"]*speed*Input.get_action_strength("ui_right")
	if(Input.is_action_pressed("ui_up")):
		velocity += directions["UP"]*speed*Input.get_action_strength("ui_up")
	if(Input.is_action_pressed("ui_down")):
		velocity += directions["DOWN"]*speed*Input.get_action_strength("ui_down")

	if(has_powerup["BulletTime"]):
		velocity *= bullet_time_player_speed_mult

	if(Input.is_action_just_pressed("ui_e") and can_bomb ):
		if(current_bombs >= 1):
			if(inf_bombs == false):
				current_bombs -= 1
			if(heads_up_display != null):
				heads_up_display.update_bombs(current_bombs)
			drop_bomb()
	if(Input.is_action_just_pressed("mouse_left") and can_shoot):
		shoot()
	if(can_shoot_laser and Input.is_action_just_pressed("mouse_right")):
		is_charging_laser = true
		$LaserChargeTimer.start()
		$SoundFX/LaserChargeAudio.play()
		$LaserChargeEffect.emitting = is_charging_laser
	if(can_shoot_laser and is_charging_laser and Input.is_action_pressed("mouse_right") == false):
		is_charging_laser = false
		$LaserChargeTimer.stop()
		$SoundFX/LaserChargeAudio.stop()
		$LaserChargeEffect.emitting = is_charging_laser

func shoot():
	if(can_shoot == false):
		return

	if(has_powerup["Barrage"] == false):
		bullets_to_shoot = bullets_per_burst

	if(bullets_to_shoot > 1):
		can_shoot = false
		$BulletBurstTimer.start()
		spawn_bullet()
	elif(bullets_to_shoot == 1):
		can_shoot = false
		spawn_bullet()
		$BulletCooldownTimer.start()

func get_direction_to_shoot():
	return ($Cursor.position).normalized() if ($Cursor.position).normalized() != Vector2(0,0) else Vector2(0,-1)

func spawn_bullet():
	var bullet = bullet_scene.instance()
	$SoundFX/BulletFireAudio.play()
	if(has_powerup["Incendiary"]):
		$SoundFX/IncendiaryBulletFire.play()

	bullet.direction = get_direction_to_shoot()
	bullet.position = position
	bullet.add_to_group("Bullets")
	bullet.modulate = modulate
	bullet.incendiary = is_shooting_indendiary
	bullet.small_bullet_explosion_scene = small_bullet_explosion_scene
	get_parent().add_child(bullet)

func drop_bomb():
	var bomb = bomb_scene.instance()
	bomb.find_node("PowerupPill").change_color(modulate)
	bomb.position = position
	$SoundFX/DropBombAudio.play()
	get_parent().add_child(bomb)

func damage():
	if(has_powerup["Opalescence"]):
		get_parent().find_node("EnemyFactory").kill_all()
	elif(has_powerup["OverShield"]):
		has_powerup["OverShield"] = false
		heads_up_display.update_health(current_health, has_powerup["OverShield"])
		get_parent().find_node("EnemyFactory").kill_all()
		get_parent().find_node("PointFactory").kill_all()
		get_parent().find_node("PowerupFactory").kill_all()
		$ShieldSprite.visible = false
	else:
		die()

func die():
	$SoundFX/PlayerExplosionSound.play()
	for laser in get_tree().get_nodes_in_group("Lasers"):
		laser.queue_free()

	bullets_to_shoot = default_bullets_per_burst

	# summon explosion
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.modulate = modulate
	explosion.find_node("Light2D").color = modulate
	explosion.find_node("Light2D").energy = 4.0
	explosion.scale *= 2.6
	get_parent().add_child(explosion)

	$BulletBurstTimer.stop()

	visible = false
	get_parent().find_node("EnemyFactory").kill_all()
	get_parent().find_node("PointFactory").kill_all()
	get_parent().find_node("PowerupFactory").kill_all()

	get_parent().find_node("EnemyFactory").is_active = false

	get_parent().find_node("PointFactory").is_active = false
	get_parent().find_node("PowerupFactory").is_active = false

	current_health -= 1
	if(current_health <= 0):
		game_over()
	else:
		$RespawnTimer.start()

	for timer in get_tree().get_nodes_in_group("PowerupTimerUIs"):
		if(timer.is_timing == true):
			timer.stop_timer()

	heads_up_display.update_health(current_health, 	has_powerup["OverShield"])

	is_charging_laser = false
	can_shoot = false
	can_shoot_laser = false
	$LaserChargeTimer.stop()
	$SoundFX/LaserChargeAudio.stop()
	$LaserChargeEffect.emitting = false

func respawn():
	_on_Bombastic_timeout()
	_on_Barrage_timeout()
	_on_BulletTime_timeout()
	_on_GravityWell_timeout()
	_on_Incendiary_timeout()
	_on_Opalescence_timeout()
	_on_Unmaker_timeout()
	_on_Vision_timeout()

	if(get_parent().has_method("start_factories")):
		get_parent().start_factories()

	change_color(Color.white)
	position = respawn_position
	visible = true

	can_shoot = Settings.player["can_shoot"]
	can_shoot_laser = Settings.player["can_shoot_laser"]

func game_over():
	if(Settings.world["mission_title"] == "challenge"):
		Settings.shop["points"] += int(points/Settings.world["points_scale"])
	else:
		Settings.shop["points"] += points
	Settings.save()

	
	if(get_parent().game_is_over):
		return

	get_parent().game_over()

	get_parent().find_node("EnemyFactory").is_active = false
	get_parent().find_node("EnemyFactory").kill_all()
	get_parent().find_node("PointFactory").is_active = false
	get_parent().find_node("PowerupFactory").is_active = false

	$BulletBurstTimer.stop() 
	
	var is_mission = Settings.world["is_mission"]
	var mission_complete = false
	var score_title = Settings.world["mission_title"]

	if(!is_mission):
		HighScore.record_score(points, score_title)
	else:
		if(Settings.world["has_point_goal"] and Settings.world["point_goal"] <= points):
			HighScore.record_score(Global.round_float(play_time, 3), score_title, false)
			mission_complete = true
		if(Settings.world["has_time_goal"] and Settings.world["time_goal"] <= play_time):
			HighScore.record_score(points, score_title, true)
			mission_complete = true

	points = 0
	play_time = 0
	heads_up_display.game_over(is_mission, mission_complete)
#	HighScore.set_high_score(Settings.settings["current_game_mode"], points)

func _physics_process(delta):
	$Sprite.look_at(global_position + get_direction_to_shoot() )
	play_time += delta
	if(heads_up_display != null and !get_parent().game_is_over):
		heads_up_display.find_node("TimeLabel").text = "Time: "+str(int(play_time* 1000.0)/1000.0 )+"s"
	if(Settings.world["has_time_goal"] and play_time >= Settings.world["time_goal"]):
		play_time = Settings.world["time_goal"]
		game_over()
	if(!is_charging_laser and $SoundFX/LaserChargeAudio.playing):
		$SoundFX/LaserChargeAudio.stop()
	$OuterLight.scale.x = move_toward($OuterLight.scale.x, min_scale, delta* (1-shrink_scalar))
	$OuterLight.scale.y = move_toward($OuterLight.scale.y, min_scale, delta* (1-shrink_scalar))

	if(!is_active):
		return

	get_input()
	var _collision = move_and_collide(velocity*delta)
	if(_collision != null):
		if(_collision.collider.is_in_group("Enemies")):
			damage()

func _input(event):
	# Mouse in viewport coordinates.
	if (event is InputEventMouseMotion):
		mouse_direction_from_player = (event.position - position).normalized()

func _on_BulletCooldownTimer_timeout():
	can_shoot = Settings.player["can_shoot"]
	bullets_to_shoot = default_bullets_per_burst

func _on_BulletBurstTimer_timeout():
	bullets_to_shoot -= 1
	if(bullets_to_shoot > 0):
		spawn_bullet()
		$BulletBurstTimer.start()
	else:
		$BulletCooldownTimer.start()

func spawn_laser(_scale=1.0, _laser_time=-1.0, _particle_intensity_scale=1.0, _pitch_scale=1.0):
	var laser = laser_scene.instance()
	laser.scale *= _scale
	if(_laser_time != -1.0):
		laser.total_time = _laser_time
		laser.particle_intensity_scale = _particle_intensity_scale
	laser.find_node("LaserSound").pitch_scale *= _pitch_scale
	add_child(laser)

func _on_LaserChargeTimer_timeout():
	can_shoot_laser = false
	$LaserCooldownTimer.start()
	$SoundFX/LaserChargeAudio.stop()
	is_charging_laser = false
	$LaserChargeEffect.emitting = is_charging_laser
	spawn_laser()

func _on_LaserCooldownTimer_timeout():
	can_shoot_laser = Settings.player["can_shoot_laser"]

func _on_RespawnTimer_timeout():
	respawn()

func start_powerup_timer(time, color, _powerup):
	for timer in get_tree().get_nodes_in_group("PowerupTimerUIs"):
		if(timer.is_timing == false or timer.powerup_name == _powerup):
			timer.powerup_name = _powerup
			timer.start_timer(time)
			timer.modulate = color
			break

func powerup_count():
	var pc = 0
	for i in has_powerup.keys():
		pc += 1 if has_powerup[i] else 0

	return pc

func get_powerup(_powerup, _color):
	var a = $SoundFX.find_node(_powerup+"Audio")
	if(a != null):
		a.play()

	change_color(_color)
	$CanvasLayer/PowerupLabel.show_powerup(_powerup)
	add_points(powerup_point_value)
	spawn_get_point_label(powerup_point_value)
	heads_up_display.update_points(points)

	if(_powerup == "Barrage"):
		$BulletBurstTimer.wait_time = barrage_burst_time
		$PowerupTimers/Barrage.start()
		start_powerup_timer($PowerupTimers/Barrage.wait_time, _color, _powerup)
		bullets_per_burst = 10000 # very big number will be cut off by _on_Barrage_timeout()
		bullets_to_shoot = 10000
		shoot()
	if(_powerup == "Bombastic"):
		$PowerupTimers/Bombastic.start()
		start_powerup_timer($PowerupTimers/Bombastic.wait_time, _color, _powerup)
		current_bombs = MAX_BOMBS
		heads_up_display.update_bombs(current_bombs)
		inf_bombs = true

	# Not currently a valid powerup
#	if(_powerup == "BombUp" and current_bombs < MAX_BOMBS):
#		current_bombs += 1
#		heads_up_display.update_bombs(current_bombs)

	if(_powerup == "BulletTime"):
		$PowerupTimers/BulletTime.start()
		start_powerup_timer($PowerupTimers/BulletTime.wait_time, _color, _powerup)
		Engine.time_scale = bullet_time_time_scale
	if(_powerup == "GravityWell"):
		$PowerupTimers/GravityWell.start()
		gravity_pull_scale = gravity_well_pull_scale
		gravity_radius = gravity_well_radius
		start_powerup_timer($PowerupTimers/GravityWell.wait_time, _color, _powerup)
	if(_powerup == "Incendiary"):
		$PowerupTimers/Incendiary.start()
		$SoundFX/BulletFireAudio.pitch_scale = incendiary_audio_pitch
		$SoundFX/BulletHitFail.pitch_scale = incendiary_audio_pitch
		start_powerup_timer($PowerupTimers/Incendiary.wait_time, _color, _powerup)
		is_shooting_indendiary = true
	if(_powerup == "MaxBomb"):
		current_bombs = MAX_BOMBS
		$SoundFX/MaxBombAudio.play()
		heads_up_display.update_bombs(current_bombs)

	# Not currently a valid powerup
#	if(_powerup == "MaxUp"):
#		current_health = MAX_HEALTH
#		heads_up_display.update_health(current_health, 	has_powerup["OverShield"])

	if(_powerup == "OneUp"):
		current_health += 1
		heads_up_display.update_health(current_health, has_powerup["OverShield"])
	if(_powerup == "Opalescence"):
		$PowerupTimers/Opalescence.start()
		$PowerupTimers/OpalescenceColorShift.start()
		start_powerup_timer($PowerupTimers/Opalescence.wait_time, _color, _powerup)
	if(_powerup == "OverShield"):
		$ShieldSprite.visible = true
		heads_up_display.update_health(current_health, 	true)
	if(_powerup == "Unmaker"):
		var unmaker_particle_intensity = 2.0
		var unmaker_pitch_scale = 0.5
		spawn_laser(unmaker_scale, $PowerupTimers/Unmaker.wait_time, unmaker_particle_intensity, unmaker_pitch_scale)
		$PowerupTimers/Unmaker.start()
		start_powerup_timer($PowerupTimers/Unmaker.wait_time, _color, _powerup)
	if(_powerup == "Vision"):
		$PowerupTimers/Vision.start()
		start_powerup_timer($PowerupTimers/Vision.wait_time, _color, _powerup)
		if(has_powerup["Vision"] == false):
			$OuterLight.scale *= vision_light_scale

	if(_powerup in transformative_powerups):
		has_powerup[_powerup] = true

func _on_Bombastic_timeout():
	has_powerup["Bombastic"] = false
	inf_bombs = false

func _on_Barrage_timeout():
	has_powerup["Barrage"] = false
	bullets_per_burst = default_bullets_per_burst
	$BulletBurstTimer.wait_time = default_bullets_burst_wait_time
	$BulletBurstTimer.stop()
	can_shoot = Settings.player["can_shoot"]

func _on_BulletTime_timeout():
	has_powerup["BulletTime"] = false
	Engine.time_scale = 1

func _on_GravityWell_timeout():
	has_powerup["GravityWell"] = false
	gravity_radius = default_gravity_radius
	gravity_pull_scale = default_gravity_pull_scale

func _on_Incendiary_timeout():
	has_powerup["Incendiary"] = false
	$SoundFX/BulletFireAudio.pitch_scale = bullet_audio_default_pitch
	$SoundFX/BulletHitFail.pitch_scale = bullet_audio_default_pitch
	is_shooting_indendiary = false

func _on_Opalescence_timeout():
	target_color = colors[randi()%len(colors)]
	has_powerup["Opalescence"] = false
	$PowerupTimers/OpalescenceColorShift.stop()

func _on_Unmaker_timeout():
	has_powerup["Unmaker"] = false

func _on_Vision_timeout():
	has_powerup["Vision"] = false
	$OuterLight.scale = default_light_size

func play_enemey_explosion_sound():
	$SoundFX/EnemyExplosionSound.play()
