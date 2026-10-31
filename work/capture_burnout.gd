extends SceneTree
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	var cena = load("res://fase01.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	await create_timer(0.3).timeout
	cena.get_node("Dev").receber_dano(100,Vector2.ZERO)
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://work/burnout-preview.png")
	quit()
