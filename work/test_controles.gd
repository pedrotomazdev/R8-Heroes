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
	for i in range(45):
		await physics_frame
	assert(dev.is_on_floor())
	Input.action_press("mover_direita")
	for i in range(4):
		await physics_frame
	var inicio: Vector2 = dev.position
	Input.action_press("pular")
	for i in range(2):
		await physics_frame
	Input.action_release("pular")
	assert(dev.velocity.y < 0 and dev.position.x > inicio.x)
	assert(dev.position.y < inicio.y, "Pulo precisa responder sem esperar animacao")
	Input.action_press("atacar")
	for i in range(2):
		await physics_frame
	Input.action_release("atacar")
	Input.action_release("mover_direita")
	assert(dev.atacando and dev.sprite.animation == "air_attack")
	# Sem colisão sólida entre bug e dev: a detecção de dano é uma área própria.
	assert(dev.collision_mask & fase.get_node("Inimigos/Bug1").collision_layer == 0)
	# Hotdogs fora da projeção horizontal das plataformas acima deles.
	for nome in ["Hotdog1", "Hotdog2"]:
		var item = fase.get_node(nome)
		for plataforma in fase.get_node("Geometria").get_children():
			if plataforma.name.begins_with("Caixa"):
				var forma = plataforma.get_node("Colisao").shape
				assert(absf(item.position.x - plataforma.position.x) > forma.size.x / 2 + 28)
	print("PASSOU: andar+pular imediato, ataque aereo, camadas e hotdogs acessiveis.")
	quit()
