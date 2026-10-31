extends CharacterBody2D

# O HUD escuta este sinal; o personagem não precisa conhecer a interface.
signal vida_alterada(atual: int, maxima: int)
signal energia_alterada(atual: float, maxima: float)

# Energia é independente da sanidade. O custo acontece ao começar a digitar.
@export var energia_maxima: float = 100.0
@export var custo_prompt: float = 25.0
@export var regeneracao_energia: float = 10.0
var energia: float = 100.0
var espera_regeneracao: float = 0.0
var recarga_prompt: float = 0.0
var conjurando_prompt: bool = false
var prompt_emitido: bool = false
var direcao_prompt: float = 1.0
var terminal_ativo: Node2D
const PROJETIL_PROMPT = preload("res://projetil_prompt.gd")
const TERMINAL_PROMPT = preload("res://terminal_prompt.gd")

# Cada personagem poderá fornecer seu próprio nome e folha de cinco expressões.
@export var nome_personagem: String = "DEV"
@export var retratos_sanidade: Texture2D = preload("res://assets/dev/retratos/dev-sanity-portraits.png")
@export var retratos_sanidade_animados: Texture2D = preload("res://assets/dev/retratos/dev-sanity-animated-v2.png")

@export var velocidade: float = 500.0
@export var forca_pulo: float = 420.0

# "vida" é o nome interno do recurso de SANIDADE, preservado para manter
# compatibilidade com cenas e scripts. O HUD apresenta o valor como porcentagem.
@export var vida_maxima: int = 100
@export var tempo_invulnerabilidade: float = 1.0
@export var forca_recuo: float = 260.0
@export var distancia_ataque: float = 110.0
# Pequenas tolerâncias de controle: aceita o pulo logo antes de pousar
# e por um instante depois de sair da borda ("coyote time").
@export var tolerancia_borda: float = 0.10
@export var memoria_pulo: float = 0.12
# Tempo para ler a tela de burnout antes de retornar ao checkpoint.
@export var duracao_burnout: float = 2.2
var borda_restante: float = 0.0
var pulo_pendente: float = 0.0

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
	energia = energia_maxima
	energia_alterada.emit(energia, energia_maxima)
	vida = vida_maxima
	vida_alterada.emit(vida, vida_maxima)
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
	# Aguarda um segundo depois de usar a skill antes de recuperar energia.
	recarga_prompt = maxf(0.0,recarga_prompt-delta)
	espera_regeneracao = maxf(0.0,espera_regeneracao-delta)
	if espera_regeneracao <= 0.0 and energia < energia_maxima:
		energia = minf(energia_maxima,energia+regeneracao_energia*delta)
		energia_alterada.emit(energia,energia_maxima)

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
	borda_restante = tolerancia_borda if estava_no_chao else maxf(0.0, borda_restante - delta)
	pulo_pendente = maxf(0.0, pulo_pendente - delta)
	if Input.is_action_just_pressed("pular"):
		pulo_pendente = memoria_pulo
	if Input.is_action_just_pressed("prompt"):
		_tentar_prompt()

	if (
		Input.is_action_just_pressed("atacar")
		and not atacando
		and not conjurando_prompt
	):
		atacando = true
		aterrissando = false
		preparando_pulo = false
		alvos_acertados.clear()
		# A pose será escolhida após mover, usando o chão e a velocidade atuais.
		sprite.play("attack")
		sprite.set_frame_and_progress(0, 0.0)

		
	# Aplica gravidade enquanto estiver no ar.
	if not estava_no_chao:
		velocity += get_gravity() * delta

	# A física responde imediatamente, sem esperar a animação de preparação.
	# Andar, pular e atacar são comandos independentes, inclusive no ar.
	if pulo_pendente > 0.0 and borda_restante > 0.0:
		velocity.y = -forca_pulo
		pulo_pendente = 0.0
		borda_restante = 0.0
		aterrissando = false
		if not atacando and not conjurando_prompt:
			preparando_pulo = true
			sprite.play("jump_start")

	# Movimento lateral.
	var direcao := Input.get_axis("mover_esquerda", "mover_direita")
	if conjurando_prompt and estava_no_chao:
		# No chão ele para para digitar; no ar conserva o controle horizontal.
		direcao = 0.0
	velocity.x = direcao * velocidade

	if direcao != 0 and not conjurando_prompt:
		sprite.flip_h = direcao < 0
		hitbox_ataque.position.x = -distancia_ataque if direcao < 0 else distancia_ataque
	move_and_slide()

	# Retorna ao início se cair para fora da fase.
	if global_position.y > 900:
		_retornar_ao_inicio()
		return
	
	if atacando:
		_atualizar_pose_ataque()
		return
	if conjurando_prompt:
		_atualizar_pose_prompt()
		return
	# A reação visual dura um pouco mais que o bloqueio curto de movimento.
	if sprite.animation == "hurt" and sprite.is_playing():
		return
		
	# Escolhe a animação conforme o movimento.
	if not is_on_floor():
		aterrissando = false
		# A preparação é apenas visual e toca durante o início da subida.
		if preparando_pulo and velocity.y < 0:
			return
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
	if sprite.animation in ["prompt", "air_prompt"]:
		conjurando_prompt = false
		if is_on_floor():
			sprite.play("idle")
		else:
			sprite.play("jump" if velocity.y < 0 else "fall")
		return
	if sprite.animation == "jump_start":
		preparando_pulo = false
		sprite.play("jump" if velocity.y < 0 else "fall")


	elif sprite.animation == "land":
		aterrissando = false
		
	elif sprite.animation in ["attack", "run_attack", "air_attack"]:
		atacando = false
		# Evita terminar o golpe suspenso numa pose de chão.
		if not is_on_floor():
			sprite.play("jump" if velocity.y < 0 else "fall")
	elif sprite.animation == "hurt":
		sprite.play("idle" if is_on_floor() else "fall")
		
