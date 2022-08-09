extends KinematicBody2D

export var default_speed = 400.0
var speed
export var starting_health = 3
export var default_shrink_scalar = 0.99
var shrink_scalar

onready var default_light_size = $OuterLight.scale
var light_size = Vector2.ZERO
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
var default_max_bombs = 3
var max_bombs
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
export var default_bomb_scale = 1.0
var bullet_scale
export var default_bullet_scale = 1.0
var small_bullet_explosion_scene = load("res://Scenes/HelperScenes/Explosions/SmallBulletExplosion.tscn")
var can_shoot = true
export var starting_bombs = 3
var inf_bombs = false

var default_laser_charge_time
var opalescence_projectile_scene = load("res://Scenes/HelperScenes/Powerups/OpalescenceProjectile.tscn")
var unmaker_strike_beam_time = 1.2
var bullet_audio_default_pitch = 1.0
var incendiary_audio_pitch = 0.7
var default_unmaker_vol
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
var bullet_time_player_speed_mult = 4.0
var vision_light_scale = 3.0

# Secondary fire variables
var is_charging_laser = false
var laser_scene
export var default_laser_scale = 1.0
var laser_scale
var can_shoot_laser = true
var is_shooting_indendiary = false

export var use_global_settings = true
export var can_collect_points = true
var death_explosion_scene = load("res://Scenes/HelperScenes/Explosions/PlayerDeathExplosion.tscn")
var opalescence_shift_speed = 0.5
var opalescense_player_speed_scale = 3
var default_player_speed
var bomb_scale = 1.0
export var default_bullets_cooldown_wait_time = 0.3
var max_bomb_bomb_scale = 3.0
var default_enemy_explosion_vol
var default_laser_cooldown_time = 5.0
var laser_cooldown_time
func _ready():
	default_unmaker_vol = $SoundFX/UnmakerAudio.volume_db
	Global.points_this_round = 0

	default_speed *= global_scale.x
	for c in $SoundFX.get_children():
		c.add_to_group("FX")

	reset_settings()
	Settings.apply_sound_settings()
	Global.player = self
	for tp in transformative_powerups:
		has_powerup[tp] = false

	Settings.world["default_points_scale"] = Settings.world["points_scale"]
	$BulletCooldownTimer.wait_time = default_bullets_cooldown_wait_time
	default_laser_charge_time = Global.laser_type_charge_times[Settings.shop["laser_type"]]
	reset()
	$LaserChargeTimer.wait_time *= max(laser_cooldown_time /2, 1.0)
	print("$LaserChargeTimer.wait_time, ", $LaserChargeTimer.wait_time)
	print("$laser_cooldown_timet_time, ", laser_cooldown_time)

