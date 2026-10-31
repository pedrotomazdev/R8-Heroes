extends Node2D

var direcao := Vector2.LEFT
var velocidade: float = 300.0
var dano: int = 15
var tempo: float = 0.0

func _ready() -> void:
	add_to_group("projeteis_inimigos")

func _physics_process(delta: float) -> void:
	tempo += delta
	if tempo > 3.0:
		queue_free()
		return
	var destino := global_position + direcao*velocidade*delta
	var espaco := get_world_2d().direct_space_state
	# Máscara 3 = cenário (1) e jogador (2), sem atingir os próprios insetos.
	var consulta := PhysicsRayQueryParameters2D.create(global_position,destino,3)
	var resultado := espaco.intersect_ray(consulta)
	if not resultado.is_empty():
		var corpo = resultado.collider
		if corpo.has_method("receber_dano"):
			corpo.receber_dano(dano,global_position-direcao*20)
		queue_free()
		return
	global_position = destino
	queue_redraw()

func _draw() -> void:
	draw_line(-direcao*22,Vector2.ZERO,Color("d95842"),7)
	draw_rect(Rect2(-6,-6,12,12),Color("ff814e"))
	draw_rect(Rect2(-3,-3,6,6),Color("fff0b0"))
