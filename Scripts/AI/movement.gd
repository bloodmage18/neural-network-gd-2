class_name creature_movement extends Node2D

@export var speed: float = 100.0
@export var rotate_speed: float = 100.0

func move(fb: float, lr: float):
	# Clamp the values of lr and fb
	lr = clampf(lr, -1.0, 1.0)
	fb = clampf(fb, 0.0, 1.0)

	# Rotate
	rotate(deg_to_rad(lr * rotate_speed))

	# Move forward
	var velocity = transform.x * speed * fb # transform.x is the forward vector in 2D
	get_parent().velocity = velocity
	get_parent().move_and_slide()
