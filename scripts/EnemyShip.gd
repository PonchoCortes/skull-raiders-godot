extends Node2D

signal hit(remaining: int)
signal destroyed

@export var max_hp := 3

var hp := max_hp
var _flash_time := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	hp = max_hp

func take_hit() -> void:
	if hp <= 0:
		return
	hp -= 1
	_flash_time = 0.15
	emit_signal("hit", hp)
	if hp <= 0:
		emit_signal("destroyed")
		_sink()

func _sink() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y + 60, 0.8).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(18), 0.8)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.8)

func _process(delta: float) -> void:
	if _flash_time > 0.0:
		_flash_time -= delta
		sprite.modulate = Color(1, 0.4, 0.4)
	else:
		sprite.modulate = Color(1, 1, 1, sprite.modulate.a)
