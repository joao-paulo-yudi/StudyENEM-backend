# Importador do banco de questões — ENEM 2022

Gera o banco de questões do StudyENEM a partir de fontes públicas:

| Saída | Conteúdo |
|---|---|
| `StudyENEM.API/Data/Migrations/Sql/enem_2022.sql` | Script SQL da carga: 4 áreas, 120 habilidades, 15 disciplinas, 58 conteúdos, 4 escalas da TRI, 185 questões e 925 alternativas. É executado pela migration `CargaEnem2022` |
| `StudyENEM.API/wwwroot/midia/enem/2022/` | As 175 imagens das questões (3,0 MB), servidas pelo backend em `/midia` |
| `StudyENEM.Tests/Dados/tri_validacao_2022.json` | 48 padrões de resposta reais com a nota oficial, usados no teste da TRI. Os parâmetros dos itens o teste lê de `enem_2022.sql` |

As questões ficam no banco, carregadas por migration; as imagens são arquivos do backend, servidos em `/midia`.

```bash
cd backend
python tools/enem-import/importar_enem.py             # Python 3.10+ e Pillow (pip install pillow)
python tools/enem-import/importar_enem.py --auditar   # confere as alternativas com os cadernos oficiais (requer: pip install pypdf)
```

Os downloads intermediários, inclusive as imagens, ficam em `tools/enem-import/.cache/` (ignorado pelo Git; outro diretório com `--cache`).
A opção `--revisao` imprime a classificação de CH, CN e MT para conferência manual.

## Como a carga chega ao banco

As questões **não são inseridas pelo código C#**. O banco é criado e populado por **migrations do EF Core**, em
`StudyENEM.API/Data/Migrations/`:

| Migration | O que faz |
|---|---|
| `CriacaoInicial` | Cria as tabelas do DER (`usuario`, `simulado`, `resposta`, `questao`, `alternativa`, `resultado`, `area`, `disciplina`, `conteudo`), além de `habilidade` e `escala_tri`, com chaves estrangeiras e índices únicos |
| `CargaEnem2022` | Executa `Sql/enem_2022.sql`, embutido no assembly da API. O `Down` remove a carga |

O Markdown das questões referencia cada imagem como `/midia/<caminho>`, que o backend serve da pasta `wwwroot/midia`
(`UseStaticFiles`); em produção o nginx encaminha esse caminho para ele.

O script gerado:

- resolve as chaves estrangeiras por **chaves naturais**: sigla da área, nome da disciplina e do conteúdo, código da
  habilidade e ano/número/língua da questão. Assim, não depende dos ids gerados pelo banco;
- usa `ON CONFLICT DO NOTHING` sobre os índices únicos e pode ser executado de novo sem duplicar dados;
- termina com uma conferência (`RAISE EXCEPTION`): se alguma questão ou alternativa não entrou, a migration falha e a
  transação é desfeita.

As migrations são aplicadas automaticamente quando a API sobe (`Database.Migrate()`). Para aplicá-las sem subir a API:

```bash
cd backend
dotnet tool restore                                  # dotnet-ef, na versão fixada em dotnet-tools.json
dotnet ef database update --project StudyENEM.API    # usa ConnectionStrings__Default ou localhost:5432
```

**Depois de regenerar os scripts**, lembre que uma migration já aplicada não roda de novo. Em desenvolvimento, recrie o
banco (`docker compose down -v`). O `Down` da carga não serve para isso quando já existem simulados respondidos:
`resposta` referencia `questao` com `RESTRICT`, então a remoção falha e nada é apagado. Em um banco com dados de
estudantes, publique as correções numa nova migration.

**Outra edição do ENEM** entra como novas migrations, sem alterar as anteriores:

1. Gere `Sql/enem_<ano>.sql`. O importador atual é específico de 2022 (fontes, caderno de referência e revisão manual).
2. Crie a migration com `dotnet ef migrations add CargaEnem<ano> --project StudyENEM.API --output-dir Data/Migrations`.
3. No `Up` da migration, chame `migrationBuilder.Sql(SqlScript.Load("enem_<ano>.sql"))`.

O `.csproj` já embute todo `Data/Migrations/Sql/*.sql`.

## Fontes dos dados

