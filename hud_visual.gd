extends Control

# Sanidade funcional e energia visual, independentes da câmera e dos cliques.
var sanidade: float = 1.0
var cauda: float = 1.0
var energia: float = 1.0
var cor_sanidade := Color("8defa5")
var critico: bool = false
var tempo: float = 0.0

func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()

func _preenchimento(y: float, largura: float, altura: float, percentual: float) -> PackedVector2Array:
	# Recorta o mesmo formato angular pela porcentagem, incluindo a ponta no 100%.
	var x := 117.0
	var base := PackedVector2Array([Vector2(x-4,y-1),Vector2(x+largura+12,y-1),Vector2(x+largura+20,y+altura/2),Vector2(x+largura+12,y+altura+1),Vector2(x-4,y+altura+1)])
	var limite := lerpf(x-4,x+largura+20,clampf(percentual,0.0,1.0))
	var resultado := PackedVector2Array()
	if percentual <= 0.0:
		return resultado
	for i in range(base.size()):
		var a := base[i]
		var b := base[(i+1)%base.size()]
		if a.x <= limite:
			resultado.append(a)
		if (a.x <= limite) != (b.x <= limite):
			resultado.append(a.lerp(b,(limite-a.x)/(b.x-a.x)))
	return resultado

func _trilho(y: float, largura: float, altura: float, valor: float, cor: Color, rastro: float = 0.0) -> void:
	var x := 117.0
	var casco := PackedVector2Array([Vector2(x-8,y-5),Vector2(x+largura+14,y-5),Vector2(x+largura+24,y+altura/2),Vector2(x+largura+14,y+altura+5),Vector2(x-8,y+altura+5)])
	draw_colored_polygon(casco, Color("08131e"))
	draw_polyline(PackedVector2Array([casco[4],casco[0],casco[1],casco[2],casco[3],casco[4]]), Color("3287a2"), 2, true)
	draw_colored_polygon(_preenchimento(y,largura,altura,1.0), Color("1c2a3d"))
	if rastro > valor:
		draw_colored_polygon(_preenchimento(y,largura,altura,rastro), Color("ea7795"))
	if valor > 0:
		draw_colored_polygon(_preenchimento(y,largura,altura,valor),cor)
		var fim := lerpf(x-4,x+largura+20,clampf(valor,0.0,1.0))
		draw_line(Vector2(x-3,y+1),Vector2(minf(fim,x+largura+12),y+1),cor.lightened(0.45),2)
		# O marcador branco só aparece no corte parcial, nunca como fim falso no 100%.
		if valor < 0.999:
			var meio := y+altura/2
			var meia_altura := altura/2
			if fim > x+largura+12:
				meia_altura *= (x+largura+20-fim)/8.0
			draw_line(Vector2(fim,meio-meia_altura),Vector2(fim,meio+meia_altura),Color.WHITE,1)
	for i in range(1,10):
		var px := x + largura * float(i) / 10.0
		draw_line(Vector2(px,y+altura-4),Vector2(px,y+altura),Color(0.05,0.09,0.15,0.5),1)

func _draw() -> void:
	# Retrato filho sobrepõe a borda superior: cabelo pode sair do círculo.
	var centro := Vector2(67,77)
	# Barras primeiro, depois fundo circular, retrato e borda frontal.
	_trilho(49,330,20,sanidade,cor_sanidade,cauda)
	_trilho(91,280,12,energia,Color("00cfff"))
	draw_circle(centro+Vector2(0,4),64,Color(0.01,0.025,0.05,0.65))
	# Discos concêntricos dão profundidade ao fundo sem uma textura externa.
	draw_circle(centro,56,Color("0a1623"))
	for i in range(8):
		draw_circle(centro+Vector2(-8,-8),float(48-i*5),Color("36576c").lerp(Color("0a1623"),float(8-i)/8.0))
	draw_arc(centro,56,0,TAU,96,Color("31576b"),2,true)
	draw_arc(centro,60,PI,TAU,64,Color("284656"),5,true)
	var intensidade: float = 0.6 + sin(tempo*6)*0.3 if critico else 1.0
	var borda := cor_sanidade
	borda.a = intensidade
	if sanidade > 0:
		draw_arc(centro,60,PI,PI+PI*sanidade,64,borda,5,true)
