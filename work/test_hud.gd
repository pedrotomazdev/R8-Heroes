extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var cena = load("res://estacionamento.tscn").instantiate()
	root.add_child(cena)
	current_scene = cena
	var dev = cena.get_node("Dev")
	var hud = cena.get_node("HUD")
	assert(hud.sanidade_atual == 100)
	dev.receber_dano(20, Vector2.ZERO)
	assert(hud.sanidade_atual == 80)
	dev.receber_dano(20, Vector2.ZERO)
	assert(hud.sanidade_atual == 80)
	dev.invulnerabilidade_restante = 0
	dev.receber_dano(60, Vector2.ZERO)
	assert(hud.sanidade_atual == 20 and hud.indice_estado == 2)
	dev.invulnerabilidade_restante = 0
	dev.receber_dano(20, Vector2.ZERO)
	assert(hud.sanidade_atual == 0)
	await create_timer(dev.duracao_burnout + 0.2).timeout
	assert(current_scene.get_node("HUD").sanidade_atual == 100)
	print("PASSOU: HUD inicial, dano, invulnerabilidade, cor critica, morte e reinicio.")
	quit()



