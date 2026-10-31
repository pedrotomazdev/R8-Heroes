from PIL import Image
from pathlib import Path
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-41196a13-6f77-4def-8cac-fa33088c731e.png').convert('RGBA')
sheet=Image.new('RGBA',(768,1280))
for row in range(5):
    for col in range(3):
        cell=src.crop((round(col*src.width/3),round(row*src.height/5),round((col+1)*src.width/3),round((row+1)*src.height/5)))
        box=cell.getchannel('A').point(lambda a:255 if a>=244 else 0).getbbox()
        sp=cell.crop(box)
        sp.thumbnail((240,240),Image.Resampling.NEAREST)
        f=Image.new('RGBA',(256,256)); f.alpha_composite(sp,((256-sp.width)//2,248-sp.height))
        sheet.alpha_composite(f,(col*256,row*256))
sheet.save('assets/dev/esbocos/dev-sanity-animated.png')
Path('assets/dev/retratos/dev-sanity-animated-notas.txt').write_text('image_gen integrada: retratos 3x5, cinco estados de sanidade com pose base, inspiracao e piscada. Quadros 256x256. Shader de recorte remove transparencia residual da geracao em runtime.\n',encoding='utf-8')
