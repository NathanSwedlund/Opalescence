extends Node2D

export var title = "TITLE"
export var description = "DESCRIPTION"
var index = 0
var page_container = null
export var settings = {
	"is_mission":true,
	"has_point_goal":true,
	"has_time_goal":false,
	"point_goal":0.0,
	"time_goal":0.0,
	"points_scale":null,
	"point_is_active":true,
	"point_time_min":null,
	"point_time_max":null,
	"point_color_override":null,
	"enemy_is_active":true,
	"enemy_health_scale":1.0,
	"enemy_time_min":null,
	"enemy_time_max":null,
	"enemy_spawn_away_radius":null,
	"enemy_blocker_prob":null,
	"enemy_chaser_prob":null,
	"enemy_comet_prob":null,
	"enemy_shooter_prob":null,
	"powerup_is_active":true,
	"powerup_time_min":null,
	"powerup_time_max":null,
	"powerup_barrage_prob":null,
	"powerup_bomb_up_prob":null,
	"powerup_bombastic_prob":null,
	"powerup_bulet_time_prob":null,
	"powerup_gravity_well_prob":null,
	"powerup_incendiary_prob":null,
	"powerup_max_bomb_prob":null,
	"powerup_max_up_prob":null,
	"powerup_one_up_prob":null,
	"powerup_opalescence_prob":null,
	"powerup_oversheild_prob":null,
	"powerup_unmaker_prob":null,
	"powerup_vision_prob":null,
	"chaser_min_scale":null,
	"chaser_max_scale":null,
	"chaser_base_health":null,
	"chaser_point_reward":null,
	"shooter_shoot_freq_range":null,
	"shooter_point_reward":null,
	"shooter_health":null,
	"shooter_missile_speed":null,
	"shooter_missile_health":null,
	"shooter_missile_damage":null,
	"blocker_point_reward":null,
	"blocker_health":null,
	"speed":null,
	"starting_health":null,
	"shrink_scalar":null,
	"min_scale":null,
	"gravity_radius":null,
	"gravity_pull_scale":null,
	"is_active":true,
	"can_bomb":true,
	"starting_bombs":null,
	"powerup_point_value":null,
	"bullet_time_time_scale":null,
	"vision_light_scale":null,
	"gravity_well_pull_scale":null,
	"gravity_well_radius":null,
	"barrage_burst_time":null,
	"unmaker_scale":null,
	"can_shoot":true,
	"default_bullets_per_burst":3,
	"default_bullets_burst_wait_time":null,
	"default_bullets_cooldown_wait_time":null,
	"can_shoot_laser":true
}

# Called when the node enters the scene tree for the first time.
func _ready():
	settings["mission_title"] = title

	$Title.text = title
	$HighScore.text = "High Score: "+str(HighScore.get_score(title))

	if(settings["has_point_goal"]):
		$Goal.text = "Goal: "+str(settings["point_goal"])+"pts"
		$HighScore.text += "s"

	if(settings["has_time_goal"]):
		$Goal.text = "Goal: "+str(settings["time_goal"])+"s"
		$HighScore.text += "pts"

	$Description.text = description

func _on_Button_pressed():
	if(page_container != null):
		page_container.panel_pressed(index)