| Fonte | O que foi usado | Como é obtido |
|---|---|---|
| **INEP – Microdados do ENEM 2022** ([download](https://download.inep.gov.br/microdados/microdados_enem_2022.zip)) | `ITENS_PROVA_2022.csv`: gabarito oficial, código do item (`CO_ITEM`), habilidade, parâmetros TRI `a`, `b`, `c` e itens desconsiderados. `MICRODADOS_ENEM_2022.csv`: respostas e notas oficiais de participantes, para calibração e validação da TRI | O zip tem ~620 MB. O script o abre por **HTTP Range** e baixa só os trechos desses arquivos (no caso dos participantes, as primeiras 150 mil linhas) |
| **INEP – Cadernos de prova** (`ENEM_2022_P1_CAD_01_DIA_1_AZUL.pdf` e `ENEM_2022_P1_CAD_07_DIA_2_AZUL.pdf`, dentro do mesmo zip) | Texto oficial das alternativas, usado para conferir e corrigir a transcrição da enem.dev | Extraídos do zip por HTTP Range com `--auditar` |
| **API pública [enem.dev](https://enem.dev)** | Enunciados, alternativas e imagens das questões 1–180 (língua estrangeira: espanhol) | `GET https://api.enem.dev/v1/exams/2022/questions` (paginado) |
| **[maritaca-ai/enem](https://huggingface.co/datasets/maritaca-ai/enem)** (Hugging Face, licença Apache-2.0) | Questões 1–5 de inglês, que a enem.dev não tem | `2022.jsonl` |
| **INEP – Matriz de Referência do ENEM** (incluída nos microdados) | Habilidades H1–H30 de cada área e objetos de conhecimento | Transcrita em `matriz_referencia.py` |

### Por que o ENEM 2022

A enem.dev foi verificada ano a ano. Em 2023 faltam as questões 34, 174 e as de inglês, e há 5 imagens quebradas; 2019 e
2020 também têm lacunas. Já 2022 tem as 180 posições completas, e o dataset maritaca-ai cobre o inglês desse ano. Assim, é
possível montar a prova inteira: 180 questões mais as 5 da outra língua estrangeira, total de 185.

## Etapas

1. **Caderno de referência.** A ordem das questões da enem.dev é a do **caderno AZUL** da 1ª aplicação. O script identifica isso
   automaticamente, comparando a sequência de gabaritos com a de cada caderno (`CO_PROVA`) dos microdados: 45/45 em cada área.
2. **Gabarito oficial.** Prevalece o gabarito do INEP. Houve uma divergência na questão 143 (enem.dev: A; INEP: D).
   A questão 157 foi **anulada pedagogicamente** e fica sem gabarito.
3. **Itens desconsiderados na TRI.** O INEP desconsiderou 7 itens no cálculo da nota (64, 112, 113, 119, 134, 141 e 157), por
   correlação bisserial negativa, não convergência da calibração ou anulação. Eles ficam no banco, mas sem parâmetros.
4. **Questões de inglês.** O maritaca-ai segue outro caderno. O mapeamento para o caderno azul é feito pelo código do item
   (`CO_ITEM`), e o gabarito é conferido. Caracteres corrompidos da fonte são corrigidos.
5. **Imagens.** São baixadas para `StudyENEM.API/wwwroot/midia/enem/2022/`, uma pasta por questão, para a aplicação não
   depender de terceiros. Os links do Markdown são reescritos para `/midia/<caminho>`. Um resíduo de ferramenta de OCR
   presente em um enunciado da enem.dev é removido.

   Cada imagem é convertida para **WebP**: sem perdas nas PNG, que trazem figuras e gráficos com texto fino, e com
   qualidade 90 nas JPEG, que já vêm compactadas com perdas. Se o WebP ficar maior que o original, o original é mantido —
   foi o caso de 3 imagens. No total, 6,81 MB viraram 3,07 MB, com as mesmas dimensões.
6. **Conferência das alternativas com o caderno oficial.** A transcrição da enem.dev tem erros:
   - em 14 questões, letras trocadas ou palavras faltando (ex.: "campenisnato", "tomara de decisões", "Ompetição",
     "Cognitiva, favorecendo ferramentas virtuais");
   - nas questões 144 e 166, **faltava a alternativa A**: as alternativas eram só "6, 7, 8, 9" e "1, 2, 3, 4", com as
     letras deslocadas. Na 166, a resposta correta (A = 0) nem existia.

   As 26 alternativas foram corrigidas pelo texto do caderno azul do INEP (tabela `CORRECOES_ALTERNATIVAS`). A importação
   falha se alguma questão não tiver as cinco alternativas A–E.

   Com `--auditar`, o script extrai o texto dos PDFs oficiais e compara as alternativas: **0 divergências** nas 177 questões
   com alternativas em texto. As outras 8 (95, 96, 103, 106, 143, 156, 160 e 180) têm alternativas em imagem ou fórmula e
   não são conferidas automaticamente.
7. **Classificação em disciplina e conteúdo** (semiautomática):
   - *Linguagens*: a habilidade do INEP define disciplina e conteúdo (ex.: competência 2 → língua estrangeira; competência 5 → Literatura).
   - *Matemática*: a competência limita os conteúdos possíveis, e palavras-chave escolhem entre eles.
   - *Ciências da Natureza e Humanas*: palavras-chave derivadas dos objetos de conhecimento da matriz, com restrições ou bônus
     conforme a habilidade (ex.: H20–H23 → Física; H24–H27 → Química; H28–H30 → Biologia).
   - **Revisão manual**: os resultados de CH, CN e MT foram conferidos com a leitura dos enunciados, e 37 classificações
     foram corrigidas (tabela `REVISAO_MANUAL`, com o motivo de cada uma).

   Resultado: 79 questões classificadas pela habilidade, 69 por palavras-chave e 37 por revisão manual.
8. **Calibração da escala da TRI** (seção a seguir).

## TRI: como a nota é calculada

O INEP descreve o procedimento em *Enem: procedimentos de análise* (documento dos microdados):

- **Modelo logístico de 3 parâmetros**: P(acerto | θ) = c + (1 − c) / (1 + e^(−a(θ − b)))
- **Estimador EAP** (*Expected a Posteriori*), com priori normal e 40 pontos de quadratura
- **Escala**: média 500 e desvio-padrão 100, com os concluintes da rede pública de 2009 como grupo de referência

Dois detalhes não constam do documento e foram **determinados empiricamente**, comparando a implementação com as notas oficiais:

1. **Constante D = 1.** Com D = 1,7 (outra convenção comum), o erro fica entre 7 e 18 pontos. Com D = 1, a correlação com a nota
   oficial é de 0,9999999.
2. **Transformação por área.** Os parâmetros publicados estão numa métrica ligeiramente diferente da escala final. A nota
   oficial é uma função linear exata de θ, mas com constantes próprias de cada área, estimadas por regressão
   com 3.000 participantes por área:

| Área | Nota = intercepto + inclinação · θ | RMSE | Erro máximo |
|---|---|---|---|
| Linguagens (LC) | 499,9775 + 108,0844 · θ | 0,029 | 0,052 |
| Ciências Humanas (CH) | 501,4891 + 112,3103 · θ | 0,029 | 0,050 |
| Ciências da Natureza (CN) | 501,1432 + 113,1020 · θ | 0,029 | 0,051 |
| Matemática (MT) | 500,0212 + 129,6453 · θ | 0,029 | 0,052 |

Um RMSE de 0,029 corresponde ao erro de arredondamento das notas oficiais, publicadas com uma casa decimal
(0,1/√12 ≈ 0,029). Ou seja, **a implementação reproduz a nota oficial do INEP**. O teste automatizado
`StudyENEM.Tests/TriScorerTests.cs` confere 48 participantes reais do caderno azul (12 por área) com tolerância de 0,2 ponto.

### Uso no StudyENEM

- **Resultado do simulado**: nota por área, estimada com as questões respondidas dessa área, e média das áreas.
- **Dashboard**: proficiência acumulada por área, que considera a resposta mais recente de cada questão para não repetir itens.
- **Erro-padrão**: exibido junto da nota. Com poucas questões, a estimativa fica próxima de 500 (efeito da priori) e o erro-padrão cresce.
- **Banco de questões**: a dificuldade de cada item (parâmetro `b`) é mostrada na escala do ENEM.

## Limitações

- As constantes de escala foram estimadas a partir dos microdados, não publicadas pelo INEP. Valem para os itens de 2022;
  outra edição exige nova calibração, que o script faz automaticamente.
- Em simulados parciais, a nota TRI é uma **estimativa** da proficiência, não a nota que o estudante teria no ENEM completo.
- A classificação por conteúdo é semiautomática e pode ter imprecisões pontuais.
- As alternativas em imagem ou fórmula de 8 questões não são conferidas pelo `--auditar`.
