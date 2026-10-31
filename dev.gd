extends CharacterBody2D

@export var velocidade: float = 500.0
@export var forca_pulo: float = 420.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var aterrissando: bool = false
var preparando_pulo: bool = false


func _ready() -> void:
	sprite.animation_finished.connect(_ao_terminar_animacao)
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	var estava_no_chao := is_on_floor()

	# Aplica gravidade enquanto estiver no ar.
	if not estava_no_chao:
		velocity += get_gravity() * delta

	# Começa a preparação. O impulso acontece ao terminar a animação.
	if (
		Input.is_action_just_pressed("pular")
		and estava_no_chao
		and not preparando_pulo
	):
		preparando_pulo = true
		aterrissando = false
		sprite.play("jump_start")

	# Movimento lateral.
	var direcao := Input.get_axis("mover_esquerda", "mover_direita")
	velocity.x = direcao * velocidade

	if direcao != 0:
		sprite.flip_h = direcao < 0

	move_and_slide()

	# Retorna ao início se cair para fora da fase.
	if global_position.y > 900:
		global_position = Vector2(200, 200)
		velocity = Vector2.ZERO
		aterrissando = false
		preparando_pulo = false
		sprite.play("idle")
		return

	# Escolhe a animação conforme o movimento.
	if not is_on_floor():
		aterrissando = false
		preparando_pulo = false

		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")

	elif not estava_no_chao:
		preparando_pulo = false
		aterrissando = true
		sprite.play("land")

	elif not aterrissando and not preparando_pulo:
		if direcao != 0:
			sprite.play("run")
		else:
			sprite.play("idle")


func _ao_terminar_animacao() -> void:
	if sprite.animation == "jump_start":
		preparando_pulo = false

		if is_on_floor():
			velocity.y = -forca_pulo
			sprite.play("jump")

	elif sprite.animation == "land":
		aterrissando = false
