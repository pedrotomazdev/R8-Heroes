# R8 Heroes

Um dev de chinelo, café na mão e uma agência inteira de caos pela frente.

R8 Heroes é um jogo de ação e plataforma 2D em pixel art, inspirado nas histórias e nas pessoas memoráveis de uma agência de marketing e desenvolvimento. A referência de ação e humor visual é Metal Slug, com personagens e universo próprios.

## Estado do projeto

Protótipo inicial em desenvolvimento, com uma primeira fase jogável e uma cena separada para testar mecânicas.

### Implementado

- Música provisória da primeira fase: remix fornecido pelo autor do projeto, com loop e entrada suave. Volume ajustável no nó `Musica` de `fase01.tscn`.
- HUD sem textos: retrato animado em moldura circular com cabelo sobreposto, sanidade e energia funcional.
- Prompt em Produção no clique direito: digitação e terminal, projétil que atravessa bugs e para nas paredes; 25 de energia por uso.
- Energia recupera 10 por segundo após 1 segundo sem usar o prompt; confirmação no quarto quadro, conjuração no chão ou no ar por meio segundo e interrupção por dano.
- Cinco estados animados do retrato: normal, olheiras, esgotamento, limite e BURNOUT em 0%.
- Movimento lateral com orientação do personagem.
- Pulo, gravidade e colisões.
- Chão e plataforma de teste.
- Câmera acompanhando o jogador.
- Animações de idle, corrida, subida, queda e pouso.
- Retorno à posição inicial ao cair para fora da fase.
- Ataque com teclado, área de impacto e inimigo com vida e reação visual.
- Bug patrulhando e detectando bordas.
- Dev com 100 de sanidade e dano de contato do bug (20 por acerto).
- Invulnerabilidade de 1 segundo, piscar e recuo após receber dano.
- Derrota com reinício automático da fase após 1 segundo.
- Primeira fase: estacionamento com cinco bugs de patrulha e três atiradores, plataformas, dois buracos e chegada na agência.
- Atirador laranja: aviso visual de 0,75 segundo, mira fixada antes do tiro e carga interrompida ao receber golpe. Tiro causa 15 de sanidade e para em paredes.
- Cenário baseado no estacionamento real: brita, muro branco com buraco, casa azul e mangueira em paralaxe. Sem mureta.
- Dois checkpoints: na primeira fase, a derrota restaura a sanidade e retorna ao último ponto, preservando inimigos derrotados.
- Dois hotdogs que recuperam 40 de sanidade cada; inimigos continuam sem barra de vida.

### Planejado

- Combate contra bugs e outras manifestações do caos da agência.
- Colegas e chefes como personagens e aliados.
- Campanha com histórias da agência e cenas curtas.
- Pombo Caramelo: um garnizé do antigo estacionamento, com desbloqueio e passiva representada por um crachá.

As ideias planejadas ainda podem mudar durante o desenvolvimento.

## Tecnologias

- Godot 4.7.
- GDScript.
- Renderizador Compatibility.
- Sprites 2D com fundo transparente; artes atuais são protótipos criados com assistência de IA.

## Como executar

1. Instale o Godot 4.7 padrão, sem .NET.
2. Clone este repositório.
3. No gerenciador de projetos do Godot, clique em Importar e selecione `project.godot`.
4. Use Executar Projeto (F5) para jogar `fase01.tscn`.
5. Para testar mecânicas isoladamente, abra `estacionamento.tscn` e use Executar Cena Atual (F6).

Na primeira abertura, aguarde a importação dos assets. Derrote os oito bugs e alcance a porta da agência para concluir a fase. Plataformas e cenário são provisórios.

## Controles

| Ação | Tecla |
| --- | --- |
| Mover para a esquerda | A |
| Mover para a direita | D |
| Pular | W ou Espaço |
| Atacar | Clique esquerdo |
| Prompt em Produção | Clique direito |

## Organização inicial

```text
assets/dev/movimento/   Idle, corrida e pulo da classe Dev
assets/dev/combate/     Tecladadas e reação de dano
assets/dev/habilidades/ Prompt, digitação e projétil
assets/dev/retratos/    Retratos e estados de sanidade
assets/dev/esbocos/     Versões antigas preservadas
assets/fonts/          Fontes da interface e licenças
assets/                Demais artes: inimigos e itens
project.godot          Configuração do projeto e entradas
estacionamento.tscn    Fase de teste
dev.tscn              Cena reutilizável do personagem
dev.gd                Movimento e controle das animações
```

## Próximos passos

- Refinar a consistência visual das animações.
- Implementar o primeiro ataque.
- Criar um inimigo básico com comportamento simples.
- Montar um pequeno encontro jogável para testar o combate.

## Desenvolvimento

Faça mudanças pequenas e teste cada etapa na fase de teste. Mantenha cenas, scripts e assets no Git; o cache `.godot/` e a pasta `builds/` ficam fora do versionamento.

O projeto começou como uma ideia de idle/auto battler e evoluiu para ação e plataforma com campanha. O protótipo atual segue essa nova direção.


