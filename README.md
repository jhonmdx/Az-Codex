# Az Codex

![Az Codex](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExMjcyaXRvb2tpenIxNW4zd2l2OWVla3h0OWZqcjNjYjdvcDJ2OWZpNiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/OzUCnzwGrbG4PmMUUr/giphy.gif)

**Az Codex** e um addon para mostrar dados locais de guias de World of Warcraft.
O personagem logado determina automaticamente a classe e a especializacao; nao
e necessario seleciona-las no addon.

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

Exemplo da forma de uma entrada:

```json
{
  "schemaVersion": 2,
  "gameVersion": {
    "patch": "versao consultada",
    "season": 1
  },
  "classes": {
    "CLASS_TOKEN": {
      "classId": 0,
      "specializations": {
        "SPEC_ID": {
          "specId": 0,
          "role": "DAMAGER",
          "name": {
            "ptBR": "Nome da especializacao",
            "enUS": "Specialization name"
          },
          "contents": {
            "raid": {
              "defaultBuildId": "build-id",
              "builds": {
                "build-id": {
                  "name": {
                    "ptBR": "Nome da build",
                    "enUS": "Build name"
                  },
                  "overview": {
                    "ptBR": "Resumo",
                    "enUS": "Overview"
                  },
                  "popularity": {
                    "summary": {
                      "ptBR": "Contexto e amostra da fonte",
                      "enUS": "Source context and sample"
                    },
                    "sampleSize": 0,
                    "source": "Nome da fonte"
                  },
                  "talents": {
                    "importString": {
                      "ptBR": "Codigo de talentos",
                      "enUS": "Talent import string"
                    }
                  },
                  "stats": [],
                  "gems": [],
                  "enchants": [],
                  "bisItems": [],
                  "gear": [],
                  "rotation": [],
                  "sources": [
                    {
                      "name": "Wowhead",
                      "url": "URL da secao correspondente"
                    }
                  ]
                }
              }
            },
            "mythicPlus": {
              "defaultBuildId": "build-id",
              "builds": {}
            }
          }
        }
      }
    }
  }
}
```

Use `ptBR` e `enUS` nos textos exibidos em ambos os idiomas. Cada build pode
ter suas proprias fontes e data de revisao. `defaultBuildId` indica a build
apresentada inicialmente quando um conteudo tem mais de uma opcao. No addon,
o botao Build alterna entre as builds cadastradas para o conteudo selecionado.

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

## Fontes e atualizacao

O addon nao faz requisicoes HTTP aos sites. O conteudo precisa ser incluido
como dados locais. Antes de automatizar a coleta de Wowhead, Icy Veins, Archon
ou Murlok.io, confirme que a fonte fornece uma API ou outro meio autorizado
para obter e reutilizar os dados. Nao contorne controles de acesso. Valores de
popularidade devem sempre indicar sua fonte e contexto e nao devem ser
misturados com recomendacoes editoriais sem deixar essa diferenca clara.
