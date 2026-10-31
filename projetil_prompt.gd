extends Node2D

@export var velocidade: float = 1100.0
@export var alcance: float = 1000.0
var direcao: float = 1.0
var percorrido: float = 0.0
var tempo: float = 0.0
var alvos_acertados: Array[int] = []
const FOLHA: Texture2D = preload("res://assets/dev/habilidades/prompt-code-burst.png")

func _ready() -> void:
	# A arte fica separada da consulta de dano; mudar o visual não muda o alcance.
	var visual := AnimatedSprite2D.new()
	var quadros := SpriteFrames.new()
	quadros.remove_animation("default")
	quadros.add_animation("voo")
	quadros.set_animation_speed("voo",16.0)
	for i in range(4):
		var textura := AtlasTexture.new()
		textura.atlas = FOLHA
		textura.region = Rect2(i*320,0,320,192)
		quadros.add_frame("voo",textura)
	visual.sprite_frames = quadros
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.scale = Vector2(0.5,0.5)
	visual.position.x = -direcao*40
	visual.flip_h = direcao < 0
	add_child(visual)
	visual.play("voo")

func _physics_process(delta: float) -> void:
	tempo += delta
	var deslocamento := minf(velocidade*delta,alcance-percorrido)
	var proxima := global_position + Vector2(direcao*deslocamento,0)
	# Consulta o caminho inteiro do frame: não atravessa alvos por estar rápido.
	var espaco := get_world_2d().direct_space_state
	var parede := espaco.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,proxima,1))
	if not parede.is_empty():
		proxima = parede.position
	var forma := RectangleShape2D.new()
	forma.size = Vector2(absf(proxima.x-global_position.x)+1,90)
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0,(global_position+proxima)/2)
	consulta.collision_mask = 4
	for resultado in espaco.intersect_shape(consulta,32):
		var corpo = resultado.collider
		var id: int = corpo.get_instance_id()
		if corpo.has_method("receber_golpe") and id not in alvos_acertados:
			alvos_acertados.append(id)
			corpo.receber_golpe()
	global_position = proxima
	percorrido += deslocamento
	if not parede.is_empty() or percorrido >= alcance:
		queue_free()
	queue_redraw()

