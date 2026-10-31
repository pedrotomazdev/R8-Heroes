from pathlib import Path
from PIL import Image
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-5ee99fd8-d569-4012-884b-eaab12569e83.png').convert('RGBA')
edges=[0,530,950,1300,1774]
sheet=Image.new('RGBA',(512,256))
frames=[]
for i in range(8):
    row,col=i//4,i%4
    cell=src.crop((edges[col],round(row*src.height/2),edges[col+1],round((row+1)*src.height/2)))
    box=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(box)
    sp=sp.resize((round(sp.width*0.22),round(sp.height*0.22)),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(128,128))
    f.alpha_composite(sp,((128-sp.width)//2,(128-sp.height)//2))
    sheet.alpha_composite(f,(col*128,row*128))
    frames.append(f)
sheet.save('assets/hotdog-spin-spritesheet.png')
parts=['[gd_scene format=3]', '[ext_resource type="Texture2D" path="res://assets/hotdog-spin-spritesheet.png" id="1"]','[ext_resource type="Script" path="res://hotdog.gd" id="2"]']
for i in range(8):
    parts.append(f'[sub_resource type="AtlasTexture" id="frame{i}"]\natlas = ExtResource("1")\nregion = Rect2({i%4*128}, {i//4*128}, 128, 128)')
frames_text=', '.join('{"duration": 1.0, "texture": SubResource("frame'+str(i)+'")}' for i in range(8))
parts.append('[sub_resource type="SpriteFrames" id="animacao"]\nanimations = [{"frames": ['+frames_text+'], "loop": true, "name": &"spin", "speed": 8.0}]')
parts.extend(['[sub_resource type="RectangleShape2D" id="colisao"]\nsize = Vector2(64, 70)',
'[node name="Hotdog" type="Area2D"]\ncollision_layer = 0\ncollision_mask = 2\nscript = ExtResource("2")',
'[node name="Colisao" type="CollisionShape2D" parent="."]\nshape = SubResource("colisao")',
'[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]\ntexture_filter = 1\nscale = Vector2(0.65, 0.65)\nsprite_frames = SubResource("animacao")\nanimation = &"spin"\nautoplay = "spin"',
'[node name="Texto" type="Label" parent="."]\noffset_left = -52.0\noffset_top = -60.0\ntext = "HOTDOG +40"\ntheme_override_font_sizes/font_size = 16\nmouse_filter = 2'])
Path('hotdog.tscn').write_text('\n\n'.join(parts)+'\n',encoding='utf-8')
Path('assets/hotdog-spin-notas.txt').write_text('image_gen integrada: hotdog de pao dourado, salsicha, mostarda em ziguezague; oito perspectivas de giro, pixel art, fundo transparente. Folha 4x2, quadros 128x128, spin 8 FPS em loop.\n',encoding='utf-8')
print('Packed hotdog sheet and reusable scene.')
