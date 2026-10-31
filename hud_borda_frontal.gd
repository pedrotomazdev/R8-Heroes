extends Node2D

# Este nó vem DEPOIS do retrato na árvore: o arco inferior cobre o busto.
# O arco de cima é desenhado antes dele, permitindo que o cabelo passe na frente.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var visual = get_parent()
	var centro := Vector2(67,77)
	draw_arc(centro,60,0,PI,64,Color("284656"),5,true)
	if visual.energia > 0:
		draw_arc(centro,60,0,PI*visual.energia,64,Color("00cfff"),5,true)
	# Filete interno sela a borda entre o retrato e o círculo, sem base reta.
	draw_arc(centro,56,0,PI,64,Color("31576b"),1.5,true)
