extends CharacterBody2D

@export var vida: int = 5
@export var velocidade: float = 80.0
@export var alcance_sensor: float = 55.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sensor_borda: RayCast2D = $SensorBorda

var direcao: float = -1.0
var efeito_acerto: Tween
var escala_original: Vector2


func _ready() -> void:
	escala_original = sprite.scale
	sprite.play("walk")
	atualizar_direcao()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Consulta o chão à frente antes de avançar.
	sensor_borda.force_raycast_update()

	if is_on_floor() and not sensor_borda.is_colliding():
		virar()

	velocity.x = direcao * velocidade
	move_and_slide()

	# Também vira ao esbarrar numa parede ou no jogador.
	if is_on_wall():
		virar()


func virar() -> void:
	direcao *= -1.0
	atualizar_direcao()


func atualizar_direcao() -> void:
	# A arte original do bug olha para a esquerda.
	sprite.flip_h = direcao > 0
	sensor_borda.position.x = alcance_sensor * direcao
	sensor_borda.force_raycast_update()


func receber_golpe() -> void:
	vida -= 1
	print("Vida do bug: ", vida)

	if vida <= 0:
		queue_free()
		return

	if efeito_acerto:
		efeito_acerto.kill()

	sprite.scale = escala_original
	sprite.modulate = Color(3.0, 3.0, 3.0)

	efeito_acerto = create_tween()

	efeito_acerto.tween_property(
		sprite,
		"scale",
		escala_original * Vector2(1.20, 0.75),
		0.05
	)

	efeito_acerto.tween_property(
		sprite,
		"scale",
		escala_original * Vector2(0.92, 1.10),
		0.07
	)

	efeito_acerto.tween_property(
		sprite,
		"scale",
		escala_original,
		0.08
	)

	efeito_acerto.parallel().tween_property(
		sprite,
		"modulate",
		Color.WHITE,
		0.08
	)
