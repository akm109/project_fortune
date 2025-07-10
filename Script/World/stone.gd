extends Node2D


const FOLLOW_SPEED = 10.0


@onready var stone_sprite: Sprite2D = $StoneSprite
@onready var label: Label = $StoneSprite/Label
@onready var animation_timer: Timer = $StoneSprite/AnimationTimer


var focused:= false
var dragable:= false
var gota_go := false
var in_bag:= false
var pos_to_go: Vector2
var velocity: Vector2
var ID: int
var t := 0.0
var heritage: Dictionary ={
	"number": null,
	"type": null,
}


signal dropped(stone)
signal stone_stopped(stone)
signal took_stone(stone)

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("LMB"):
		if stone_sprite.get_rect().has_point(to_local(event.position)):
			dragable = true
			ID = -1
			took_stone.emit(self)
	if event is InputEventMouseButton and event.is_action_released("LMB"):
		if dragable:
			dragable = false
			dropped.emit(self)


func _process(delta: float) -> void:
	t = 1 -exp(- delta*FOLLOW_SPEED)
	if dragable:
		velocity = global_position.lerp(get_global_mouse_position(), t) - global_position
		global_position += velocity
	elif not velocity.is_zero_approx():
		global_position += velocity
		velocity = velocity*0.85
	else:
		stone_stopped.emit(self)
	if gota_go:
		global_position = global_position.lerp(pos_to_go, t)
		if( global_position - pos_to_go).is_zero_approx():
			gota_go = false


func focuse():
	stone_sprite.set_scale(Vector2(1.5,1.5))
	emit_signal("pocus")
	animation_timer.start()


func assign_heritage():
	heritage.type = Global.types.pick_random()
	print(heritage.type)
	heritage.number = randi() % 9 + 1
	await ready
	label.text = str(heritage.number)
	match_color(heritage.type)
	print(label.label_settings.font_color)


func match_color(type:String):
	match type:
		"attack":
			label.label_settings.font_color = Color.RED
		"deffend":
			label.label_settings.font_color = Color.SILVER
		"magick":
			label.label_settings.font_color = Color.BLUE_VIOLET
		"special":
			label.label_settings.font_color = Color.ORANGE
