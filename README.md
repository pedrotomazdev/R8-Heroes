# R8 Heroes

Um dev de chinelo, café na mão e uma agência inteira de caos pela frente.

R8 Heroes é um jogo de ação e plataforma 2D em pixel art, inspirado nas histórias e nas pessoas memoráveis de uma agência de marketing e desenvolvimento. A referência de ação e humor visual é Metal Slug, com personagens e universo próprios.

## Estado do projeto

Protótipo inicial em desenvolvimento. O foco atual é acertar o movimento do personagem antes de implementar combate e campanha.

### Implementado

- Movimento lateral com orientação do personagem.
- Pulo, gravidade e colisões.
- Chão e plataforma de teste.
- Câmera acompanhando o jogador.
- Animações de idle, corrida, subida, queda e pouso.
- Retorno à posição inicial ao cair para fora da fase.

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
4. Abra a cena `estacionamento.tscn`.
5. Use Executar Cena Atual no editor, ou F6.

Na primeira abertura, aguarde a importação dos assets. A cena principal ainda não está configurada no projeto.

## Controles

| Ação | Tecla |
| --- | --- |
| Mover para a esquerda | A |
| Mover para a direita | D |
| Pular | W ou Espaço |

## Organização inicial

```text
assets/                Artes e animações
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
