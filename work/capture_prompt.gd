extends SceneTree
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	for i in range(45):
		await physics_frame
	dev._tentar_prompt()
	await create_timer(0.32).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://work/prompt-preview.png")
	quit()
