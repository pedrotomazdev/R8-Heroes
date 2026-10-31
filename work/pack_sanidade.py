from PIL import Image
from pathlib import Path
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-a28364fd-57e7-4c13-b808-3f1c0127b728.png').convert('RGBA')
sheet=Image.new('RGBA',(1280,256))
for i in range(5):
    cell=src.crop((round(i*src.width/5),0,round((i+1)*src.width/5),src.height))
    b=cell.getchannel('A').point(lambda a:255 if a>128 else 0).getbbox()
    sp=cell.crop(b)
    sp.thumbnail((240,240),Image.Resampling.NEAREST)
    f=Image.new('RGBA',(256,256))
    f.alpha_composite(sp,((256-sp.width)//2,248-sp.height))
    sheet.alpha_composite(f,(i*256,0))
sheet.save('assets/dev/retratos/dev-sanity-portraits.png')
Path('assets/dev/retratos/dev-sanity-portraits-notas.txt').write_text('image_gen integrada. Prompt: cinco retratos do mesmo dev, descansado, olheiras leves, abatido com olheiras fortes, estresse extremo e exaustao burnout; preservar fone cabelo barba camisa azul; pixel art e fundo transparente. Folha 5x1, cada retrato 256x256.\n',encoding='utf-8')
