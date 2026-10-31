extends SceneTree


func _initialize() -> void:
	call_deferred("testar")


func testar() -> void:
	var cena = load("res://estacionamento.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	var dev = cena.get_node("Dev")
	var bug = cena.get_node("Alvo")
	await physics_frame
	assert(dev.vida == 100)
	dev.atacando = true
	dev.receber_dano(20, dev.global_position - Vector2(50, 0))
	assert(dev.vida == 80 and dev.velocity.x > 0)
	assert(not dev.atacando)
	dev.receber_dano(20, bug.global_position)
	assert(dev.vida == 80, "Invulnerabilidade deve bloquear dano repetido")
	await physics_frame
	assert(dev.colisao_ataque.disabled)
	# Encosta os corpos e verifica a AreaContato real, não apenas a função de dano.
	dev.invulnerabilidade_restante = 0.0
	dev.recuo_restante = 0.0
	dev.velocity = Vector2.ZERO
	dev.global_position = bug.global_position + Vector2(-58, 0)
	for i in range(8):
		await physics_frame
	assert(dev.vida == 60, "Contato deve causar um único dano durante proteção")
	# Cair fora da fase preserva vida e restaura a posição de entrada da cena.
	dev.global_position.y = 1000
	await physics_frame
	await physics_frame
	assert(dev.global_position.distance_to(dev.posicao_inicial) < 10)
	assert(dev.vida == 60)
	# Dano fatal bloqueia controle e recarrega a cena com vida e inimigo restaurados.
	dev.invulnerabilidade_restante = 0.0
	dev.receber_dano(100, bug.global_position)
	assert(dev.morto and dev.vida == 0)
	await create_timer(dev.duracao_burnout + 0.2).timeout
	assert(current_scene != cena)
	assert(current_scene.get_node("Dev").vida == 100)
	assert(current_scene.has_node("Alvo"))
	print("PASSOU: contato, invulnerabilidade, recuo, cancelamento do ataque, queda e reinicio.")
	quit()