func _ao_mudar_quadro() -> void:
	if conjurando_prompt and sprite.animation in ["prompt", "air_prompt"] and sprite.frame == 3 and not prompt_emitido:
		_emitir_prompt()
	var golpe_ativo := (
		not morto and atacando and sprite.animation in ["attack", "run_attack", "air_attack"]
		and sprite.frame >= 2 and sprite.frame <= 3
	)

	colisao_ataque.set_deferred("disabled", not golpe_ativo)


func _ao_ataque_encostar(corpo: Node2D) -> void:
	if not atacando:
		return

	if sprite.animation not in ["attack", "run_attack", "air_attack"] or sprite.frame < 2 or sprite.frame > 3:
		return

	if corpo == self or corpo in alvos_acertados:
		return

	if corpo.has_method("receber_golpe"):
		alvos_acertados.append(corpo)
		corpo.receber_golpe()


func _atualizar_pose_ataque() -> void:
	var animacao: StringName = &"attack"
	if not is_on_floor():
		animacao = &"air_attack"
	elif absf(velocity.x) > 1.0:
		animacao = &"run_attack"
	if sprite.animation == animacao:
		return
	# Pode começar a andar, parar ou pular no meio da tecladada.
	# Conserva o quadro do golpe para não reiniciar nem aplicar dano extra.
	var ja_atacava := sprite.animation in ["attack", "run_attack", "air_attack"]
	var quadro := sprite.frame if ja_atacava else 0
	var progresso := sprite.frame_progress if ja_atacava else 0.0
	sprite.play(animacao)
	sprite.set_frame_and_progress(quadro, progresso)
	_ao_mudar_quadro()


