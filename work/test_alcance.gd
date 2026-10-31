extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var cena = load("res://estacionamento.tscn").instantiate()
	root.add_child(cena)
	var dev = cena.get_node("Dev")
	var bug = cena.get_node("Alvo")
	dev.set_physics_process(false)
	bug.set_physics_process(false)
	bug.global_position = Vector2(600, 300)
	for lado in [1.0, -1.0]:
		dev.global_position = Vector2(600 - 170 * lado, 300)
		dev.hitbox_ataque.position.x = 110 * lado
		dev.atacando = true
		dev.alvos_acertados.clear()
		dev.sprite.play("attack")
		dev.sprite.frame = 2
		dev.sprite.pause()
		var vida_antes = bug.vida
		for i in range(5):
			await physics_frame
		assert(bug.vida == vida_antes - 1, "Ataque deve acertar a 170 pixels, uma vez")
		assert(bug.atordoamento_restante > 0)
		dev.atacando = false
		dev.sprite.play("idle")
		for i in range(3):
			await physics_frame
	print("PASSOU: alcance de 170 pixels nos dois sentidos, um dano por golpe e atordoamento.")
	quit()
