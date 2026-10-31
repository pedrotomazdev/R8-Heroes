extends CharacterBody2D

@export var vida: int = 5
@export var velocidade: float = 80.0
@export var alcance_sensor: float = 55.0
@export var dano_contato: int = 20

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sensor_borda: RayCast2D = $SensorBorda
@onready var area_contato: Area2D = $AreaContato

var direcao: float = -1.0
var efeito_acerto: Tween
var escala_original: Vector2
var atordoamento_restante: float = 0.0


func _ready() -> void:
	escala_original = sprite.scale
	sprite.play("walk")
	atualizar_direcao()


func _physics_process(delta: float) -> void:
	# Um acerto abre espaço para o jogador: durante esta pausa o bug não
	# anda nem causa dano de contato, mas continua caindo se estiver no ar.
	if atordoamento_restante > 0.0:
		atordoamento_restante = maxf(0.0, atordoamento_restante - delta)
		velocity.x = 0.0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return
	# A área é um pouco maior que o corpo sólido, detectando até um encostão.
	# Consultar continuamente permite novo dano após acabar a invulnerabilidade,
	# mesmo se o jogador continuar encostado sem sair e entrar outra vez.
	for corpo in area_contato.get_overlapping_bodies():
		if corpo != self and corpo.has_method("receber_dano"):
			corpo.receber_dano(dano_contato, global_position)

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
	atordoamento_restante = 0.4
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
