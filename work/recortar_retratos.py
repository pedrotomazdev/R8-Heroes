from PIL import Image
from pathlib import Path
from collections import deque

src=Image.open(r'C:\Users\Dev\.codex\generated_images\01a18f26-6f09-7902-8c26-7ba2d0ac90e6\exec-41196a13-6f77-4def-8cac-fa33088c731e.png').convert('RGBA')
w,h=src.size
# Detecta cada silhueta opaca, em vez de presumir células uniformes na geração.
alpha=src.getchannel('A')
mask=bytearray(1 if a>=244 else 0 for a in alpha.tobytes())
components=[]
for start in range(w*h):
    if not mask[start]: continue
    mask[start]=0
    queue=deque([start]); count=0
    xmin=xmax=start%w; ymin=ymax=start//w
    while queue:
        pos=queue.popleft(); x=pos%w; y=pos//w
        count+=1
        xmin=min(xmin,x); xmax=max(xmax,x); ymin=min(ymin,y); ymax=max(ymax,y)
        for nxt in (pos-1 if x else -1,pos+1 if x<w-1 else -1,pos-w if y else -1,pos+w if y<h-1 else -1):
            if nxt>=0 and mask[nxt]:
                mask[nxt]=0; queue.append(nxt)
    if count>5000: components.append((count,(xmin,ymin,xmax+1,ymax+1)))
components=sorted(components,reverse=True)[:15]
assert len(components)==15, len(components)
boxes=sorted([b for _,b in components],key=lambda b:b[1])
ordered=[]
for row in range(5): ordered.extend(sorted(boxes[row*3:row*3+3],key=lambda b:b[0]))
scale=min(232/max(b[2]-b[0]+4 for b in ordered),232/max(b[3]-b[1]+4 for b in ordered))
sheet=Image.new('RGBA',(768,1280))
for i,b in enumerate(ordered):
    box=(max(0,b[0]-2),max(0,b[1]-2),min(w,b[2]+2),min(h,b[3]+2))
    sprite=src.crop(box)
    sprite=sprite.resize((round(sprite.width*scale),round(sprite.height*scale)),Image.Resampling.NEAREST)
    cell=Image.new('RGBA',(256,256))
    cell.alpha_composite(sprite,((256-sprite.width)//2,246-sprite.height))
    sheet.alpha_composite(cell,((i%3)*256,(i//3)*256))
sheet.save('assets/dev/retratos/dev-sanity-animated-v2.png')
print('15 retratos isolados; escala unica:',round(scale,3))
print(ordered)
