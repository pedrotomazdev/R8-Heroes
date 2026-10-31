extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var cena = load("res://fase01.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	var hud = cena.get_node("HUD")
	cena.get_node("Dev").set_physics_process(false)
	for bug in cena.get_node("Inimigos").get_children():
		bug.set_physics_process(false)
	assert(hud.visual.energia == 1.0)
	for i in range(5):
		var nome := StringName("estado_%d" % i)
		assert(hud.retrato.sprite_frames.get_frame_count(nome) == 3)
		assert(hud.retrato.sprite_frames.get_animation_loop(nome))
	for par in [[100,0],[60,1],[40,2],[10,3],[0,4]]:
		hud._atualizar_vida(par[0], 100)
		assert(hud.retrato.animation == StringName("estado_%d" % par[1]))
		hud.retrato.frame = 0
		hud.retrato.frame_progress = 0.0
		# Avança até o quadro de respiração em cada estado, inclusive burnout.
		await create_timer(1.9 if par[1] < 4 else 0.9).timeout
		assert(hud.retrato.frame != 0)
	assert(hud.visual.sanidade == 0)
	assert(hud.visual.energia == 1.0, "Sanidade não deve consumir energia")
	assert(hud.visual.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	print("PASSOU: cinco retratos animados, barra animada, energia independente, HUD sem bloquear mouse.")
	quit()
