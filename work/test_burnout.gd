extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var cena = load("res://fase01.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	var dev = cena.get_node("Dev")
	var hud = cena.get_node("HUD")
	assert(hud.visual.scale == Vector2(0.78,0.78))
	assert(not hud.tela_burnout.visible)
	dev.receber_dano(100,Vector2.ZERO)
	assert(hud.tela_burnout.visible and dev.morto)
	var titulo: Label = hud.get_node("TelaBurnout/Conteudo/Faixa/Titulo")
	assert(titulo.text == "¡BURNOUT!")
	assert(titulo.get_theme_font("font").resource_path.ends_with("DepartureMono-Regular.otf"))
	await create_timer(dev.duracao_burnout + 0.2).timeout
	assert(not hud.tela_burnout.visible and not dev.morto)
	assert(dev.vida == dev.vida_maxima)
	print("PASSOU: HUD reduzido, fonte local, tela de burnout e retorno ao checkpoint.")
	quit()
