extends Node2D

# ---------------------------------------------------------
# Nivel 1 jugable — prototipo de migración a Godot.
# Controles: mantené click izquierdo para apuntar y cargar
# potencia, soltá para disparar.
# ---------------------------------------------------------

const CANNONBALL_SCENE := preload("res://scenes/Cannonball.tscn")

const MIN_POWER := 250.0
const MAX_POWER := 900.0
const CHARGE_TIME_TO_MAX := 1.1  # segundos para llegar a potencia máxima

# Datos del "nivel" (equivalentes a levels.js del juego original)
var level_gravity := 1.1
var level_wind := 0.3
var targets_remaining := 3

var _charging := false
var _charge_t := 0.0
var _game_over := false

@onready var cannon_pivot: Marker2D = $PlayerShip/CannonPivot
@onready var trajectory: Line2D = $TrajectoryLine
@onready var enemy_ship = $EnemyShip
@onready var hp_label: Label = $UI/HUD/HPLabel
@onready var wind_label: Label = $UI/HUD/WindLabel
@onready var power_bar: ProgressBar = $UI/HUD/PowerBar
@onready var victory_panel: Control = $UI/VictoryPanel
@onready var victory_label: Label = $UI/VictoryPanel/Label

func _ready() -> void:
	targets_remaining = enemy_ship.max_hp
	_update_hud()
	wind_label.text = "Viento: %s" % _wind_text(level_wind)
	victory_panel.visible = false
	enemy_ship.connect("hit", Callable(self, "_on_enemy_hit"))
	enemy_ship.connect("destroyed", Callable(self, "_on_enemy_destroyed"))
	trajectory.clear_points()

func _wind_text(w: float) -> String:
	if abs(w) < 0.05:
		return "calma"
	elif w > 0:
		return "→ %.1f" % w
	else:
		return "← %.1f" % abs(w)

func _unhandled_input(event: InputEvent) -> void:
	if _game_over:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_charging = true
			_charge_t = 0.0
		else:
			if _charging:
				_fire(get_global_mouse_position())
			_charging = false
			trajectory.clear_points()
			power_bar.value = 0

func _process(delta: float) -> void:
	if _charging and not _game_over:
		_charge_t = min(_charge_t + delta, CHARGE_TIME_TO_MAX)
		power_bar.value = (_charge_t / CHARGE_TIME_TO_MAX) * 100.0
		_draw_trajectory_preview(get_global_mouse_position())

func _current_power() -> float:
	var f := _charge_t / CHARGE_TIME_TO_MAX
	return lerp(MIN_POWER, MAX_POWER, f)

func _aim_velocity(target_pos: Vector2) -> Vector2:
	var dir := (target_pos - cannon_pivot.global_position).normalized()
	return dir * _current_power()

func _fire(target_pos: Vector2) -> void:
	var ball := CANNONBALL_SCENE.instantiate()
	get_tree().current_scene.add_child(ball)
	ball.global_position = cannon_pivot.global_position
	ball.setup(_aim_velocity(target_pos), level_gravity, level_wind)

func _draw_trajectory_preview(target_pos: Vector2) -> void:
	var vel := _aim_velocity(target_pos)
	var pts := PackedVector2Array()
	var pos := cannon_pivot.global_position
	var ax := level_wind * 0.3 * 150.0
	var ay := level_gravity * 500.0
	var t := 0.0
	var dt := 0.05
	for i in range(40):
		t += dt
		var px := pos.x + vel.x * t + 0.5 * ax * t * t
		var py := pos.y + vel.y * t + 0.5 * ay * t * t
		pts.append(Vector2(px, py))
		if py > get_viewport_rect().size.y:
			break
	trajectory.points = pts

func _on_enemy_hit(remaining: int) -> void:
	targets_remaining = remaining
	_update_hud()

func _on_enemy_destroyed() -> void:
	_game_over = true
	victory_panel.visible = true
	victory_label.text = "¡VICTORIA!\nHundiste el barco enemigo."

func _update_hud() -> void:
	hp_label.text = "Vida enemigo: %d" % targets_remaining

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
