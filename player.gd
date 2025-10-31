extends CharacterBody3D
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@onready var anim_player = $Pivot/Player/AnimationPlayer
@export var fall_acceleration = 75
@export var jump_impulse = 20.0
@export var bounce_impulse = 16
var target_velocity = Vector3.ZERO
signal hit

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		anim_player.play("CharacterArmature|Bite_Front")
	elif Input.is_action_pressed("move_left"):
		direction.x -= 1
		anim_player.play("CharacterArmature|Bite_Front")
	elif Input.is_action_pressed("move_back"):
		direction.z += 1
		anim_player.play("CharacterArmature|Bite_Front")
	elif Input.is_action_pressed("move_forward"):
		direction.z -= 1
		anim_player.play("CharacterArmature|Bite_Front")
	else:
		anim_player.play("CharacterArmature|Idle")
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Gravity
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0  # reset vertical velocity when on ground

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_impulse
		anim_player.play("CharacterArmature|Jump")
	# Apply horizontal velocity
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	
	move_and_slide()
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break

	
func die():
	AudioManager.death_sfx.play()
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	die()
