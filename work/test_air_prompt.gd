extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	for bug in fase.get_node("Inimigos").get_children():
		bug.set_physics_process(false)
		bug.position = Vector2(-1000,-1000)
	var tiros := [0]
	fase.child_entered_tree.connect(func(filho: Node):
		if filho.name.begins_with("ProjetilPrompt"):
			tiros[0] += 1
	)
	for i in range(45):
		await physics_frame
	Input.action_press("mover_direita")
	Input.action_press("pular")
	for i in range(3):
		await physics_frame
	Input.action_release("pular")
	assert(not dev.is_on_floor())
	Input.action_press("prompt")
	for i in range(2):
		await physics_frame
	Input.action_release("prompt")
	assert(dev.conjurando_prompt and dev.sprite.animation == "air_prompt")
	assert(dev.energia == 75 and dev.velocity.x > 0)
	await process_frame
	# process_frame é emitido antes do _process do terminal; atualiza este frame.
	dev.terminal_ativo._process(0.0)
	assert(dev.terminal_ativo.global_position.distance_to(dev.global_position+dev.terminal_ativo.deslocamento) < 1)
	await create_timer(0.65).timeout
	Input.action_release("mover_direita")
	assert(not dev.conjurando_prompt and tiros[0] == 1)
	# Começa no chão, pula DURANTE a preparação e verifica que o cast não reinicia.
	dev.global_position = Vector2(180,450)
	dev.velocity = Vector2.ZERO
	for i in range(40):
		await physics_frame
	dev.recarga_prompt = 0
	dev.energia = 100
	assert(dev._tentar_prompt())
	Input.action_press("pular")
	for i in range(3):
		await physics_frame
	Input.action_release("pular")
	assert(dev.sprite.animation == "air_prompt" and dev.velocity.y < 0)
	assert(dev.energia == 75)
	await create_timer(0.65).timeout
	assert(tiros[0] == 2 and not dev.conjurando_prompt)
	print("PASSOU: skill no salto, movimento aereo, terminal acompanha, pulo durante cast e um tiro por uso.")
	quit()