var first_load = true
func reset_settings():
	load_player_type()
	can_shoot = can_shoot and player_type.can_shoot
	laser_cooldown_time = default_laser_cooldown_time
	max_bombs = default_max_bombs
	if(use_global_settings):
		default_speed = Settings.get_setting_if_exists(Settings.player, "speed", speed) * Settings.get_setting_if_exists(Settings.player, "player_speed_scale", 1.0)
		starting_health = Settings.get_setting_if_exists(Settings.player, "starting_health", starting_health)
		default_shrink_scalar = Settings.get_setting_if_exists(Settings.player, "shrink_scalar", default_shrink_scalar)
		default_shrink_scalar = 1 + (default_shrink_scalar - 1) *  Settings.get_setting_if_exists(Settings.player, "light_fade_scale", 1.0)
		min_scale = Settings.get_setting_if_exists(Settings.player, "min_scale", min_scale)
		gravity_radius = Settings.get_setting_if_exists(Settings.player, "gravity_radius", gravity_radius)
		gravity_pull_scale = Settings.get_setting_if_exists(Settings.player, "gravity_pull_scale", gravity_pull_scale)
		default_gravity_radius = Settings.get_setting_if_exists(Settings.player, "default_gravity_radius", default_gravity_radius)
		default_gravity_pull_scale = Settings.get_setting_if_exists(Settings.player, "default_gravity_pull_scale", default_gravity_pull_scale)
		default_bullets_burst_wait_time = Settings.get_setting_if_exists(Settings.player, "default_bullets_burst_wait_time", default_bullets_burst_wait_time)
		is_active = Settings.get_setting_if_exists(Settings.player, "is_active", is_active)
		can_bomb = can_bomb and Settings.get_setting_if_exists(Settings.player, "can_bomb", can_bomb)
		starting_bombs = Settings.get_setting_if_exists(Settings.player, "starting_bombs", starting_bombs)
		powerup_point_value = Settings.get_setting_if_exists(Settings.player, "powerup_point_value", powerup_point_value)
		bullet_time_time_scale = Settings.get_setting_if_exists(Settings.player, "bullet_time_time_scale", bullet_time_time_scale)
		vision_light_scale = Settings.get_setting_if_exists(Settings.player, "vision_light_scale", vision_light_scale)
		gravity_well_pull_scale = Settings.get_setting_if_exists(Settings.player, "gravity_well_pull_scale", gravity_well_pull_scale)
		gravity_well_radius = Settings.get_setting_if_exists(Settings.player, "gravity_well_radius", gravity_well_radius)
		barrage_burst_time = Settings.get_setting_if_exists(Settings.player, "barrage_burst_time", barrage_burst_time)
		unmaker_scale = Settings.get_setting_if_exists(Settings.player, "unmaker_scale", unmaker_scale)
		can_shoot = can_shoot and Settings.get_setting_if_exists(Settings.player, "can_shoot", can_shoot)
		default_bullets_per_burst = Settings.get_setting_if_exists(Settings.player, "default_bullets_per_burst", default_bullets_per_burst)
		can_shoot_laser = can_shoot_laser and Settings.get_setting_if_exists(Settings.player, "can_shoot_laser", can_shoot_laser)
		default_bullets_cooldown_wait_time = Settings.get_setting_if_exists(Settings.player, "default_bullets_cooldown_wait_time", default_bullets_cooldown_wait_time)
		scale *= Settings.get_setting_if_exists(Settings.player, "player_scale", 1.0)
		default_light_size = Vector2.ONE * Settings.get_setting_if_exists(Settings.player, "light_scale", 1.0)
		max_bombs += Settings.get_setting_if_exists(Settings.shop, "additional_max_bombs", 0)
		#print(Settings.shop)
		laser_cooldown_time /= Settings.get_setting_if_exists(Settings.shop, "laser_recharge_scale", 1.0)

	laser_cooldown_time /= player_type.laser_recharge_scale
	
	light_size = default_light_size
	speed = default_speed
	speed *= player_type.speed_scale
	default_bullets_per_burst += player_type.bullets_per_burst_mod
	bullets_per_burst = default_bullets_per_burst
	bullets_to_shoot = default_bullets_per_burst

	light_size *= player_type.light_scale
	shrink_scalar = default_shrink_scalar * player_type.light_fade_scale
	laser_scale = default_laser_scale *  player_type.laser_scale
	bullet_scale = default_bullet_scale *  player_type.bullet_scale
	bomb_scale = default_bomb_scale * player_type.bomb_scale
	max_bombs += player_type.max_bomb_mod
	Settings.world["points_scale"] *= player_type.points_scale
	bomb_scene = load(player_type.bomb_scene_path)
	
	starting_bombs = max_bombs
	if(first_load):
		current_bombs = max_bombs
		
	can_bomb = can_bomb and player_type.can_bomb
	can_shoot_laser = can_shoot_laser and player_type.can_shoot_laser
	$OuterLight.scale = light_size
	
	if(Settings.world["is_mission"] == false):
		for pt in powerup_times:
			$PowerupTimers.find_node(pt).wait_time = powerup_times[pt]

	if(use_global_settings and Settings.world["is_mission"] == false):
		if(Settings.shop["default_bullets_per_burst_mod"]):
			default_bullets_per_burst += Settings.shop["default_bullets_per_burst_mod"]
		if(Settings.shop["starting_health_mod"]):
			starting_health += Settings.shop["starting_health_mod"]
		if(Settings.shop["light_scale"]):
			light_size *= Settings.shop["light_scale"]
		if(Settings.shop["bullet_burst_speed_scale"]):
			default_bullets_burst_wait_time /= Settings.shop["bullet_burst_speed_scale"]
		if(Settings.shop["powerup_time_scale"]):
			for t in $PowerupTimers.get_children():
				t.wait_time *= Settings.shop["powerup_time_scale"]
			
	default_player_speed = speed
	first_load = false
	
	$LaserCooldownTimer.wait_time = laser_cooldown_time

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

	bullet_scene = Global.bullet_type_scenes[Settings.shop["bullet_type"]]
	if(Settings.player["bullet_type_override"] != null):
		bullet_scene = Global.bullet_type_scenes[Settings.player["bullet_type_override"]]


	laser_scene = Global.laser_type_scenes[Settings.shop["laser_type"]]
	if(Settings.player["laser_type_override"] != null):
		laser_scene = Global.laser_type_scenes[Settings.player["laser_type_override"]]

	respawn()

