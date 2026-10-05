# Raid Intel

Addon inicial em Lua para exibir dentro do World of Warcraft dados locais de
guias e fontes como Wowhead, Icy Veins, Archon e Murlok.io.

## Limite importante

Addons do WoW nao podem fazer requisicoes HTTP arbitrarias para esses sites.
Por isso, o Raid Intel nao busca nem atualiza dados online: os dados exibidos
precisam ser preparados e distribuidos nos arquivos Lua do addon. Nao inclua
tokens ou credenciais de APIs no addon. Antes de reutilizar dados, verifique os
termos de uso e as APIs oficiais de cada fonte.

## Instalacao

1. Copie a pasta do addon para `World of Warcraft/_retail_/Interface/AddOns/RaidIntel`.
2. No seletor de personagens, habilite **Raid Intel**.
3. No jogo, use `/raidintel` para abrir ou fechar a janela.

O numero `Interface` no arquivo TOC deve corresponder a versao do cliente do
WoW. Se o addon aparecer como desatualizado, atualize esse numero para o valor
da versao instalada ou habilite addons desatualizados temporariamente.
Use os botoes **PT-BR** e **EN** no addon para trocar o idioma; a preferencia e
salva para a proxima sessao.

## Prévia visual no navegador

Abra `preview.html` em um navegador para visualizar o layout sem instalar o
addon. Os botoes de idioma alternam entre portugues do Brasil e ingles; os
botoes de **Raide** e **Mitico+** alternam entre exemplos visuais. Itens,
atributos e encantamentos nessa pagina sao ficticios e nao devem ser usados
como recomendacoes de jogo. As fontes aparecem em duas colunas, duas por linha.

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

## Proxima etapa para automatizar

Para automatizar atualizacoes, implemente um coletor fora do jogo que use
somente APIs e metodos autorizados pelas fontes. Esse coletor pode normalizar
os dados e gerar o arquivo `Data.lua`; o addon continua apenas carregando e
exibindo os dados locais.
