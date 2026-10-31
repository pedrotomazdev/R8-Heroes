extends "res://alvo.gd"

@export var distancia_deteccao: float = 620.0
@export var tempo_aviso: float = 0.75
@export var intervalo_tiros: float = 2.6
var recarga: float = 1.0
var aviso_restante: float = 0.0
var recuperacao: float = 0.0
var preparando: bool = false
var mira := Vector2.LEFT
const TIRO = preload("res://tiro_bug.gd")

func _physics_process(delta: float) -> void:
	recarga = maxf(0,recarga-delta)
	if atordoamento_restante > 0:
		_cancelar_carga()
		super._physics_process(delta)
		queue_redraw()
		return
	var jogador = get_tree().current_scene.get_node_or_null("Dev")
	if preparando:
		if not is_instance_valid(jogador) or jogador.morto:
			_cancelar_carga()
		else:
			aviso_restante -= delta
			sprite.frame = 0 if aviso_restante > tempo_aviso*0.55 else 1
			if aviso_restante <= 0:
				_disparar()
	if preparando or recuperacao > 0:
		recuperacao = maxf(0,recuperacao-delta)
		_causar_dano_contato()
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity()*delta
		move_and_slide()
		queue_redraw()
		return
	if recarga <= 0 and is_on_floor() and is_instance_valid(jogador) and not jogador.morto:
		var origem := global_position+Vector2(0,20)
		var alvo: Vector2 = jogador.global_position+Vector2(0,30)
		if absf(alvo.x-origem.x) < distancia_deteccao and absf(alvo.y-origem.y) < 160:
			var parede := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(origem,alvo,1))
			if parede.is_empty():
				# Mira fixada no início do aviso: o jogador pode saltar para desviar.
				mira = (alvo-origem).normalized()
				direcao = -1.0 if mira.x < 0 else 1.0
				atualizar_direcao()
				preparando = true
				aviso_restante = tempo_aviso
				sprite.play("shoot")
				sprite.pause()
				sprite.frame = 0
				queue_redraw()
				return
	sprite.play("walk")
	super._physics_process(delta)
	queue_redraw()

func _disparar() -> void:
	preparando = false
	recarga = intervalo_tiros
	recuperacao = 0.30
	sprite.play("shoot")
	sprite.frame = 2
	var tiro := TIRO.new()
	tiro.direcao = mira
	get_tree().current_scene.add_child(tiro)
	tiro.global_position = global_position+Vector2(direcao*48,20)
	tiro.z_index = 3

func _cancelar_carga() -> void:
	preparando = false
	aviso_restante = 0
	recuperacao = 0
	recarga = maxf(recarga,0.8)
	sprite.play("walk")

func receber_golpe() -> void:
	_cancelar_carga()
	super.receber_golpe()
	queue_redraw()

func _draw() -> void:
	if not preparando:
		return
	# Aviso gráfico sem depender de som: exclamação e foco na boca do canhão.
	var carga := 1.0-aviso_restante/tempo_aviso
	draw_rect(Rect2(-3,-62,6,18),Color("ffd478"))
	draw_rect(Rect2(-3,-39,6,6),Color("ffd478"))
	draw_arc(Vector2(direcao*48,20),7+carga*8,0,TAU,16,Color("ff8150"),2)
