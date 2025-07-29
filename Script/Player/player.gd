extends CharacterBody2D

class_name Player

const SPEED = 300.0


@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var camera_2d: Camera2D = $Camera2D
@export var is_in_battle: bool = false
@export var camera_on: bool = true

var stats: Dictionary={
	"hp": 100,
	"shield": 0,
	"magick": 0,
	"special": 0,
	"effects": [],
}

var dead: bool

enum States{
	IDLE,
	WALK,
	DEAD,
}


func _ready() -> void:
	camera_2d.set_enabled(camera_on)


func _physics_process(delta: float) -> void:
	
	if is_in_battle:
		return
	
	var direction_hor: float = Input.get_axis("move_left","move_right")
	var direction_ver: float = Input.get_axis("move_up","move_down")
	
	if direction_hor or direction_ver:
		var direction :Vector2 = Vector2(direction_hor,direction_ver).normalized()
		velocity = SPEED* direction
		if direction_hor < 0:
			sprite_2d.set_flip_h(true)
		elif direction_hor > 0:
			sprite_2d.set_flip_h(false)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	var anim: StringName = choose_animation()
	if sprite_2d.animation != anim :
		sprite_2d.play(anim)


func choose_animation():
	if  is_zero_approx(velocity.length()):
		return &"idle"
	else:
		return &"walk"