var has_loaded_type = false
var player_type
func load_player_type():
	if(has_loaded_type == false):
		has_loaded_type = true
		var index = Settings.shop["player_type"]
		if(Settings.player["player_type_override"] != null):
			index = Settings.player["player_type_override"]

		player_type = Global.player_type_scenes[index].instance()
		player_type.name = "PlayerType"
		player_type.player = self
		add_child(player_type)

func add_points(points_num):
	if(can_collect_points):
		points += points_num * Settings.world["points_scale"]
		if(heads_up_display != null):
			heads_up_display.update_points(points)

		Global.points_this_round = int(points)
		if(Settings.world["mission_title"] == "challenge"):
			Global.points_this_round = int(points/Settings.world["points_scale"])

		if(Settings.world["has_point_goal"] and points >= Settings.world["point_goal"]):
			game_over()

func spawn_get_point_label(points_num):
	var gpl = point_get_label_scene.instance()
	gpl.points_num = points_num
	gpl.color = modulate
	gpl.position = position
	get_parent().add_child(gpl)

var points_per_points_collected = 1000
func gain_point(_color):
	if(powerup_count() == 0 or (has_powerup["OverShield"] and powerup_count() == 1)):
		change_color(_color)

	if(has_powerup["Vision"]):
		$OuterLight.scale = light_size * vision_light_scale
	else:
		$OuterLight.scale = light_size

	add_points(points_per_points_collected)
	spawn_get_point_label(points_per_points_collected)

	var explosion = point_explosion.instance()
	explosion.modulate = modulate
	explosion.position = position
	explosion.scale = scale
	explosion.emitting = true
	get_parent().add_child(explosion)

export var can_change_color = true
func change_color(new_color):
	if(Settings.shop["monocolor_color"] != null):
		new_color = Settings.shop["monocolor_color"].linear_interpolate(new_color, 0.5)

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
			drop_bomb(bomb_scale)
	if(Input.is_action_pressed("mouse_left") and can_shoot):
		shoot()
	if(is_charging_laser == false and can_shoot_laser and Input.is_action_pressed("mouse_right")):
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
	if(can_shoot == false and has_powerup["Barrage"] == false):
		return

	if(has_powerup["Barrage"] == false):
		bullets_per_burst = default_bullets_per_burst
		bullets_to_shoot = bullets_per_burst



	if(bullets_to_shoot > 1):
		can_shoot = false
		$BulletBurstTimer.start()
		spawn_bullet()
	elif(bullets_to_shoot == 1):
		can_shoot = false
		spawn_bullet()
		$BulletCooldownTimer.start()

func get_direction_to_shoot(_name=null):
	return ($Cursor.position).normalized() if ($Cursor.position).normalized() != Vector2(0,0) else Vector2(0,-1)

var BULLET_SPAWN_DIST = 25
func spawn_bullet():
#	Global.vibrate_controller(0.1,0.3)
	var bullet = bullet_scene.instance()
	if(has_powerup["Incendiary"]):
		$SoundFX/IncendiaryBulletFire.play()
		Global.shakes["misc"].start()
		Global.vibrate_controller(0.2,0.9,0.9,0)


	bullet.direction = get_direction_to_shoot()
	bullet.position = position + (bullet.direction * BULLET_SPAWN_DIST)
	bullet.add_to_group("Bullets")
	bullet.modulate = modulate
	bullet.incendiary = is_shooting_indendiary
	bullet.scale *= bullet_scale
	bullet.small_bullet_explosion_scene = small_bullet_explosion_scene
	get_parent().add_child(bullet)

func drop_bomb(_scale=1.0, is_max_bomb=false):
	var bomb = bomb_scene.instance()
	bomb.find_node("PowerupPill").change_color(modulate)
	bomb.position = position
	bomb.find_node("PowerupPill").is_max_bomb = is_max_bomb
	if(Settings.world["is_mission"] == false or _scale == max_bomb_bomb_scale):
		bomb.scale *= Settings.shop["bomb_scale"] * _scale
	$SoundFX/DropBombAudio.play()
	if(Settings.shop["player_type"] == 4):
		bomb.find_node("PowerupPill").find_node("CountdownTimer").wait_time = 0.05
		
	get_parent().add_child(bomb)

