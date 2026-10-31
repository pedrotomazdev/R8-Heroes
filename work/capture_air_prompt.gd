extends SceneTree
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	for i in range(40):
		await physics_frame
	Input.action_press("pular")
	for i in range(3):
		await physics_frame
	Input.action_release("pular")
	dev._tentar_prompt()
	await create_timer(0.27).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://work/air-prompt-preview.png")
	quit()
