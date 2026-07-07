extends Area2D

# ---------------------------------------------------------
# Bala de cañón con física simple: gravedad + viento.
# Replica la fórmula del juego original (PirateGame.jsx):
#   ax = windX * 0.3
#   ay = gravity
# Aquí los valores de "gravity" y "windX" vienen del nivel
# y se multiplican por constantes de escala en píxeles.
# ---------------------------------------------------------

const GRAVITY_SCALE := 500.0   # px/s^2 por cada unidad de "gravity" del nivel
const WIND_SCALE := 150.0      # px/s^2 por cada unidad de "windX" del nivel
const RADIUS := 8.0
const MAX_LIFETIME := 6.0

var velocity := Vector2.ZERO
var level_gravity := 1.1
var level_wind := 0.0
var _life := 0.0
var _active := true
var _visible := true

func setup(start_velocity: Vector2, gravity: float, wind_x: float) -> void:
	velocity = start_velocity
	level_gravity = gravity
	level_wind = wind_x

func _physics_process(delta: float) -> void:
	if not _active:
		return

	_life += delta
	if _life > MAX_LIFETIME:
		queue_free()
		return

	var ax := level_wind * 0.3 * WIND_SCALE
	var ay := level_gravity * GRAVITY_SCALE

	velocity.x += ax * delta
	velocity.y += ay * delta
	position += velocity * delta

	rotation = velocity.angle()
	queue_redraw()

	var vp_size := get_viewport_rect().size
	# Se destruye si sale de la pantalla por abajo o muy lejos a los lados.
	if position.y > vp_size.y + 100 or position.x < -100 or position.x > vp_size.x + 400:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not _active:
		return
	if area.is_in_group("enemy_hurtbox"):
		_active = false
		area.get_parent().call("take_hit")
		_explode()

func _on_body_entered(_body: Node) -> void:
	if not _active:
		return
	_active = false
	_explode()

func _draw() -> void:
	if not _visible:
		return
	draw_circle(Vector2.ZERO, RADIUS, Color(0.15, 0.13, 0.1))
	draw_circle(Vector2(-2, -2), RADIUS * 0.35, Color(0.4, 0.38, 0.32))

func _explode() -> void:
	# Pequeño efecto visual de impacto antes de desaparecer.
	_visible = false
	queue_redraw()
	var particles := CPUParticles2D.new()
	add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 14
	particles.lifetime = 0.4
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180
	particles.initial_velocity_min = 60
	particles.initial_velocity_max = 160
	particles.gravity = Vector2(0, 300)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(0.9, 0.85, 0.6)
	await get_tree().create_timer(0.5).timeout
	queue_free()
