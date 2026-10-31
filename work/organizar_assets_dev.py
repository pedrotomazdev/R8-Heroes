"""Migração de assets do dev: preserva bytes, metadados de importação e referências."""
from pathlib import Path
import hashlib
import json

root=Path(__file__).resolve().parent.parent
assets=root/'assets'

def categoria(nome):
    if nome.startswith('prompt-code-burst') or nome.startswith(('dev-prompt','dev-air-prompt')):
        return 'habilidades'
    if nome in ('dev-attack-keyboard-spritesheet.png','dev-attack-keyboard-v2-spritesheet.png','dev-sanity-animated.png'):
        return 'esbocos'
    if nome.startswith('dev-sanity'):
        return 'retratos'
    if nome.startswith('dev_idle'):
        return 'movimento'
    return 'combate'

mapa={}
hashes={}
for origem in list(assets.iterdir()):
    if not origem.is_file() or not origem.name.startswith(('dev-','dev_','prompt-code-burst')):
        continue
    nome_base=origem.name.removesuffix('.import')
    destino=assets/'dev'/categoria(nome_base)/origem.name
    assert origem.resolve().is_relative_to(root) and destino.resolve().is_relative_to(root)
    assert not destino.exists(), f'Destino já existe: {destino}'
    mapa[origem.relative_to(root).as_posix()]=destino.relative_to(root).as_posix()
    if origem.suffix != '.import':
        hashes[destino]=hashlib.sha256(origem.read_bytes()).hexdigest()
    destino.parent.mkdir(parents=True,exist_ok=True)
    origem.rename(destino)

# Atualiza cenas, preload, importação e scripts de preparação sem tocar em caches.
extensoes={'.gd','.tscn','.tres','.py','.md','.txt','.import'}
alterados=[]
for arquivo in root.rglob('*'):
    if not arquivo.is_file() or arquivo.suffix not in extensoes:
        continue
    relativo=arquivo.relative_to(root)
    if any(p in ('.git','.godot') for p in relativo.parts) or arquivo == Path(__file__).resolve():
        continue
    try:
        original=arquivo.read_text(encoding='utf-8-sig')
    except UnicodeDecodeError:
        continue
    novo=original
    for antes,depois in sorted(mapa.items(),key=lambda item:len(item[0]),reverse=True):
        novo=novo.replace(antes,depois)
    if novo!=original:
        arquivo.write_text(novo,encoding='utf-8')
        alterados.append(relativo.as_posix())

for arquivo,digest in hashes.items():
    assert hashlib.sha256(arquivo.read_bytes()).hexdigest()==digest
(root/'work/assets-dev-map.json').write_text(json.dumps(mapa,indent=2,ensure_ascii=False),encoding='utf-8')
print(f'Movidos {len(mapa)} arquivos; conteúdo de {len(hashes)} assets preservado; {len(alterados)} arquivos de referências atualizados.')