func _cancelar_acoes() -> void:
	# Interromper um golpe também deve desligar sua área de dano.
	atacando = false
	conjurando_prompt = false
	if is_instance_valid(terminal_ativo):
		terminal_ativo.queue_free()
	aterrissando = false
	preparando_pulo = false
	pulo_pendente = 0.0
	borda_restante = 0.0
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
	vida_alterada.emit(vida, vida_maxima)
	print("Sanidade do dev: ", vida, "/", vida_maxima)
	_cancelar_acoes()
	if vida == 0:
		_morrer()
		return

	invulnerabilidade_restante = tempo_invulnerabilidade
	recuo_restante = 0.18
	# Empurra para o lado oposto ao inimigo, com um pequeno salto de reação.
	var lado := 1.0 if global_position.x >= origem.x else -1.0
	velocity = Vector2(lado * forca_recuo, -180.0)
	sprite.play("hurt")


func _morrer() -> void:
	morto = true
	velocity = Vector2.ZERO
	sprite.stop()
	sprite.modulate = Color(1.0, 0.35, 0.35, 1.0)
	print("BURNOUT! Pausa obrigatória antes de voltar ao expediente.")
	# Reinicia também os inimigos, permitindo testar o ciclo completo novamente.
	await get_tree().create_timer(duracao_burnout).timeout
	var fase := get_tree().current_scene
	if fase.has_method("reiniciar_no_checkpoint"):
		fase.reiniciar_no_checkpoint()
	else:
		get_tree().reload_current_scene()


func restaurar_no_checkpoint(destino: Vector2) -> void:
	# A fase decide onde voltar; o personagem restaura seu próprio estado.
	posicao_inicial = destino
	morto = false
	vida = vida_maxima
	energia = energia_maxima
	recarga_prompt = 0.0
	espera_regeneracao = 0.0
	energia_alterada.emit(energia,energia_maxima)
	invulnerabilidade_restante = tempo_invulnerabilidade
	sprite.modulate = Color.WHITE
	_retornar_ao_inicio()
	$Camera2D.reset_smoothing()
	vida_alterada.emit(vida, vida_maxima)


func _tentar_prompt() -> bool:
	# Sem custo se não puder conjurar; E e Q permanecem livres.
	if morto or atacando or conjurando_prompt or recuo_restante > 0.0 or recarga_prompt > 0.0 or energia < custo_prompt:
		return false
	energia -= custo_prompt
	energia_alterada.emit(energia,energia_maxima)
	espera_regeneracao = 1.0
	recarga_prompt = 0.8
	conjurando_prompt = true
	prompt_emitido = false
	aterrissando = false
	preparando_pulo = false
	direcao_prompt = -1.0 if sprite.flip_h else 1.0
	sprite.play("prompt" if is_on_floor() else "air_prompt")
	sprite.set_frame_and_progress(0,0.0)
	terminal_ativo = TERMINAL_PROMPT.new()
	terminal_ativo.emissor = self
	terminal_ativo.deslocamento = Vector2(direcao_prompt*130,-70)
	get_tree().current_scene.add_child(terminal_ativo)
	terminal_ativo.global_position = global_position+Vector2(direcao_prompt*130,-70)
	terminal_ativo.z_index = 5
	return true


func _atualizar_pose_prompt() -> void:
	# Pousar durante a digitação troca só a pose, sem pagar ou disparar de novo.
	var animacao: StringName = &"prompt" if is_on_floor() else &"air_prompt"
	if sprite.animation == animacao:
		return
	var quadro := sprite.frame
	var progresso := sprite.frame_progress
	sprite.play(animacao)
	sprite.set_frame_and_progress(quadro,progresso)
	_ao_mudar_quadro()


func _emitir_prompt() -> void:
	# Só o quadro de confirmação dispara; não há hitbox de tecladada nesta pose.
	prompt_emitido = true
	var projetil := PROJETIL_PROMPT.new()
	projetil.name = "ProjetilPrompt"
	projetil.direcao = direcao_prompt
	get_tree().current_scene.add_child(projetil)
	projetil.global_position = global_position+Vector2(direcao_prompt*90,18)
	projetil.z_index = 4
