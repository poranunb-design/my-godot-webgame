extends Node

@export var mob_scene: PackedScene

func _ready():
	$UserInterface/Retry.hide()
	AudioManager.background_sfx.play()
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
		
func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_player_hit() -> void:
	$MobTimer.stop()
	$UserInterface/Retry.show()
	AudioManager.background_sfx.stop()
	
