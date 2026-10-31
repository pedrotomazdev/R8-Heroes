extends CharacterBody2D

@export var velocidade: float = 500.0
@export var forca_pulo: float = 420.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_ataque: Area2D = $HitboxAtaque
@onready var colisao_ataque: CollisionShape2D = $HitboxAtaque/CollisionShape2D

var alvos_acertados: Array[Node2D] = []
var aterrissando: bool = false
var preparando_pulo: bool = false
var atacando: bool = false

func _ready() -> void:
	sprite.animation_finished.connect(_ao_terminar_animacao)
	sprite.play("idle")
	sprite.frame_changed.connect(_ao_mudar_quadro)
	hitbox_ataque.body_entered.connect(_ao_ataque_encostar)

func _physics_process(delta: float) -> void:
	var estava_no_chao := is_on_floor()

	if (
		Input.is_action_just_pressed("atacar")
		and estava_no_chao
		and not atacando
		and not preparando_pulo
	):
		atacando = true
		aterrissando = false
		alvos_acertados.clear()
		sprite.play("attack")

		
	# Aplica gravidade enquanto estiver no ar.
	if not estava_no_chao:
		velocity += get_gravity() * delta

	# Começa a preparação. O impulso acontece ao terminar a animação.
	if (
		Input.is_action_just_pressed("pular")
		and estava_no_chao
		and not preparando_pulo
		and not atacando
	):
		preparando_pulo = true
		aterrissando = false
		sprite.play("jump_start")

	# Movimento lateral.
	var direcao := Input.get_axis("mover_esquerda", "mover_direita")
	velocity.x = direcao * velocidade

	if direcao != 0:
		sprite.flip_h = direcao < 0
		hitbox_ataque.position.x = -65.0 if direcao < 0 else 65.0
	move_and_slide()

	# Retorna ao início se cair para fora da fase.
	if global_position.y > 900:
		global_position = Vector2(200, 200)
		velocity = Vector2.ZERO
		aterrissando = false
		preparando_pulo = false
		atacando = false
		sprite.play("idle")
		return
	
	if atacando:
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
		
	elif sprite.animation == "attack":
		atacando = false
		
func _ao_mudar_quadro() -> void:
	var golpe_ativo := (
		sprite.animation == "attack"
		and sprite.frame == 3
	)

	colisao_ataque.set_deferred("disabled", not golpe_ativo)


func _ao_ataque_encostar(corpo: Node2D) -> void:
	if not atacando:
		return

	if sprite.animation != "attack" or sprite.frame != 3:
		return

	if corpo == self or corpo in alvos_acertados:
		return

	if corpo.has_method("receber_golpe"):
		alvos_acertados.append(corpo)
		corpo.receber_golpe()
