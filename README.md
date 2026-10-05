# Az Codex

![Az Codex](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExMjcyaXRvb2tpenIxNW4zd2l2OWVla3h0OWZqcjNjYjdvcDJ2OWZpNiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/OzUCnzwGrbG4PmMUUr/giphy.gif)

**Az Codex** e um addon para mostrar dados locais de guias de World of Warcraft.
O personagem logado determina automaticamente a classe e a especializacao; nao
e necessario seleciona-las no addon.

Use `/azcodex` para abrir ou fechar a janela.

## Estrutura universal dos dados

Os dados seguem a hierarquia:

```text
Classe -> Especializacao -> Conteudo -> Build
```

Cada especializacao pode ter varios conteudos (por exemplo, `raid` e
`mythicPlus`) e cada conteudo pode ter varias builds. Uma build pode conter
visao geral, popularidade, talentos, prioridade de atributos, gemas,
encantamentos, equipamento BIS, equipamento adicional e rotacao.

O [guides.json](./guides.json) e o formato de entrada para qualquer classe. As
chaves de classe usam o token do WoW (`DEMONHUNTER`, `MAGE`, etc.); as
especializacoes sao indexadas pelo ID. O addon obtem a classe com `UnitClass`
e a especializacao ativa com `GetSpecializationInfo`, entao procura os dados
correspondentes. IDs usados em dados importados devem ser conferidos com as
APIs do cliente; nomes e IDs de exemplo nao sao afirmacoes sobre o catalogo
atual do jogo.

Os textos podem ser armazenados em `ptBR` e `enUS`. Cada build pode ter uma
opcao padrao; quando ha varias builds para o conteudo selecionado, o botao
Build permite alternar entre elas.

## Mapeamento do guia Wowhead

Os links de exemplo se encaixam nestas secoes:

- `overview-pve-dps` -> visao geral.
- `bis-gear` -> equipamento BIS.
- `rotation-cooldowns-pve-dps` -> rotacao e cooldowns.
- `talent-builds-pve-dps` -> talentos e builds.
- `enchants-gems-pve-dps` -> encantamentos e gemas.
- `stat-priority-pve-dps` -> prioridade de atributos.

Isso identifica o assunto de cada pagina, mas nao garante que um script consiga
ler os dados dela. A coleta automatica depende de uma API ou de outro metodo de
acesso autorizado pela fonte; o formato JSON e a estrutura local, nao um
scraper do Wowhead.
