extends SceneTree

func _initialize() -> void:
	call_deferred("capturar")

func capturar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	for i in range(40):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://work/fase01-preview.png")
	quit()