var is_invincible = false
func damage(_enemy=null):
	if(_enemy != null):
		_enemy.die()
	if(is_invincible):
		return 
		
	if(has_powerup["Opalescence"]):
		var ens = get_tree().get_nodes_in_group("Enemies")
		for en in ens:
			if(en != _enemy):
				var new_op_pro = opalescence_projectile_scene.instance()
				new_op_pro.position = position
				new_op_pro.find_node("KinematicBody2D").target = en.position-position
				get_parent().add_child(new_op_pro)
	
	elif(has_powerup["OverShield"]):
		is_invincible = true
		$InvincibilityTimer.start()
		Global.vibrate_controller(0.3,0.7,0.7,0)
		$ShieldDestroyedParticles.emitting = true
		$ShieldDestroyedParticles2.emitting = true
		$SoundFX/OverSheildLostAudio.play()
		has_powerup["OverShield"] = false
		heads_up_display.update_health(current_health, has_powerup["OverShield"])
		get_parent().find_node("EnemyFactory").kill_all()
		$ShieldSprite.visible = false
	else:
		die()

func die():
	if(get_parent().game_is_over):
		return
		
	if(is_invincible):
		return
		 
	Global.shakes["explosion"].start(10, 0.95, 40, 1)
	Global.vibrate_controller(1,1,1,1)
	
	$SoundFX/PlayerExplosionSound.play()
	pause_bosses()
	for laser in get_tree().get_nodes_in_group("Lasers"):
		laser.queue_free()

	bullets_to_shoot = default_bullets_per_burst

	# summon explosion
	var explosion = death_explosion_scene.instance()
	explosion.position = position
	explosion.modulate = modulate
	explosion.find_node("Light2D").color = modulate
	explosion.find_node("Light2D").energy = 4.0
	explosion.point_reward = -1000
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
		$GameOverWaitTimer.start()
	else:
		$RespawnTimer.start()
		heads_up_display.update_health(current_health, 	has_powerup["OverShield"])

	for timer in get_tree().get_nodes_in_group("PowerupTimerUIs"):
		if(timer.is_timing == true):
			timer.stop_timer()

	is_charging_laser = false
	can_shoot = false
	can_shoot_laser = false
	can_bomb = false
	$LaserChargeTimer.stop()
	$SoundFX/LaserChargeAudio.stop()
	$LaserChargeEffect.emitting = false
	$LaserCooldown.emitting = false
	$SoundFX/LaserCooldownAudio.stop()
	$LaserExistsTimer.stop()

func pause_bosses():
	for b in get_tree().get_nodes_in_group("Bosses"):
		b.is_active = false

func resume_bosses():
	for b in get_tree().get_nodes_in_group("Bosses"):
		b.is_active = true

func respawn():
	_on_Bombastic_timeout()
	_on_Barrage_timeout()
	_on_BulletTime_timeout()
	_on_GravityWell_timeout()
	_on_Incendiary_timeout()
	_on_Opalescence_timeout()
	_on_Unmaker_timeout()
	_on_Vision_timeout()
	resume_bosses()

	if(get_parent().has_method("start_factories")):
		get_parent().start_factories()

	if(Settings.shop["monocolor_color"] != null):
		change_color(Settings.shop["monocolor_color"])
	else:
		change_color(Color.white)

	position = respawn_position
	visible = true
	can_shoot = Settings.player["can_shoot"] and player_type.can_shoot
	can_shoot_laser = Settings.player["can_shoot_laser"] and player_type.can_shoot_laser
	can_bomb = Settings.player["can_bomb"] and player_type.can_bomb

func game_over():
	if(get_parent().game_is_over):
		return

	get_parent().game_over()

	get_parent().find_node("EnemyFactory").is_active = false
	get_parent().find_node("EnemyFactory").kill_all()
	get_parent().find_node("PointFactory").is_active = false
	get_parent().find_node("PowerupFactory").is_active = false
	visible = false
	$BulletBurstTimer.stop()

	Global.play_time = Global.round_float(play_time, 3)
	points = 0
	heads_up_display.game_over()
	play_time = 0
	Settings.world["points_scale"] = Settings.world["default_points_scale"]
#	HighScore.set_high_score(Settings.settings["current_game_mode"], points)

func _physics_process(delta):
#	print("can_shoot_laser, ", can_shoot_laser)
#	print("has_powerup[Unmaker], ", has_powerup["Unmaker"])
	$PlayerType.look_at(global_position + get_direction_to_shoot() )
	play_time += delta
	if(heads_up_display != null and !get_parent().game_is_over):
		heads_up_display.find_node("TimeLabel").text = "Time: "+str(Global.round_float(play_time, 3))+"s"
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
			damage(_collision.collider)

