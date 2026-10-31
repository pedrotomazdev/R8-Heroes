extends CharacterBody2D

@export var velocidade: float = 500.0
@export var forca_pulo: float = 420.0

# Valores ajustáveis pelo Inspetor: vida, proteção após dano e força do recuo.
@export var vida_maxima: int = 100
@export var tempo_invulnerabilidade: float = 1.0
@export var forca_recuo: float = 260.0
@export var distancia_ataque: float = 110.0

var vida: int
var invulnerabilidade_restante: float = 0.0
var recuo_restante: float = 0.0
var morto: bool = false
var posicao_inicial: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_ataque: Area2D = $HitboxAtaque
@onready var colisao_ataque: CollisionShape2D = $HitboxAtaque/CollisionShape2D

var alvos_acertados: Array[Node2D] = []
var aterrissando: bool = false
var preparando_pulo: bool = false
var atacando: bool = false

func _ready() -> void:
	vida = vida_maxima
	posicao_inicial = global_position
	# A cena já começa com uma pose de ataque no editor; desliga a hitbox.
	colisao_ataque.disabled = true
	hitbox_ataque.position.x = distancia_ataque
	sprite.animation_finished.connect(_ao_terminar_animacao)
	sprite.play("idle")
	sprite.frame_changed.connect(_ao_mudar_quadro)
	hitbox_ataque.body_entered.connect(_ao_ataque_encostar)

func _physics_process(delta: float) -> void:
	if morto:
		return

	# Contadores em segundos, independentes da quantidade de frames por segundo.
	invulnerabilidade_restante = maxf(0.0, invulnerabilidade_restante - delta)
	recuo_restante = maxf(0.0, recuo_restante - delta)
	# Pisca somente o desenho. O corpo continua sólido durante a proteção.
	sprite.modulate.a = 0.35 if invulnerabilidade_restante > 0.0 and int(invulnerabilidade_restante * 12.0) % 2 == 0 else 1.0
	if recuo_restante > 0.0:
		# Por um instante, o controle não sobrescreve a velocidade do impacto.
		velocity += get_gravity() * delta
		move_and_slide()
		if global_position.y > 900:
			_retornar_ao_inicio()
		return

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
		hitbox_ataque.position.x = -distancia_ataque if direcao < 0 else distancia_ataque
	move_and_slide()

	# Retorna ao início se cair para fora da fase.
	if global_position.y > 900:
		_retornar_ao_inicio()
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
	if morto:
		return
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
		not morto and atacando and sprite.animation == "attack"
		and sprite.frame >= 2 and sprite.frame <= 3
	)

	colisao_ataque.set_deferred("disabled", not golpe_ativo)


func _ao_ataque_encostar(corpo: Node2D) -> void:
	if not atacando:
		return

	if sprite.animation != "attack" or sprite.frame < 2 or sprite.frame > 3:
		return

	if corpo == self or corpo in alvos_acertados:
		return

	if corpo.has_method("receber_golpe"):
		alvos_acertados.append(corpo)
		corpo.receber_golpe()


func _cancelar_acoes() -> void:
	# Interromper um golpe também deve desligar sua área de dano.
	atacando = false
	aterrissando = false
	preparando_pulo = false
	colisao_ataque.set_deferred("disabled", true)


func _retornar_ao_inicio() -> void:
	# Cair fora da fase ainda não tira vida: preserva nosso teste de plataformas.
	global_position = posicao_inicial
	velocity = Vector2.ZERO
	recuo_restante = 0.0
	_cancelar_acoes()
	sprite.play("idle")


func receber_dano(quantidade: int, origem: Vector2) -> void:
	# Vários contatos no mesmo instante contam como um único golpe.
	if morto or invulnerabilidade_restante > 0.0 or quantidade <= 0:
		return

	vida = maxi(0, vida - quantidade)
	print("Vida do dev: ", vida, "/", vida_maxima)
	_cancelar_acoes()
	if vida == 0:
		_morrer()
		return

	invulnerabilidade_restante = tempo_invulnerabilidade
	recuo_restante = 0.18
	# Empurra para o lado oposto ao inimigo, com um pequeno salto de reação.
	var lado := 1.0 if global_position.x >= origem.x else -1.0
	velocity = Vector2(lado * forca_recuo, -180.0)
	sprite.play("fall")


func _morrer() -> void:
	morto = true
	velocity = Vector2.ZERO
	sprite.stop()
	sprite.modulate = Color(1.0, 0.35, 0.35, 1.0)
	print("Fim do expediente! Reiniciando a fase...")
	# Reinicia também os inimigos, permitindo testar o ciclo completo novamente.
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
