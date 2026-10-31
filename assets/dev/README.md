# Assets da classe Dev

As cenas e scripts usam estes arquivos por caminhos `res://assets/dev/...`.

| Pasta | Conteúdo |
| --- | --- |
| `movimento/` | Idle, corrida e poses de pulo. |
| `combate/` | Tecladada parada, correndo e no ar; reação de dano. |
| `habilidades/` | Digitação no chão e no ar; projétil do Prompt em Produção. |
| `retratos/` | Retratos estáticos e animações de sanidade do HUD. |
| `esbocos/` | Versões anteriores preservadas, sem uso nas cenas atuais. |

Os arquivos `*-notas.txt` registram informações da geração e do empacotamento. Os `.png.import` guardam os identificadores e as configurações de importação do Godot e acompanham as imagens no Git.

Novas artes do dev devem ser salvas na subpasta correspondente. Assets compartilhados, fontes, itens e inimigos ficam fora da pasta desta classe. Para mover pelo editor, use o painel Arquivos do Godot para que ele atualize as referências.

Os scripts em `work/pack_*.py` são ferramentas de preparação; alguns acrescentam animações à cena e não devem ser executados novamente sem conferir se ela já existe.
