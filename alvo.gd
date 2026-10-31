extends StaticBody2D

@onready var visual: Polygon2D = $Polygon2D
@export var vida: int = 5

var efeito_acerto: Tween


func receber_golpe() -> void:
	vida -= 1
	print("Vida do alvo: ", vida)

	if vida <= 0:
		queue_free()
		return

	if efeito_acerto:
		efeito_acerto.kill()

	visual.modulate = Color(3.0, 3.0, 3.0)

	efeito_acerto = create_tween()
	efeito_acerto.tween_property(
		visual,
		"modulate",
		Color.WHITE,
		0.15
	)
