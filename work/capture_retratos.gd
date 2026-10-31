extends SceneTree
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	var cena = load("res://fase01.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	cena.get_node("Dev").set_physics_process(false)
	for bug in cena.get_node("Inimigos").get_children():
		bug.set_physics_process(false)
	var hud = cena.get_node("HUD")
	for valor in [100,60,40,10,0]:
		hud._atualizar_vida(valor,100)
		await create_timer(0.2).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().get_region(Rect2i(0,0,490,165)).save_png("res://work/hud-%d.png" % valor)
	quit()
