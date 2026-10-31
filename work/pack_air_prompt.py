from PIL import Image
from pathlib import Path
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-0c96ba83-aa6f-4379-85da-8d019ac0b806.png').convert('RGBA')
edges=[0,395,760,1110,1480,1870,2172]
anchors=[190,540,920,1250,1625,2020]
sheet=Image.new('RGBA',(4608,640))
for i in range(6):
    cell=src.crop((edges[i],135,edges[i+1],590))
    b=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(b); scale=1.45
    sp=sp.resize((round(sp.width*scale),round(sp.height*scale)),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(768,640))
    f.alpha_composite(sp,(round(384-(anchors[i]-edges[i]-b[0])*scale),560-sp.height))
    sheet.alpha_composite(f,(i*768,0))
sheet.save('assets/dev/habilidades/dev-air-prompt-spritesheet.png')
p=Path('dev.tscn'); s=p.read_text(encoding='utf-8')
s=s.replace('[sub_resource','[ext_resource type="Texture2D" path="res://assets/dev/habilidades/dev-air-prompt-spritesheet.png" id="tex_air_prompt"]\n\n[sub_resource',1)
resources=[]; frames=[]
for i in range(6):
    resources.append(f'[sub_resource type="AtlasTexture" id="air_prompt_{i}"]\natlas = ExtResource("tex_air_prompt")\nregion = Rect2({i*768}, 0, 768, 640)')
    frames.append('{"duration": 1.0, "texture": SubResource("air_prompt_'+str(i)+'")}')
s=s.replace('[sub_resource type="SpriteFrames"','\n\n'.join(resources)+'\n\n[sub_resource type="SpriteFrames"',1)
s=s.replace('animations = [','animations = [{"frames": ['+', '.join(frames)+'], "loop": false, "name": &"air_prompt", "speed": 12.0}, ',1)
p.write_text(s,encoding='utf-8')
Path('assets/dev/habilidades/dev-air-prompt-notas.txt').write_text('image_gen integrada: versao aerea da digitacao do dev, joelhos dobrados e pernas equilibrando o salto, teclado flutuante, cafe preservado, confirmacao de comando e recuperacao no ar. Seis quadros 768x640, 12 FPS, sem loop.\n',encoding='utf-8')
