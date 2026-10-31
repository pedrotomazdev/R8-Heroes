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
	Input.action_press("mover_direita")
	Input.action_press("atacar")
	for i in range(2):
		await physics_frame
	Input.action_release("atacar")
	assert(dev.sprite.animation == "run_attack" and dev.atacando)
	dev.sprite.set_frame_and_progress(2, 0.2)
	Input.action_release("mover_direita")
	for i in range(2):
		await physics_frame
	assert(dev.sprite.animation == "attack" and dev.sprite.frame == 2)
	Input.action_press("pular")
	for i in range(2):
		await physics_frame
	Input.action_release("pular")
	assert(dev.sprite.animation == "air_attack" and dev.sprite.frame >= 2)
	await create_timer(0.6).timeout
	assert(not dev.atacando)
	print("PASSOU: corrida com ataque, parada e pulo sem reiniciar golpe; recuperacao.")
	quit()
