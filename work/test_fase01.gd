extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	assert(fase.get_node("Inimigos").get_child_count() == 8)
	for inimigo in fase.get_node("Inimigos").get_children():
		inimigo.set_physics_process(false)
	for i in range(80):
		await physics_frame
	assert(dev.is_on_floor(), "Posicao inicial precisa ter chao")
	# Testa os gatilhos usando sobreposição física real.
	dev.global_position = Vector2(1790, 470)
	dev.velocity = Vector2.ZERO
	for i in range(5):
		await physics_frame
	assert(fase.checkpoint.x == 1790)
	dev.vida = 40
	dev.global_position = Vector2(2350, 470)
	for i in range(5):
		await physics_frame
	assert(dev.vida == 80)
	fase.reiniciar_no_checkpoint()
	assert(dev.vida == 100 and dev.global_position.x == 1790)
	fase._chegar_na_saida(dev)
	assert(not fase.concluida, "Saida deve exigir limpar bugs")
	for bug in fase.get_node("Inimigos").get_children():
		bug.queue_free()
	await process_frame
	# Percorre os dois buracos usando as entradas e a física reais do personagem.
	for inicio in [1370.0, 3070.0]:
		dev.global_position = Vector2(inicio, 450)
		dev.velocity = Vector2.ZERO
		for i in range(30):
			await physics_frame
		Input.action_press("mover_direita")
		Input.action_press("pular")
		await physics_frame
		await physics_frame
		Input.action_release("pular")
		for i in range(50):
			await physics_frame
		Input.action_release("mover_direita")
		assert(dev.global_position.x > inicio + 350)
		assert(dev.global_position.y < 650, "Salto deve atravessar o buraco")
		for i in range(30):
			await physics_frame
		assert(dev.is_on_floor())
	# Confere morte real e retorno, sem recriar os inimigos derrotados.
	dev.invulnerabilidade_restante = 0
	dev.receber_dano(100, Vector2.ZERO)
	await create_timer(dev.duracao_burnout + 0.2).timeout
	assert(not dev.morto and dev.vida == 100)
	assert(current_scene == fase and fase.get_node("Inimigos").get_child_count() == 0)
	fase._chegar_na_saida(dev)
	assert(fase.concluida and fase.fim.visible)
	assert(not dev.is_physics_processing())
	print("PASSOU: entrada, oito bugs, checkpoint, hotdog, ambos os saltos, morte, retorno e conclusao.")
	quit()

