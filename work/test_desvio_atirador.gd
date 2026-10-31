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
	for i in range(40):
		await physics_frame
	bug.recarga = 0
	bug.set_physics_process(true)
	for i in range(80):
		await physics_frame
		if bug.preparando:
			break
	assert(bug.preparando)
	await create_timer(0.45).timeout
	Input.action_press("pular")
	for i in range(2):
		await physics_frame
	Input.action_release("pular")
	await create_timer(1.2).timeout
	assert(dev.vida == 100, "Pular apos o aviso precisa permitir desviar do tiro")
	print("PASSOU: janela de aviso permite desviar pulando.")
	quit()
