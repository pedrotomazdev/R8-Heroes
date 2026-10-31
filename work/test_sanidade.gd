extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var dev = fase.get_node("Dev")
	var hud = fase.get_node("HUD")
	for par in [[100,0],[61,0],[60,1],[41,1],[40,2],[11,2],[10,3],[1,3],[0,4]]:
		hud._atualizar_vida(par[0],100)
		assert(hud.indice_estado == par[1])
		assert(hud.sanidade_atual == par[0])
	assert(hud.estado_atual == "BURNOUT!")
	hud._atualizar_vida(100,100)
	assert(hud.estado_atual == "TUDO OK")
	# Dano real e recuperação devem atualizar a mesma barra e expressão.
	dev.receber_dano(60,Vector2.ZERO)
	assert(hud.estado_atual == "ESGOTADO")
	fase._pegar_hotdog(dev,fase.get_node("Hotdog1"))
	assert(dev.vida == 80 and hud.estado_atual == "TUDO OK")
	dev.invulnerabilidade_restante = 0
	dev.receber_dano(100,Vector2.ZERO)
	assert(hud.estado_atual == "BURNOUT!")
	await create_timer(dev.duracao_burnout + 0.2).timeout
	assert(hud.estado_atual == "TUDO OK" and hud.sanidade_atual == 100)
	print("PASSOU: todos os limiares, retratos, hotdog, burnout e recuperacao.")
	quit()


