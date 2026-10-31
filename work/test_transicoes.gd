extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	var bug = fase.get_node("Inimigos/Bug1")
	dev.set_physics_process(false)
	for inimigo in fase.get_node("Inimigos").get_children():
		inimigo.set_physics_process(false)
	assert(dev.sprite.sprite_frames.has_animation("air_attack"))
	assert(dev.sprite.sprite_frames.has_animation("hurt"))
	dev.global_position = Vector2(500, 300)
	bug.global_position = Vector2(670, 300)
	dev.atacando = true
	dev.sprite.play("air_attack")
	dev.sprite.frame = 2
	dev.sprite.pause()
	for i in range(6):
		await physics_frame
	assert(bug.vida == 2, "Golpe aereo precisa usar a mesma hitbox e dano")
	dev.receber_dano(20, bug.global_position)
	assert(dev.sprite.animation == "hurt" and not dev.atacando)
	await physics_frame
	assert(dev.colisao_ataque.disabled)
	await create_timer(0.3).timeout
	assert(dev.sprite.animation == "fall", "Dano deve devolver pose de queda no ar")
	dev.atacando = true
	dev.velocity.y = -100
	dev.sprite.play("air_attack")
	await create_timer(0.6).timeout
	assert(not dev.atacando and dev.sprite.animation == "jump")
	print("PASSOU: golpe aereo acerta, dano interrompe, retorno para queda e subida.")
	quit()
