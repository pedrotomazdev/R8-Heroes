from PIL import Image
from pathlib import Path
import re

base=Path(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6')
def pack(source,edges,anchors,width,scale,bottom,name):
    src=Image.open(base/source).convert('RGBA')
    sheet=Image.new('RGBA',(width*(len(edges)-1),640))
    for i in range(len(edges)-1):
        cell=src.crop((edges[i],110,edges[i+1],650))
        b=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
        sprite=cell.crop(b)
        sprite=sprite.resize((round(sprite.width*scale),round(sprite.height*scale)),Image.Resampling.NEAREST)
        frame=Image.new('RGBA',(width,640))
        frame.alpha_composite(sprite,(round(width/2-(anchors[i]-edges[i]-b[0])*scale),bottom-sprite.height))
        sheet.alpha_composite(frame,(i*width,0))
    sheet.save(Path('assets/dev/combate')/name)

pack('exec-0fcb383b-b083-450e-ad46-f3f249f1886c.png',[0,360,715,1030,1595,1900,2172],[180,530,875,1170,1700,2040],1792,1.6,560,'dev-air-attack-spritesheet.png')
pack('exec-d10c0a3c-5946-4377-a0b1-434a9fd12448.png',[0,543,1086,1629,2172],[334,860,1344,1920],640,1.12,612,'dev-hurt-spritesheet.png')

# Acrescenta recursos à cena existente, mantendo as outras animações intactas.
path=Path('dev.tscn')
text=path.read_text(encoding='utf-8')
extras=[]
animations=[]
for name,count,width,file,speed in [('air_attack',6,1792,'dev-air-attack-spritesheet.png',12),('hurt',4,640,'dev-hurt-spritesheet.png',20)]:
    text=text.replace('[sub_resource',f'[ext_resource type="Texture2D" path="res://assets/dev/combate/{file}" id="tex_{name}"]\n\n[sub_resource',1)
    frames=[]
    for i in range(count):
        ident=f'Atlas_{name}_{i}'
        extras.append(f'[sub_resource type="AtlasTexture" id="{ident}"]\natlas = ExtResource("tex_{name}")\nregion = Rect2({i*width}, 0, {width}, 640)\n')
        frames.append('{"duration": 1.0, "texture": SubResource("'+ident+'")}')
    animations.append('{"frames": ['+', '.join(frames)+'], "loop": false, "name": &"'+name+'", "speed": '+str(float(speed))+'}')
text=text.replace('[sub_resource type="SpriteFrames"', '\n'.join(extras)+'\n[sub_resource type="SpriteFrames"',1)
text=text.replace('animations = [','animations = ['+', '.join(animations)+', ',1)
path.write_text(text,encoding='utf-8')
Path('assets/dev/combate/dev-transicoes-notas.txt').write_text('Geracao: image_gen integrada, referencias do dev existente. Prompts: ataque aereo de seis quadros com pernas recolhidas, teclado e corte digital ciano, cafe na outra mao; reacao de dano de quatro quadros com susto, recuo e recuperacao, mantendo identidade e roupas. Fundos transparentes. air_attack: 1792x640 por quadro, 12 FPS; hurt: 640x640 por quadro, 20 FPS; sem loop.\n',encoding='utf-8')
print('Packed and linked air_attack and hurt.')
