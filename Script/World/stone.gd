extends Node2D


class_name Stone


const FOLLOW_SPEED = 10.0


@onready var stone_sprite: Sprite2D = $StoneSprite
@onready var label: Label = $StoneSprite/Label
@onready var animation_timer: Timer = $StoneSprite/AnimationTimer
@onready var panel_container: PanelContainer = $StoneSprite/PanelContainer


var focused:= false
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
signal taken(stone)

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
#Handle taking stone
	if event is InputEventMouseButton and event.is_action_pressed("LMB"):
		if stone_sprite.get_rect().has_point(to_local(event.position)):
			if not focused:                        #if we clicked on stone that wasnt taken already we take it
				focuse(true)
			else:
				focuse(false)                      #if it was already taken we drop it
		elif focused:
			focuse(false)                          # if we had stone in hands and clicked somewhere else we drop it



func focuse(foc: bool) -> void:
	if foc:
		panel_container.set_modulate(Color.RED)   #if focused highlight it!! and tell everbody around about it
		focused = true
		taken.emit(self)
	else:
		panel_container.set_modulate(Color.WHITE) # if you dropped it strip off it's regalia and tell everyone about it
		focused = false
		dropped.emit(self)


func assign_heritage() -> void:
	if not is_node_ready():
		await ready                                                    # wait a little so nothing brokes when we trie to do smth 
	var choosen_rock = Global.bag_rocks.pick_random().duplicate()  # I want marble just like yours but mine
	Global.bag_rocks.erase(choosen_rock)                           # Throw away your marble
	heritage.type = choosen_rock[1]
	heritage.number = choosen_rock[0]
	label.text = str(heritage.number)
	match_color(heritage.type)                                     # Now stone looks just like that marble


func match_color(type:String):
	match type:
		"attack":
			label.label_settings.font_color = Color.RED             # Red stands for BLOOD of our Enemies
		"deffend":
			label.label_settings.font_color = Color.DODGER_BLUE    #  Light blue seems just like tint of steel shield
		"magick":
			label.label_settings.font_color = Color.BLUE_VIOLET     # Violet Magic?
		"special":
			label.label_settings.font_color = Color.ORANGE          # Orange....
