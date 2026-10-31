extends Node2D

# Brita e muro pertencem ao mundo. A casa/mangueira se desloca mais devagar,
# seguindo só parte do movimento da câmera para produzir a paralaxe.
@export_range(0.0,1.0) var paralaxe_casa: float = 0.28
const CASA = preload("res://assets/cenarios/estacionamento/casa-azul-mangueira.png")
const MATERIAIS = preload("res://assets/cenarios/estacionamento/muro-brita-atlas.png")
var muro: AtlasTexture
var brita: AtlasTexture
var camera_x: float = 640.0
var fonte: Font = preload("res://assets/fonts/DepartureMono-Regular.otf")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	muro = AtlasTexture.new()
	muro.atlas = MATERIAIS
	muro.region = Rect2(0,0,MATERIAIS.get_width(),MATERIAIS.get_height()/2)
	brita = AtlasTexture.new()
	brita.atlas = MATERIAIS
	brita.region = Rect2(0,MATERIAIS.get_height()/2,MATERIAIS.get_width(),MATERIAIS.get_height()/2)
	# Mantém colisões editáveis na cena, substituindo só os retângulos visuais.
	for corpo in get_parent().get_node("Geometria").get_children():
		corpo.get_node("Visual").hide()
		corpo.get_node("Borda").hide()
	for placa in get_parent().get_node("Placas").get_children():
		if placa is Label and placa.name != "Saida":
			placa.hide()

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera:
		camera_x = camera.get_screen_center_position().x
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(muro):
		return
	draw_rect(Rect2(-1000,-900,7400,1900),Color("28343a"))
	var deslocamento := camera_x*(1.0-paralaxe_casa)-700.0
	for i in range(-2,5):
		draw_texture_rect(CASA,Rect2(i*1800+deslocamento,-80,1800,600),false,Color(0.85,0.87,0.85))
	# Muro branco é a referência estável próxima ao caminho.
	for x in range(-1024,6400,1024):
		draw_texture_rect(muro,Rect2(x,340,1024,220),false,Color(0.84,0.86,0.84))
	draw_rect(Rect2(-600,333,6600,7),Color("dad7c4"))
	draw_rect(Rect2(-600,340,6600,4),Color("989d8b"))
	# O único buraco do vizinho é cenário por enquanto, sem bloquear o jogador.
	var buraco := PackedVector2Array([Vector2(1095,560),Vector2(1093,524),Vector2(1107,524),Vector2(1107,506),Vector2(1131,496),Vector2(1169,502),Vector2(1186,520),Vector2(1192,560)])
	draw_colored_polygon(buraco,Color("354136"))
	draw_polyline(buraco,Color("aa9b7e"),6)
	draw_rect(Rect2(1102,542,75,18),Color("26352f"))
	# Fundo das valas contrasta com as bordas claras da brita.
	draw_rect(Rect2(-600,560,6600,500),Color("17252b"))
	for corpo in get_parent().get_node("Geometria").get_children():
		if corpo.name.begins_with("Limite"):
			continue
		var tamanho: Vector2 = corpo.get_node("Colisao").shape.size
		var canto: Vector2 = corpo.position-tamanho/2
		if corpo.name.begins_with("Caixa"):
			_plataforma(canto,tamanho)
		else:
			var terreno := Rect2(canto,Vector2(tamanho.x,400))
			draw_texture_rect(brita,terreno,true,Color(0.74,0.76,0.73))
			draw_rect(Rect2(canto,Vector2(tamanho.x,7)),Color("c2bba0"))
			draw_line(canto+Vector2(0,8),canto+Vector2(tamanho.x,8),Color("66745e"),3)
			# Sinaliza as extremidades dos buracos antes do salto.
			for borda in [canto.x,canto.x+tamanho.x-44]:
				for k in range(4):
					draw_rect(Rect2(borda+k*11,canto.y+10,7,12),Color("e2b86a"))
	_placa(Vector2(58,246),Vector2(455,82),"ESTACIONAMENTO ANTIGO","A/D MOVER   W/ESPAÇO PULAR")
	_placa(Vector2(1840,248),Vector2(440,82),"BUG LARANJA = ATIRADOR","AVISOU? PULE OU INTERROMPA!")
	_placa(Vector2(4310,235),Vector2(480,82),"ÚLTIMO DEPLOY","LIMPE OS BUGS E ENTRE NA AGÊNCIA")

func _plataforma(canto: Vector2,tamanho: Vector2) -> void:
	draw_rect(Rect2(canto+Vector2(3,5),tamanho),Color(0,0,0,0.25))
	draw_rect(Rect2(canto,tamanho),Color("263f4b"))
	draw_rect(Rect2(canto,Vector2(tamanho.x,6)),Color("d7b767"))
	draw_line(canto+Vector2(0,tamanho.y),canto+tamanho,Color("637b7f"),3)
	for x in range(8,int(tamanho.x)-6,28):
		draw_rect(Rect2(canto+Vector2(x,11),Vector2(13,4)),Color("50636a"))

func _placa(posicao: Vector2,tamanho: Vector2,titulo: String,subtitulo: String) -> void:
	draw_rect(Rect2(posicao+Vector2(4,5),tamanho),Color(0,0,0,0.25))
	draw_rect(Rect2(posicao,tamanho),Color("1a3038"))
	draw_rect(Rect2(posicao,tamanho),Color("7c9487"),false,2)
	draw_string(fonte,posicao+Vector2(16,30),titulo,HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("f2deaa"))
	draw_string(fonte,posicao+Vector2(16,59),subtitulo,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("b7cabb"))
