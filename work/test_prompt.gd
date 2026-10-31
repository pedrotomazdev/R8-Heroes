extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	var hud = fase.get_node("HUD")
	var bugs = fase.get_node("Inimigos").get_children()
	for i in range(bugs.size()):
		bugs[i].set_physics_process(false)
		bugs[i].global_position = Vector2(600+i*150,514)
	for i in range(40):
		await physics_frame
	assert(dev.is_on_floor())
	assert(InputMap.action_get_events("prompt")[0].button_index == MOUSE_BUTTON_RIGHT)
	Input.action_press("prompt")
	for i in range(2):
		await physics_frame
	Input.action_release("prompt")
	assert(dev.conjurando_prompt and dev.energia == 75)
	assert(is_equal_approx(hud.visual.energia,0.75))
	assert(not dev._tentar_prompt(), "Nao pode conjurar duas vezes ao mesmo tempo")
	await create_timer(1.0).timeout
	assert(not dev.conjurando_prompt)
	for i in range(3):
		assert(bugs[i].vida == 2, "Projetil deve atravessar alvos e causar um dano em cada")
	await create_timer(0.4).timeout
	assert(dev.energia > 75 and dev.energia <= 100)
	dev.energia = 24
	dev.recarga_prompt = 0
	assert(not dev._tentar_prompt(), "Energia insuficiente nao pode disparar")
	dev.energia = 100
	assert(dev._tentar_prompt())
	dev.receber_dano(20,Vector2.ZERO)
	assert(not dev.conjurando_prompt and not dev.atacando)
	await create_timer(0.6).timeout
	dev.restaurar_no_checkpoint(Vector2(180,450))
	assert(dev.energia == 100 and is_equal_approx(hud.visual.energia,1.0))
	print("PASSOU: clique direito, custo, bloqueio, disparo perfurante, regeneracao, interrupcao e energia no HUD.")
	quit()
