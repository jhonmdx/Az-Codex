# Raid Intel

Addon inicial em Lua para exibir dentro do World of Warcraft dados locais de
guias e fontes como Wowhead, Icy Veins, Archon e Murlok.io.

## Limite importante

Addons do WoW nao podem fazer requisicoes HTTP arbitrarias para esses sites.
Por isso, o Raid Intel nao busca nem atualiza dados online: os dados exibidos
precisam ser preparados e distribuidos nos arquivos Lua do addon. Nao inclua
tokens ou credenciais de APIs no addon. Antes de reutilizar dados, verifique os
termos de uso e as APIs oficiais de cada fonte.

## Adicionar dados

Edite `Data.lua`. Os registros sao indexados pelo arquivo da classe e pelo ID
da especializacao, separados por dois-pontos. Por exemplo, a chave de Arcane
Mage e `MAGE:62`. O addon identifica a especializacao ativa do personagem e
procura somente o registro correspondente. Os perfis `raid` e `mythicPlus`
mantem separados os equipamentos e as recomendacoes para cada conteudo.

```lua
specs = {
    ["MAGE:62"] = {
        patch = "patch do jogo",
        raid = {
            updatedAt = "AAAA-MM-DD",
            sourceName = "Wowhead",
            sourceUrl = "https://www.wowhead.com/guides",
            bisItems = {
                { slot = "Cabeca", name = "Nome do item", note = "Opcional" },
            },
            stats = { "Prioridade de atributos revisada" },
            enchants = {
                { slot = "Arma", name = "Nome do encantamento" },
            },
        },
        mythicPlus = {
            updatedAt = "AAAA-MM-DD",
            sourceName = "Wowhead",
            sourceUrl = "https://www.wowhead.com/guides",
            bisItems = {},
            stats = {},
            enchants = {},
        },
    },
},
```

Na janela, selecione **Raide** ou **Mitico+**. Opcionalmente, cada perfil pode
ter `summary` e `recommendations`. O addon exibe os itens, atributos e
encantamentos cadastrados, mas nao calcula uma simulacao nem busca atualizacoes
online. Preencha as recomendacoes somente com dados verificados para o patch
atual e informe a fonte e a data de revisao.

Os botoes de fonte copiam o endereco para o campo de texto; use Ctrl+A e Ctrl+C
para copia-lo. O endereco especifico do guia cadastrado tambem e exibido no
painel como referencia.

## Preparar guias em JSON

`guides.json` e o arquivo de entrada planejado para a ferramenta de conversao.
Ele ja tem Mago Arcano (`MAGE:62`) separado entre Raide e Mítico+, sem
recomendacoes ficticias. Para preencher, use nomes e textos como objetos com
as chaves `ptBR` e `enUS`. Exemplo de item:

```json
{
  "slot": {
    "ptBR": "Cabeca",
    "enUS": "Head"
  },
  "name": {
    "ptBR": "Nome verificado do item",
    "enUS": "Verified item name"
  }
}
```

Preencha o patch, a temporada, a data de revisao e os itens, atributos,
encantamentos e recomendacoes de cada modo. Use somente dados conferidos no
guia e mantenha o link da fonte.
