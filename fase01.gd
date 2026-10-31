extends Node2D

# Esta cena é o percurso jogável. O estacionamento antigo continua como laboratório.
@onready var dev = $Dev
@onready var objetivo: Label = $Interface/Objetivo
@onready var mensagem: Label = $Interface/Mensagem
@onready var fim: PanelContainer = $Interface/Fim
@onready var musica: AudioStreamPlayer = $Musica

var checkpoint := Vector2(180, 450)
var concluida: bool = false
var aviso_restante: float = 0.0


func _ready() -> void:
	_iniciar_musica()
	var camera: Camera2D = dev.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = 5320
	camera.limit_top = 0
	camera.limit_bottom = 900
	mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objetivo.position.x = 410
	mensagem.position.x = 410
	mensagem.size.x = 850
	# Itens e checkpoints procuram a camada do jogador, não a dos inimigos.
	for nome in ["Checkpoint1", "Checkpoint2", "Hotdog1", "Hotdog2", "Saida"]:
		get_node(nome).collision_mask = 2
	# As áreas da cena têm nomes simples para facilitar encontrar cada evento.
	$Checkpoint1.body_entered.connect(_ativar_checkpoint.bind($Checkpoint1))
	$Checkpoint2.body_entered.connect(_ativar_checkpoint.bind($Checkpoint2))
	$Hotdog1.body_entered.connect(_pegar_hotdog.bind($Hotdog1))
	$Hotdog2.body_entered.connect(_pegar_hotdog.bind($Hotdog2))
	$Saida.body_entered.connect(_chegar_na_saida)
	$Interface/Fim/Margem/Coluna/Rejogar.pressed.connect(_rejogar)
	_avisar("A/D: mover   |   W/Espaço: pular   |   Mouse: esquerdo = teclado, direito = prompt", 7.0)


func _iniciar_musica() -> void:
	# Stream próprio da fase: continua tocando ao voltar para um checkpoint.
	# Duplicar evita alterar o recurso de áudio compartilhado no editor.
	var faixa := musica.stream.duplicate() as AudioStreamWAV
	faixa.loop_mode = AudioStreamWAV.LOOP_FORWARD
	faixa.loop_begin = 0
	faixa.loop_end = roundi(faixa.get_length()*faixa.mix_rate)
	musica.stream = faixa
	# Volume moderado, ajustável no nó Musica. Entrada suave evita um susto.
	var volume_final := musica.volume_db
	musica.volume_db = -40.0
	musica.play()
	create_tween().tween_property(musica,"volume_db",volume_final,0.8)


func _process(delta: float) -> void:
	if concluida:
		return
	var restantes := $Inimigos.get_child_count()
	objetivo.text = "01 / ESTACIONAMENTO ANTIGO     •     Bugs restantes: %d" % restantes
	aviso_restante = maxf(0.0, aviso_restante - delta)
	mensagem.visible = aviso_restante > 0.0


func _ativar_checkpoint(corpo: Node2D, area: Area2D) -> void:
	if corpo != dev or area.get_meta("ativado", false):
		return
	area.set_meta("ativado", true)
	checkpoint = Vector2(area.position.x, 450)
	dev.posicao_inicial = checkpoint
	area.get_node("Bandeira").color = Color("63dfb1")
	_avisar("CHECKPOINT / Seu próximo retorno fica aqui.")


func _pegar_hotdog(corpo: Node2D, area: Area2D) -> void:
	if corpo != dev or dev.morto or area.get_meta("usado", false):
		return
	# Só consome quando há vida para recuperar.
	if dev.vida >= dev.vida_maxima:
		return
	area.set_meta("usado", true)
	dev.vida = mini(dev.vida + 40, dev.vida_maxima)
	dev.vida_alterada.emit(dev.vida, dev.vida_maxima)
	area.hide()
	_avisar("HOTDOG / +40 de sanidade. Pausa pra um lanche!")


func reiniciar_no_checkpoint() -> void:
	# Mantém os bugs derrotados fora da fase, evitando repetir o percurso inteiro.
	dev.restaurar_no_checkpoint(checkpoint)
	_avisar("De volta ao expediente. Sanidade restaurada no checkpoint.")


func _chegar_na_saida(corpo: Node2D) -> void:
	if corpo != dev or dev.morto or concluida:
		return
	if $Inimigos.get_child_count() > 0:
		_avisar("Ainda tem bug no estacionamento! Limpe a área antes de entrar.")
		return
	concluida = true
	dev._cancelar_acoes()
	dev.velocity = Vector2.ZERO
	dev.set_physics_process(false)
	# Encerra os disparos que ainda estavam voando quando a fase terminou.
	for tiro in get_tree().get_nodes_in_group("projeteis_inimigos"):
		tiro.queue_free()
	dev.sprite.play("idle")
	fim.show()
	objetivo.text = "ESTACIONAMENTO LIMPO / FASE CONCLUÍDA"
	mensagem.hide()


func _avisar(texto: String, duracao: float = 4.0) -> void:
	mensagem.text = texto
	mensagem.show()
	aviso_restante = duracao


func _rejogar() -> void:
	get_tree().reload_current_scene()


func _draw() -> void:
	# Texturas e paralaxe ficam no nó Cenario; esta cena gerencia as regras.
	pass