func _input(event):
	# Mouse in viewport coordinates.
	if (event is InputEventMouseMotion):
		mouse_direction_from_player = (event.position - position).normalized()

func _on_BulletCooldownTimer_timeout():
	can_shoot = Settings.player["can_shoot"]
	if(has_powerup["Barrage"] == false):
		bullets_to_shoot = default_bullets_per_burst

func _on_BulletBurstTimer_timeout():
	bullets_to_shoot -= 1
	if(bullets_to_shoot > 0):
		spawn_bullet()
		$BulletBurstTimer.start()
	else:
		$BulletCooldownTimer.start()

func spawn_laser(_scale=1.0, _particle_intensity_scale=1.0, _pitch_scale=1.0):
	var laser = laser_scene.instance()
	laser.scale *= _scale
	laser.max_fade_in_width *= _scale
	laser.particle_intensity_scale = _particle_intensity_scale
	
	if(has_powerup["Unmaker"] == false):
		if(Settings.shop["laser_type"] == 3): # Ball lightning
			$LaserExistsTimer.wait_time = laser.lifetime/3
		else:
			$LaserExistsTimer.wait_time = laser.lifetime
		$LaserExistsTimer.start()
	else:
		$SoundFX/UnmakerAudio/VolTween.start()
		var unmaker_laser_time = laser.lifetime * 6
		if(Settings.shop["laser_type"] == 3): # Ball Lightning
			unmaker_laser_time /= 3
			
		$SoundFX/UnmakerAudio/VolTween.interpolate_property($SoundFX/UnmakerAudio, "volume_db", default_unmaker_vol, -20, unmaker_laser_time-0.5)		
		if(use_global_settings):
			unmaker_laser_time *= Settings.shop["powerup_time_scale"]
			
		laser.lifetime = unmaker_laser_time
		start_powerup_timer(unmaker_laser_time, modulate, "Unmaker")
		$PowerupTimers/Unmaker.wait_time = unmaker_laser_time
		$PowerupTimers/Unmaker.start()
		start_powerup_timer(unmaker_laser_time, modulate, "Unmaker")
				
	laser.find_node("LaserSound").pitch_scale *= _pitch_scale
	if(Settings.shop["laser_type"] == 3): # Ball Lightning
		laser.position = position
		get_parent().add_child(laser)
	else:
		add_child(laser)

func _on_LaserChargeTimer_timeout():
	$LaserCooldownTimer.start()
	$SoundFX/LaserChargeAudio.stop()
	is_charging_laser = false
	$LaserChargeEffect.emitting = is_charging_laser
	spawn_laser(laser_scale)
	can_shoot_laser = false

func _on_LaserCooldownTimer_timeout(make_sound=true):
	print("_on_LaserCooldownTimer_timeout DONE")
	$LaserCooldown.emitting = false
	$SoundFX/LaserCooldownAudio.stop()
	if(get_parent() == Global.world):
		if(get_parent().game_is_over == false and can_shoot_laser == false):
			if(make_sound):
				$SoundFX/LaserCooldownCompleteAudio.play()
			$LaserReady.emitting = true
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
	$GetPoweup.restart()
	$GetPoweup.emitting = true
	var a = $SoundFX.find_node(_powerup+"Audio")
	if(a != null):
		a.play()

	change_color(_color)
	$CanvasLayer/PowerupLabel.show_powerup(get_parent().find_node("PowerupFactory").readable_names[_powerup])
	add_points(powerup_point_value)
	spawn_get_point_label(powerup_point_value)
	heads_up_display.update_points(points)

	if(_powerup == "Barrage"):
		$BulletBurstTimer.wait_time = barrage_burst_time
		$PowerupTimers/Barrage.start()
		start_powerup_timer($PowerupTimers/Barrage.wait_time, _color, _powerup)
		bullets_per_burst = 10000 # very big number will be cut off by _on_Barrage_timeout()
		bullets_to_shoot = 10000
	if(_powerup == "Bombastic"):
		$PowerupTimers/Bombastic.start()
		start_powerup_timer($PowerupTimers/Bombastic.wait_time, _color, _powerup)
		current_bombs = max_bombs
		heads_up_display.update_bombs(current_bombs)
		inf_bombs = true

	# Not currently a valid powerup
