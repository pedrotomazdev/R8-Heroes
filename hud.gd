extends CanvasLayer

# Sem texto no HUD; estes dados continuam disponíveis aos outros sistemas.
@export var caminho_jogador: NodePath = NodePath("../Dev")

@onready var visual: Control = $Visual
@onready var retrato: AnimatedSprite2D = $Visual/Retrato

var indice_estado: int = 0
var estado_atual: String = "TUDO OK"
var sanidade_atual: int = 100
var sanidade_maxima: int = 100
var transicao: Tween
var transicao_burnout: Tween
@onready var tela_burnout: Control = $TelaBurnout/Conteudo


func _ready() -> void:
	var jogador = get_node(caminho_jogador)
	_criar_animacoes(jogador.retratos_sanidade_animados)
	jogador.vida_alterada.connect(_atualizar_vida)
	jogador.energia_alterada.connect(_atualizar_energia)
	_atualizar_energia(jogador.energia,jogador.energia_maxima)
	_atualizar_vida(jogador.vida, jogador.vida_maxima)


func _atualizar_energia(atual: float, maxima: float) -> void:
	visual.energia = clampf(atual/maxf(maxima,1.0),0.0,1.0)
	visual.queue_redraw()


func _criar_animacoes(folha: Texture2D) -> void:
	# Três colunas de animação e cinco linhas de estado por personagem.
	var animacoes := SpriteFrames.new()
	animacoes.remove_animation("default")
	var lado := float(folha.get_width()) / 3.0
	for linha in range(5):
		var nome := StringName("estado_%d" % linha)
		animacoes.add_animation(nome)
		animacoes.set_animation_speed(nome, 1.0)
		animacoes.set_animation_loop(nome, true)
		for coluna in range(3):
			var quadro := AtlasTexture.new()
			quadro.atlas = folha
			quadro.region = Rect2(coluna * lado, linha * lado, lado, lado)
			# Respiração lenta, piscada rápida. Burnout mantém olhos fechados.
			var duracao: float = [1.8, 0.65, 0.12][coluna]
			if linha == 4:
				duracao = 0.8
			animacoes.add_frame(nome, quadro, duracao)
	retrato.sprite_frames = animacoes


func _atualizar_vida(atual: int, maxima: int) -> void:
	sanidade_atual = atual
	sanidade_maxima = maxima
	# A própria mudança de sanidade exibe e encerra a tela, inclusive no respawn.
	if atual <= 0 and not tela_burnout.visible:
		tela_burnout.show()
		tela_burnout.modulate.a = 0.0
		transicao_burnout = create_tween()
		transicao_burnout.tween_property(tela_burnout, "modulate:a", 1.0, 0.18)
	elif atual > 0:
		if transicao_burnout:
			transicao_burnout.kill()
		tela_burnout.hide()
	var proporcao := clampf(float(atual) / maxf(float(maxima), 1.0), 0.0, 1.0)
	indice_estado = 0
	estado_atual = "TUDO OK"
	var cor := Color("8defa5")
	if atual <= 0:
		indice_estado = 4
		estado_atual = "BURNOUT!"
		cor = Color("ff4b75")
	elif proporcao <= 0.10:
		indice_estado = 3
		estado_atual = "NO LIMITE"
		cor = Color("ff4b75")
	elif proporcao <= 0.40:
		indice_estado = 2
		estado_atual = "ESGOTADO"
		cor = Color("ff9566")
	elif proporcao <= 0.60:
		indice_estado = 1
		estado_atual = "SOB PRESSÃO"
		cor = Color("ffe09a")
	var animacao := StringName("estado_%d" % indice_estado)
	if retrato.animation != animacao or not retrato.is_playing():
		retrato.play(animacao)
	visual.cor_sanidade = cor
	visual.critico = proporcao <= 0.10
	if transicao:
		transicao.kill()
	# A barra responde rápido; a cauda de dano acompanha mais lentamente.
	visual.cauda = maxf(visual.cauda, visual.sanidade)
	transicao = create_tween()
	transicao.tween_property(visual, "sanidade", proporcao, 0.15)
	transicao.tween_interval(0.15)
	transicao.tween_property(visual, "cauda", proporcao, 0.30)
	visual.queue_redraw()
