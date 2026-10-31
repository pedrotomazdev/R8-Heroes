from PIL import Image
from pathlib import Path
src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-2a9384ff-9631-4fbc-88d0-73862ebdf04f.png').convert('RGBA')
sheet=Image.new('RGBA',(1280,192))
for i in range(4):
    cell=src.crop((i*543,170,(i+1)*543,540))
    cell=cell.resize((272,185),Image.Resampling.NEAREST)
    frame=Image.new('RGBA',(320,192)); frame.alpha_composite(cell,(24,3))
    sheet.alpha_composite(frame,(i*320,0))
sheet.save('assets/dev/habilidades/prompt-code-burst.png')
Path('assets/dev/habilidades/prompt-code-burst-notas.txt').write_text('image_gen integrada: rajada de codigo em quatro quadros, nucleo branco menta, fragmentos e colchetes verdes/cianos, cauda de pixels a esquerda, contorno de cometa digital, fundo transparente. Folha 4x1, quadros 320x192, 16 FPS.\n',encoding='utf-8')
