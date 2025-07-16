extends CharacterBody2D

class_name Player

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	
	var direction_hor: float = Input.get_axis("move_left","move_right")
	var direction_ver: float = Input.get_axis("move_up","move_down")
	
	if direction_hor or direction_ver:
		var direction :Vector2 = Vector2(direction_hor,direction_ver).normalized()
		velocity = SPEED* direction
	else:
		velocity = velocity*0.75
	
	move_and_slide()