#	if(_powerup == "BombUp" and current_bombs < max_bombs):
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
		$SoundFX/BulletHitFail.pitch_scale = incendiary_audio_pitch
		start_powerup_timer($PowerupTimers/Incendiary.wait_time, _color, _powerup)
		is_shooting_indendiary = true
	if(_powerup == "MaxBomb"):
		drop_bomb(max_bomb_bomb_scale, true)
		current_bombs = max_bombs
		$SoundFX/MaxBombAudio.play()
		heads_up_display.update_bombs(current_bombs)

	if(_powerup == "OneUp"):
		current_health += 1
		heads_up_display.update_health(current_health, has_powerup["OverShield"])
	if(_powerup == "Opalescence"):
		$PowerupTimers/Opalescence.start()
		$PowerupTimers/OpalescenceColorShift.start()
		$OpalescenceEffect.emitting = true
		speed *= opalescense_player_speed_scale
		start_powerup_timer($PowerupTimers/Opalescence.wait_time, _color, _powerup)
	if(_powerup == "OverShield"):
		$ShieldSprite.visible = true
		heads_up_display.update_health(current_health, 	true)
	if(_powerup == "Unmaker"):
		# stopping existing laser charging/cooldown
		$LaserChargeTimer.stop()
		_on_LaserChargeTimer_timeout()
		$LaserCooldownTimer.stop()
		_on_LaserCooldownTimer_timeout()
		
		# Deleting any existing laser		
		for l in get_tree().get_nodes_in_group("Lasers"):
			l.queue_free()
			
		var unmaker_particle_intensity = 2.0
		var unmaker_pitch_scale = 0.5
		has_powerup["Unmaker"] = true
		$SoundFX/UnmakerAudio.volume_db = default_unmaker_vol
		
		can_shoot_laser = true
		spawn_laser(unmaker_scale, unmaker_particle_intensity, unmaker_pitch_scale)
		can_shoot_laser = false
		
	if(_powerup == "Vision"):
		$PowerupTimers/Vision.start()
		start_powerup_timer($PowerupTimers/Vision.wait_time, _color, _powerup)
		if(has_powerup["Vision"] == false):
			$OuterLight.scale *= vision_light_scale

	if(_powerup in transformative_powerups):
		has_powerup[_powerup] = true

	if(_powerup == "Barrage"):
		shoot()

func _on_Bombastic_timeout():
	has_powerup["Bombastic"] = false
	inf_bombs = false

func _on_Barrage_timeout():
	has_powerup["Barrage"] = false
	bullets_per_burst = default_bullets_per_burst
	bullets_to_shoot = default_bullets_per_burst
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
	$SoundFX/BulletHitFail.pitch_scale = bullet_audio_default_pitch
	is_shooting_indendiary = false

func _on_Opalescence_timeout():
	target_color = colors[randi()%len(colors)]
	has_powerup["Opalescence"] = false
	speed = default_player_speed
	$OpalescenceEffect.emitting = false
	$PowerupTimers/OpalescenceColorShift.stop()

func _on_Unmaker_timeout():
	print("UNMAKER DONE")
	_on_LaserCooldownTimer_timeout()
	$SoundFX/UnmakerAudio.stop()
	$SoundFX/UnmakerAudio/VolTween.stop($SoundFX/UnmakerAudio, "volume_db")
	$SoundFX/UnmakerAudio.volume_db = default_unmaker_vol
	has_powerup["Unmaker"] = false
	


func _on_Vision_timeout():
	has_powerup["Vision"] = false
	$OuterLight.scale = light_size

#func play_enemey_explosion_sound(explosion_pitch=1.0, volume_db_mod=0.0):
#	Global.vibrate_controller(0.2,0.9)
#	$SoundFX/EnemyExplosionSound.pitch_scale = explosion_pitch
#	if($SoundFX/EnemyExplosionSound.playing):
#		$SoundFX/EnemyExplosionSound.volume_db = default_enemy_explosion_vol
#	if($SoundFX/EnemyExplosionSound.volume_db != -80):
#		$SoundFX/EnemyExplosionSound.volume_db += volume_db_mod
#
#	$SoundFX/EnemyExplosionSound.play()

func _on_GameOverWaitTimer_timeout():
	game_over()


func _on_EnemyExplosionSound_finished():
	$SoundFX/EnemyExplosionSound.volume_db = default_enemy_explosion_vol


func _on_LaserExistsTimer_timeout():
	$LaserCooldown.emitting = true
	$SoundFX/LaserCooldownAudio.play()


func _on_InvincibilityTimer_timeout():
	is_invincible = false
