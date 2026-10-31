from pathlib import Path

lines=['[gd_scene format=3]', '',
'[ext_resource type="Script" path="res://fase01.gd" id="1"]',
'[ext_resource type="PackedScene" path="res://dev.tscn" id="2"]',
'[ext_resource type="PackedScene" path="res://bug.tscn" id="3"]',
'[ext_resource type="PackedScene" path="res://hud.tscn" id="4"]',
'[ext_resource type="PackedScene" path="res://hotdog.tscn" id="5"]',
'[ext_resource type="PackedScene" path="res://bug_atirador.tscn" id="6"]',
'[ext_resource type="Script" path="res://cenario_estacionamento.gd" id="7"]',
'[ext_resource type="AudioStreamWAV" path="res://assets/audio/musica/fase01-remix-provisorio.wav" id="8"]']
resources=[]
nodes=[]
def node(name,typ,parent='.',props=''):
    nodes.append(f'\n[node name="{name}" type="{typ}" parent="{parent}"]\n{props}')
def rect(name,parent,x,y,w,h,color):
    node(name,'Polygon2D',parent,f'position = Vector2({x}, {y})\ncolor = Color("{color}")\npolygon = PackedVector2Array(0, 0, {w}, 0, {w}, {h}, 0, {h})')
def shape(name,parent,w,h):
    ident=f'shape_{len(resources)}'
    resources.append(f'\n[sub_resource type="RectangleShape2D" id="{ident}"]\nsize = Vector2({w}, {h})')
    node(name,'CollisionShape2D',parent,f'shape = SubResource("{ident}")')
def floor(name,x,y,w,h=40):
    node(name,'StaticBody2D','Geometria',f'position = Vector2({x+w/2}, {y+h/2})')
    shape('Colisao','Geometria/'+name,w,h)
    rect('Visual','Geometria/'+name,-w/2,-h/2,w,h,'536b6d')
    rect('Borda','Geometria/'+name,-w/2,-h/2,w,6,'9fae87')
def label(name,parent,x,y,text,size=22):
    node(name,'Label',parent,f'offset_left = {float(x)}\noffset_top = {float(y)}\ntheme_override_font_sizes/font_size = {size}\ntext = "{text}"\nmouse_filter = 2')
def area(name,x,y,w,h):
    node(name,'Area2D','.',f'position = Vector2({x}, {y})\ncollision_layer = 0\ncollision_mask = 1')
    shape('Colisao',name,w,h)

nodes.append('\n[node name="Fase01" type="Node2D"]\nscript = ExtResource("1")')
node('Musica','AudioStreamPlayer','.', 'stream = ExtResource("8")\nvolume_db = -14.0')
node('Cenario','Node2D','.', 'z_index = -100\nscript = ExtResource("7")')
node('Geometria','Node2D')
# Surface is y=560; gaps of 180/220 are below the ~490px jump reach.
floor('Entrada',0,560,1500)
floor('Patio',1680,560,1520)
floor('Agencia',3420,560,1900)
floor('LimiteEsquerdo',-60,-200,60,1100)
floor('LimiteDireito',5320,-200,60,1100)
for name,x,y,w in [('Caixa1',680,465,220),('Caixa2',1050,375,220),('Caixa3',2060,465,220),('Caixa4',2460,375,240),('Caixa5',3750,465,220),('Caixa6',4140,375,220)]:
    floor(name,x,y,w,26)
node('Placas','Node2D')
label('Titulo','Placas',65,300,'R8 / ESTACIONAMENTO ANTIGO',30)
label('Controles','Placas',65,350,'A/D: mover   W/Espaço: pular\nMouse esquerdo: tecladada',20)
label('PrimeiroBug','Placas',480,270,'01 / BUG NO CAMINHO\nAtaque antes de encostar.',22)
label('Saltos','Placas',1190,230,'02 / ENTRE AS VAGAS\nPule os buracos do estacionamento.',22)
label('Patio','Placas',2220,260,'03 / ACÚMULO DE DEMANDAS',24)
label('Final','Placas',4050,240,'04 / ÚLTIMO DEPLOY',26)
rect('Porta','Placas',4960,335,200,225,'273746')
rect('Batente','Placas',4960,335,200,10,'63dfb1')
label('Saida','Placas',4980,370,'AGÊNCIA\nENTRADA',26)

