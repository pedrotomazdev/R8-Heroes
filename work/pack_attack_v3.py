from PIL import Image
from pathlib import Path
p=Path('assets')
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-2166c132-2a24-423f-a366-7ef26d9c9b7b.png').convert('RGBA')
edges=[0,345,680,1000,1605,1900,2172]
anchors=[180,523,862,1145,1697,2015]
frames=[]
for i in range(6):
    cell=src.crop((edges[i],150,edges[i+1],550))
    b=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(b)
    scale=1.75
    sp=sp.resize((round(sp.width*scale),round(sp.height*scale)),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(1792,640))
    f.alpha_composite(sp,(round(896-(anchors[i]-edges[i]-b[0])*scale),612-sp.height))
    frames.append(f)
sheet=Image.new('RGBA',(10752,640))
for i,f in enumerate(frames): sheet.alpha_composite(f,(i*1792,0))
sheet.save(p/'dev-attack-keyboard-v3-spritesheet.png')
# Keep existing animation resources and swap only their atlas/regions.
scene=Path('dev.tscn').read_text(encoding='utf-8')
import re
scene=re.sub(r'\[ext_resource type="Texture2D"[^\n]*id="2_gamoy"\]', '[ext_resource type="Texture2D" path="res://assets/dev-attack-keyboard-v3-spritesheet.png" id="2_gamoy"]',scene)
for i in range(6):
    scene=scene.replace(f'region = Rect2({i*640}, 0, 640, 640)',f'region = Rect2({i*1792}, 0, 1792, 640)')
Path('dev.tscn').write_text(scene,encoding='utf-8')
Path('assets/dev-attack-keyboard-v3-notas.txt').write_text('image_gen integrada: reforcar tecladada preservando dev e cafe; antecipacao, arco ciano, impacto digital longo e recuperacao; seis quadros, fundo transparente. Folha empacotada 6x1, quadros 1792x640 para comportar alcance magico. Escala do sprite mantida.\n',encoding='utf-8')
print('Packed attack v3 and linked existing attack animation.')
