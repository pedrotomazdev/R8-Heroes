extends SceneTree
func _initialize() -> void:
	var visual = load("res://hud_visual.gd").new()
	for largura in [330.0,280.0]:
		assert(visual._preenchimento(49,largura,20,0).is_empty())
		var cheio = visual._preenchimento(49,largura,20,1)
		var max_x: float = -INF
		for ponto in cheio:
			max_x = maxf(max_x,ponto.x)
		assert(is_equal_approx(max_x,117+largura+20))
		var metade = visual._preenchimento(49,largura,20,0.5)
		for ponto in metade:
			assert(ponto.x <= lerpf(113,117+largura+20,0.5)+0.01)
	visual.free()
	print("PASSOU: 0%, 50% e 100% nas duas barras; preenchimento inclui ponta angular.")
	quit()
