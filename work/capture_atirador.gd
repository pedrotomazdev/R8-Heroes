extends SceneTree
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	dev.position = Vector2(2305,450)
	dev.get_node("Camera2D").reset_smoothing()
	await create_timer(1.1).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://work/atirador-preview.png")
	quit()
