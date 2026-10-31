extends Area2D

# Só o desenho flutua. A área de coleta permanece estável e fácil de alcançar.
var tempo: float = 0.0

func _process(delta: float) -> void:
	if not visible:
		return
	tempo += delta
	$AnimatedSprite2D.position.y = sin(tempo * 3.0) * 4.0