nodes.append('\n[node name="Dev" parent="." instance=ExtResource("2")]\nposition = Vector2(180, 450)\nup_direction = Vector2(0, -1)\nvelocidade = 500.0\nforca_pulo = 480.0')
node('Inimigos','Node2D')
for i,(x,y) in enumerate([(780,500),(1250,500),(2450,500),(2850,500),(3720,500),(4180,500),(4550,500),(4820,500)]):
    tipo='6' if i in (2,5,7) else '3'
    speed=36 if tipo=='6' else 55+i*3
    nodes.append(f'\n[node name="Bug{i+1}" parent="Inimigos" instance=ExtResource("{tipo}")]\nposition = Vector2({x}, {y})\nvida = 3\nvelocidade = {speed}.0')
for i,x in enumerate([1790,3540],1):
    name=f'Checkpoint{i}'
    area(name,x,470,70,180)
    rect('Poste',name,0,-95,5,185,'d5dfcf')
    rect('Bandeira',name,5,-95,65,38,'ffc66d')
    label('Texto',name,-40,-135,'CHECKPOINT',16)
for i,x in enumerate([2350,4050],1):
    name=f'Hotdog{i}'
    nodes.append(f'\n[node name="{name}" parent="." instance=ExtResource("5")]\nposition = Vector2({x}, 515)')
area('Saida',5070,455,150,200)
nodes.append('\n[node name="HUD" parent="." instance=ExtResource("4")]')
node('Interface','CanvasLayer','.', 'layer = 11')
node('FundoObjetivo','ColorRect','Interface','offset_left = 400.0\noffset_top = 14.0\noffset_right = 1264.0\noffset_bottom = 104.0\ncolor = Color(0.025, 0.06, 0.08, 0.76)\nmouse_filter = 2')
label('Objetivo','Interface',410,25,'01 / ESTACIONAMENTO ANTIGO',20)
label('Mensagem','Interface',410,58,'',15)
node('Fim','PanelContainer','Interface','visible = false\nanchors_preset = 8\nanchor_left = 0.5\nanchor_top = 0.5\nanchor_right = 0.5\nanchor_bottom = 0.5\noffset_left = -240.0\noffset_top = -125.0\noffset_right = 240.0\noffset_bottom = 125.0\ngrow_horizontal = 2\ngrow_vertical = 2')
node('Margem','MarginContainer','Interface/Fim','layout_mode = 2\ntheme_override_constants/margin_left = 30\ntheme_override_constants/margin_right = 30\ntheme_override_constants/margin_top = 30\ntheme_override_constants/margin_bottom = 30')
node('Coluna','VBoxContainer','Interface/Fim/Margem','layout_mode = 2\ntheme_override_constants/separation = 18')
node('Titulo','Label','Interface/Fim/Margem/Coluna','layout_mode = 2\ntext = "EXPEDIENTE CONCLUÍDO"\nhorizontal_alignment = 1\ntheme_override_font_sizes/font_size = 28')
node('Descricao','Label','Interface/Fim/Margem/Coluna','layout_mode = 2\ntext = "Estacionamento sem bugs.\nO café ainda está quente."\nhorizontal_alignment = 1')
node('Rejogar','Button','Interface/Fim/Margem/Coluna','layout_mode = 2\ntext = "Jogar novamente"\ncustom_minimum_size = Vector2(0, 45)')
import re
text='\n'.join(lines+resources+nodes)+'\n'
def color_value(match):
    rgb=match.group(1)
    values=[int(rgb[i:i+2],16)/255 for i in (0,2,4)]
    return 'Color('+', '.join(str(v) for v in values)+', 1)'
text=re.sub(r'Color\("([0-9a-f]{6})"\)',color_value,text)
Path('fase01.tscn').write_text(text,encoding='utf-8')
print('Created editable fase01.tscn: 5320px, 8 bugs, 2 checkpoints, 2 hotdogs.')
