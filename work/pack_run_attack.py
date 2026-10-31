from PIL import Image
from pathlib import Path
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-73ec5f71-f7e2-4348-8f94-9c69322044a6.png').convert('RGBA')
edges=[0,365,715,1060,1520,1840,2172]
anchors=[180,550,900,1220,1670,2030]
sheet=Image.new('RGBA',(10752,640))
for i in range(6):
    cell=src.crop((edges[i],130,edges[i+1],620))
    b=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(b)
    scale=1.55
    sp=sp.resize((round(sp.width*scale),round(sp.height*scale)),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(1792,640))
    f.alpha_composite(sp,(round(896-(anchors[i]-edges[i]-b[0])*scale),612-sp.height))
    sheet.alpha_composite(f,(i*1792,0))
sheet.save('assets/dev/combate/dev-run-attack-spritesheet.png')
p=Path('dev.tscn'); text=p.read_text(encoding='utf-8')
text=text.replace('[sub_resource','[ext_resource type="Texture2D" path="res://assets/dev/combate/dev-run-attack-spritesheet.png" id="tex_run_attack"]\n\n[sub_resource',1)
resources=[]; frames=[]
for i in range(6):
    resources.append(f'[sub_resource type="AtlasTexture" id="run_attack_{i}"]\natlas = ExtResource("tex_run_attack")\nregion = Rect2({i*1792}, 0, 1792, 640)')
    frames.append('{"duration": 1.0, "texture": SubResource("run_attack_'+str(i)+'")}')
text=text.replace('[sub_resource type="SpriteFrames"','\n\n'.join(resources)+'\n\n[sub_resource type="SpriteFrames"',1)
animation='{"frames": ['+', '.join(frames)+'], "loop": false, "name": &"run_attack", "speed": 12.0}, '
text=text.replace('animations = [','animations = ['+animation,1)
p.write_text(text,encoding='utf-8')
Path('assets/dev/combate/dev-run-attack-notas.txt').write_text('image_gen integrada. Prompt: seis quadros do mesmo dev correndo e golpeando com teclado, pernas alternando passadas, cafe na outra mao, corte digital ciano, fundo transparente. Folha: 6x1, quadros 1792x640; run_attack, 12 FPS, sem loop.\n',encoding='utf-8')
print('Created and linked run_attack.')
