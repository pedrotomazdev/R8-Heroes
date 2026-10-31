from pathlib import Path
import re
import json

root=Path(__file__).resolve().parent.parent
faltantes=[]
total=0
for arquivo in root.rglob('*'):
    if arquivo.suffix not in {'.gd','.tscn','.tres'} or any(p in ('.godot','.git') for p in arquivo.relative_to(root).parts):
        continue
    for referencia in re.findall(r'res://[A-Za-z0-9_./-]+',arquivo.read_text(encoding='utf-8-sig')):
        if not Path(referencia[6:]).suffix:
            continue
        total+=1
        if not (root/referencia[6:]).exists():
            faltantes.append((str(arquivo.relative_to(root)),referencia))
assert not faltantes,faltantes
mapa=json.loads((root/'work/assets-dev-map.json').read_text(encoding='utf-8'))
for antigo,novo in mapa.items():
    assert not (root/antigo).exists()
    assert (root/novo).exists()
print(f'PASSOU: {total} referencias validas; {len(mapa)} arquivos migrados, sem duplicatas nos caminhos antigos.')
