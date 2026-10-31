extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	var bug = fase.get_node("Inimigos/Bug3")
	for inimigo in fase.get_node("Inimigos").get_children():
		inimigo.set_physics_process(false)
		if inimigo != bug:
			inimigo.position = Vector2(-1500,-1500)
	dev.position = Vector2(2305,450)
	for i in range(35):
		await physics_frame
	assert(dev.is_on_floor())
	bug.recarga = 0
	bug.set_physics_process(true)
	for i in range(80):
		await physics_frame
		if bug.preparando:
			break
	assert(bug.preparando and bug.aviso_restante > 0)
	assert(get_nodes_in_group("projeteis_inimigos").is_empty())
	# Uma tecladada interrompe o aviso e impede o tiro daquela carga.
	bug.receber_golpe()
	assert(not bug.preparando and bug.vida == 2)
	await create_timer(0.6).timeout
	assert(get_nodes_in_group("projeteis_inimigos").is_empty())
	bug.recarga = 0
	for i in range(80):
		await physics_frame
		if bug.preparando:
			break
	assert(bug.preparando)
	# Deixar a carga terminar produz um projétil real que causa 15 de dano.
	await create_timer(1.4).timeout
	assert(dev.vida == 85, "Tiro deve acertar uma vez e causar 15")
	bug.set_physics_process(false)
	# Parede no caminho impede o dano de outro disparo.
	dev.invulnerabilidade_restante = 0
	dev.position = Vector2(2000,480)
	dev.velocity = Vector2.ZERO
	var parede := StaticBody2D.new()
	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(30,200)
	colisao.shape = forma
	parede.add_child(colisao)
	fase.add_child(parede)
	parede.position = Vector2(2200,500)
	for i in range(3):
		await physics_frame
	var tiro = load("res://tiro_bug.gd").new()
	tiro.direcao = Vector2.LEFT
	fase.add_child(tiro)
	tiro.position = Vector2(2350,510)
	await create_timer(0.7).timeout
	assert(dev.vida == 85 and not is_instance_valid(tiro))
	assert(fase.get_node("Cenario").paralaxe_casa < 1)
	print("PASSOU: aviso, interrupcao por golpe, disparo, dano, parede e paralaxe.")
	quit()
