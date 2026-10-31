from pathlib import Path
from PIL import Image
import re
root=Path('.')
bg=Path('assets/cenarios/estacionamento'); bg.mkdir(parents=True,exist_ok=True)
enemy=Path('assets/inimigos/atirador'); enemy.mkdir(parents=True,exist_ok=True)
generated=Path(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6')
Image.open(generated/'exec-d957799d-ef89-4608-8c81-c469b1001251.png').save(bg/'casa-azul-mangueira.png')
Image.open(generated/'exec-11b185d9-7fdd-4681-9880-f9d855edad7d.png').save(bg/'muro-brita-atlas.png')
src=Image.open(generated/'exec-7ebf24b7-6cde-42c3-8a81-4ec0593036c2.png').convert('RGBA')
sheet=Image.new('RGBA',(2048,1024))
for i in range(8):
    row,col=i//4,i%4
    left,right=round(col*src.width/4),round((col+1)*src.width/4)
    top,bottom=round(row*src.height/2),round((row+1)*src.height/2)
    cell=src.crop((left,top,right,bottom))
    box=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(box); scale=0.88
    sp=sp.resize((round(sp.width*scale),round(sp.height*scale)),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(512,512))
    f.alpha_composite(sp,(round(256-(235-box[0])*scale),470-sp.height))
    sheet.alpha_composite(f,(col*512,row*512))
sheet.save(enemy/'bug-atirador-spritesheet.png')
s=Path('bug.tscn').read_text(encoding='utf-8')
s=s.replace(' uid="uid://d03v00dtd1kmi"','')
s=re.sub(r'\[ext_resource type="Script"[^\n]*id="1_hs7dx"\]', '[ext_resource type="Script" path="res://bug_atirador.gd" id="1_hs7dx"]',s)
s=re.sub(r'\[ext_resource type="Texture2D"[^\n]*id="2_q3ryj"\]', '[ext_resource type="Texture2D" path="res://assets/inimigos/atirador/bug-atirador-spritesheet.png" id="2_q3ryj"]',s)
resources=[]; frames=[]
for i in range(4):
    resources.append(f'[sub_resource type="AtlasTexture" id="tiro_{i}"]\natlas = ExtResource("2_q3ryj")\nregion = Rect2({i*512},512,512,512)')
    frames.append('{"duration": 1.0, "texture": SubResource("tiro_'+str(i)+'")}')
s=s.replace('[sub_resource type="SpriteFrames"','\n\n'.join(resources)+'\n\n[sub_resource type="SpriteFrames"',1)
s=s.replace('animations = [','animations = [{"frames": ['+', '.join(frames)+'], "loop": false, "name": &"shoot", "speed": 8.0}, ',1)
s=s.replace('position = Vector2(0, 9)','position = Vector2(0, -7)').replace('scale = Vector2(0.1796875, 0.1911164)','scale = Vector2(0.25, 0.25)')
Path('bug_atirador.tscn').write_text(s,encoding='utf-8')
(bg/'notas.txt').write_text('image_gen integrada: casa antiga azul com telhas de barro e mangueira grande, fundo lateral em pixel art; atlas de muro branco envelhecido e brita. Composicao baseada na descricao do estacionamento real, sem mureta.\n',encoding='utf-8')
(enemy/'notas.txt').write_text('image_gen integrada: besouro de circuito laranja/bordo com focinho-canhao, quatro poses de caminhada e quatro poses de carga/disparo, pixel art transparente. Quadros 512x512, grade 4x2.\n',encoding='utf-8')
print('Cenario e bug atirador preparados.')
