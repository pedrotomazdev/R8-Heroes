extends Node2D

# Janela invocada é um efeito visual separado do dano do projétil.
var tempo: float = 0.0
var emissor: Node2D
var deslocamento: Vector2 = Vector2.ZERO
var fonte: Font = preload("res://assets/fonts/DepartureMono-Regular.otf")

func _process(delta: float) -> void:
	tempo += delta
	if is_instance_valid(emissor):
		global_position = emissor.global_position + deslocamento
	scale = Vector2.ONE * minf(tempo / 0.10, 1.0)
	modulate.a = clampf((0.65-tempo)/0.15,0.0,1.0)
	if tempo >= 0.65:
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-85,-38,170,76),Color(0.02,0.06,0.10,0.95))
	draw_rect(Rect2(-85,-38,170,76),Color("44dbfa"),false,2)
	draw_line(Vector2(-85,-20),Vector2(85,-20),Color("286979"),1)
	for i in range(3):
		draw_circle(Vector2(-74+i*10,-29),2,Color("8defa5"))
	var comando := "> deploy --force"
	var caracteres := mini(int(tempo*80),comando.length())
	draw_string(fonte,Vector2(-75,1),comando.left(caracteres),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("8defa5"))
	if tempo > 0.24:
		draw_string(fonte,Vector2(-75,22),"[ EXECUTADO ]",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("44dbfa"))
