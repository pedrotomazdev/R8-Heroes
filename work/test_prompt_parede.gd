extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	fase.get_node("Dev").set_physics_process(false)
	var bugs = fase.get_node("Inimigos").get_children()
	for bug in bugs:
		bug.set_physics_process(false)
		bug.position = Vector2(-1000,-1000)
	bugs[0].position = Vector2(500,500)
	bugs[1].position = Vector2(250,500)
	var parede := StaticBody2D.new()
	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(30,200)
	colisao.shape = forma
	parede.add_child(colisao)
	fase.add_child(parede)
	parede.position = Vector2(360,500)
	for i in range(3):
		await physics_frame
	var tiro = load("res://projetil_prompt.gd").new()
	tiro.direcao = -1
	fase.add_child(tiro)
	tiro.position = Vector2(650,500)
	await create_timer(0.6).timeout
	assert(bugs[0].vida == 2)
	assert(bugs[1].vida == 3, "Parede deve bloquear dano atras dela")
	assert(not is_instance_valid(tiro))
	print("PASSOU: tiro para esquerda, dano unico e bloqueio por parede.")
	quit()
