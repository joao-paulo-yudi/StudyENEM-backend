# -*- coding: utf-8 -*-
"""
Taxonomia usada na classificação das questões do StudyENEM.

- HABILIDADES / COMPETENCIAS: transcritas da Matriz de Referência do ENEM (INEP),
  documento "matriz_referencia_enem.pdf" distribuído com os microdados.
- TAXONOMIA: disciplinas e conteúdos organizados a partir do Anexo "Objetos de
  conhecimento associados às Matrizes de Referência" do mesmo documento. As
  palavras-chave (sem acentos, em minúsculas) derivam das descrições desses
  objetos de conhecimento e são usadas pelo classificador semiautomático.
"""

AREAS = {
    "LC": {"nome": "Linguagens, Códigos e suas Tecnologias", "dia": 1, "inicio": 1},
    "CH": {"nome": "Ciências Humanas e suas Tecnologias", "dia": 1, "inicio": 46},
    "CN": {"nome": "Ciências da Natureza e suas Tecnologias", "dia": 2, "inicio": 91},
    "MT": {"nome": "Matemática e suas Tecnologias", "dia": 2, "inicio": 136},
}

# Faixas de habilidades (inclusivas) de cada competência de área.
COMPETENCIAS = {
    "LC": {1: (1, 4), 2: (5, 8), 3: (9, 11), 4: (12, 14), 5: (15, 17), 6: (18, 20), 7: (21, 24), 8: (25, 27), 9: (28, 30)},
    "MT": {1: (1, 5), 2: (6, 9), 3: (10, 14), 4: (15, 18), 5: (19, 23), 6: (24, 26), 7: (27, 30)},
    "CN": {1: (1, 4), 2: (5, 7), 3: (8, 12), 4: (13, 16), 5: (17, 19), 6: (20, 23), 7: (24, 27), 8: (28, 30)},
    "CH": {1: (1, 5), 2: (6, 10), 3: (11, 15), 4: (16, 20), 5: (21, 25), 6: (26, 30)},
}


def competencia(area: str, habilidade: int) -> int:
    for c, (ini, fim) in COMPETENCIAS[area].items():
        if ini <= habilidade <= fim:
            return c
    raise ValueError(f"Habilidade H{habilidade} inválida para {area}")


HABILIDADES = {
    "LC": {
        1: "Identificar as diferentes linguagens e seus recursos expressivos como elementos de caracterização dos sistemas de comunicação.",
        2: "Recorrer aos conhecimentos sobre as linguagens dos sistemas de comunicação e informação para resolver problemas sociais.",
        3: "Relacionar informações geradas nos sistemas de comunicação e informação, considerando a função social desses sistemas.",
        4: "Reconhecer posições críticas aos usos sociais que são feitos das linguagens e dos sistemas de comunicação e informação.",
        5: "Associar vocábulos e expressões de um texto em LEM ao seu tema.",
        6: "Utilizar os conhecimentos da LEM e de seus mecanismos como meio de ampliar as possibilidades de acesso a informações, tecnologias e culturas.",
        7: "Relacionar um texto em LEM, as estruturas linguísticas, sua função e seu uso social.",
        8: "Reconhecer a importância da produção cultural em LEM como representação da diversidade cultural e linguística.",
        9: "Reconhecer as manifestações corporais de movimento como originárias de necessidades cotidianas de um grupo social.",
        10: "Reconhecer a necessidade de transformação de hábitos corporais em função das necessidades cinestésicas.",
        11: "Reconhecer a linguagem corporal como meio de interação social, considerando os limites de desempenho e as alternativas de adaptação para diferentes indivíduos.",
        12: "Reconhecer diferentes funções da arte, do trabalho da produção dos artistas em seus meios culturais.",
        13: "Analisar as diversas produções artísticas como meio de explicar diferentes culturas, padrões de beleza e preconceitos.",
        14: "Reconhecer o valor da diversidade artística e das inter-relações de elementos que se apresentam nas manifestações de vários grupos sociais e étnicos.",
        15: "Estabelecer relações entre o texto literário e o momento de sua produção, situando aspectos do contexto histórico, social e político.",
        16: "Relacionar informações sobre concepções artísticas e procedimentos de construção do texto literário.",
        17: "Reconhecer a presença de valores sociais e humanos atualizáveis e permanentes no patrimônio literário nacional.",
        18: "Identificar os elementos que concorrem para a progressão temática e para a organização e estruturação de textos de diferentes gêneros e tipos.",
        19: "Analisar a função da linguagem predominante nos textos em situações específicas de interlocução.",
        20: "Reconhecer a importância do patrimônio linguístico para a preservação da memória e da identidade nacional.",
        21: "Reconhecer em textos de diferentes gêneros, recursos verbais e não verbais utilizados com a finalidade de criar e mudar comportamentos e hábitos.",
        22: "Relacionar, em diferentes textos, opiniões, temas, assuntos e recursos linguísticos.",
        23: "Inferir em um texto quais são os objetivos de seu produtor e quem é seu público-alvo, pela análise dos procedimentos argumentativos utilizados.",
        24: "Reconhecer no texto estratégias argumentativas empregadas para o convencimento do público, tais como a intimidação, sedução, comoção, chantagem, entre outras.",
        25: "Identificar, em textos de diferentes gêneros, as marcas linguísticas que singularizam as variedades linguísticas sociais, regionais e de registro.",
        26: "Relacionar as variedades linguísticas a situações específicas de uso social.",
        27: "Reconhecer os usos da norma padrão da língua portuguesa nas diferentes situações de comunicação.",
        28: "Reconhecer a função e o impacto social das diferentes tecnologias da comunicação e informação.",
        29: "Identificar pela análise de suas linguagens, as tecnologias da comunicação e informação.",
        30: "Relacionar as tecnologias de comunicação e informação ao desenvolvimento das sociedades e ao conhecimento que elas produzem.",
    },
    "MT": {
        1: "Reconhecer, no contexto social, diferentes significados e representações dos números e operações - naturais, inteiros, racionais ou reais.",
        2: "Identificar padrões numéricos ou princípios de contagem.",
        3: "Resolver situação-problema envolvendo conhecimentos numéricos.",
        4: "Avaliar a razoabilidade de um resultado numérico na construção de argumentos sobre afirmações quantitativas.",
        5: "Avaliar propostas de intervenção na realidade utilizando conhecimentos numéricos.",
        6: "Interpretar a localização e a movimentação de pessoas/objetos no espaço tridimensional e sua representação no espaço bidimensional.",
        7: "Identificar características de figuras planas ou espaciais.",
        8: "Resolver situação-problema que envolva conhecimentos geométricos de espaço e forma.",
        9: "Utilizar conhecimentos geométricos de espaço e forma na seleção de argumentos propostos como solução de problemas do cotidiano.",
        10: "Identificar relações entre grandezas e unidades de medida.",
        11: "Utilizar a noção de escalas na leitura de representação de situação do cotidiano.",
        12: "Resolver situação-problema que envolva medidas de grandezas.",
        13: "Avaliar o resultado de uma medição na construção de um argumento consistente.",
        14: "Avaliar proposta de intervenção na realidade utilizando conhecimentos geométricos relacionados a grandezas e medidas.",
        15: "Identificar a relação de dependência entre grandezas.",
        16: "Resolver situação-problema envolvendo a variação de grandezas, direta ou inversamente proporcionais.",
        17: "Analisar informações envolvendo a variação de grandezas como recurso para a construção de argumentação.",
        18: "Avaliar propostas de intervenção na realidade envolvendo variação de grandezas.",
        19: "Identificar representações algébricas que expressem a relação entre grandezas.",
        20: "Interpretar gráfico cartesiano que represente relações entre grandezas.",
        21: "Resolver situação-problema cuja modelagem envolva conhecimentos algébricos.",
        22: "Utilizar conhecimentos algébricos/geométricos como recurso para a construção de argumentação.",
        23: "Avaliar propostas de intervenção na realidade utilizando conhecimentos algébricos.",
        24: "Utilizar informações expressas em gráficos ou tabelas para fazer inferências.",
        25: "Resolver problema com dados apresentados em tabelas ou gráficos.",
        26: "Analisar informações expressas em gráficos ou tabelas como recurso para a construção de argumentos.",
        27: "Calcular medidas de tendência central ou de dispersão de um conjunto de dados expressos em uma tabela de frequências de dados agrupados (não em classes) ou em gráficos.",
        28: "Resolver situação-problema que envolva conhecimentos de estatística e probabilidade.",
        29: "Utilizar conhecimentos de estatística e probabilidade como recurso para a construção de argumentação.",
        30: "Avaliar propostas de intervenção na realidade utilizando conhecimentos de estatística e probabilidade.",
    },
    "CN": {
        1: "Reconhecer características ou propriedades de fenômenos ondulatórios ou oscilatórios, relacionando-os a seus usos em diferentes contextos.",
        2: "Associar a solução de problemas de comunicação, transporte, saúde ou outro, com o correspondente desenvolvimento científico e tecnológico.",
        3: "Confrontar interpretações científicas com interpretações baseadas no senso comum, ao longo do tempo ou em diferentes culturas.",
        4: "Avaliar propostas de intervenção no ambiente, considerando a qualidade da vida humana ou medidas de conservação, recuperação ou utilização sustentável da biodiversidade.",
        5: "Dimensionar circuitos ou dispositivos elétricos de uso cotidiano.",
        6: "Relacionar informações para compreender manuais de instalação ou utilização de aparelhos, ou sistemas tecnológicos de uso comum.",
        7: "Selecionar testes de controle, parâmetros ou critérios para a comparação de materiais e produtos, tendo em vista a defesa do consumidor, a saúde do trabalhador ou a qualidade de vida.",
        8: "Identificar etapas em processos de obtenção, transformação, utilização ou reciclagem de recursos naturais, energéticos ou matérias-primas, considerando processos biológicos, químicos ou físicos neles envolvidos.",
        9: "Compreender a importância dos ciclos biogeoquímicos ou do fluxo de energia para a vida, ou da ação de agentes ou fenômenos que podem causar alterações nesses processos.",
        10: "Analisar perturbações ambientais, identificando fontes, transporte e(ou) destino dos poluentes ou prevendo efeitos em sistemas naturais, produtivos ou sociais.",
        11: "Reconhecer benefícios, limitações e aspectos éticos da biotecnologia, considerando estruturas e processos biológicos envolvidos em produtos biotecnológicos.",
        12: "Avaliar impactos em ambientes naturais decorrentes de atividades sociais ou econômicas, considerando interesses contraditórios.",
        13: "Reconhecer mecanismos de transmissão da vida, prevendo ou explicando a manifestação de características dos seres vivos.",
        14: "Identificar padrões em fenômenos e processos vitais dos organismos, como manutenção do equilíbrio interno, defesa, relações com o ambiente, sexualidade, entre outros.",
        15: "Interpretar modelos e experimentos para explicar fenômenos ou processos biológicos em qualquer nível de organização dos sistemas biológicos.",
        16: "Compreender o papel da evolução na produção de padrões, processos biológicos ou na organização taxonômica dos seres vivos.",
        17: "Relacionar informações apresentadas em diferentes formas de linguagem e representação usadas nas ciências físicas, químicas ou biológicas, como texto discursivo, gráficos, tabelas, relações matemáticas ou linguagem simbólica.",
        18: "Relacionar propriedades físicas, químicas ou biológicas de produtos, sistemas ou procedimentos tecnológicos às finalidades a que se destinam.",
        19: "Avaliar métodos, processos ou procedimentos das ciências naturais que contribuam para diagnosticar ou solucionar problemas de ordem social, econômica ou ambiental.",
        20: "Caracterizar causas ou efeitos dos movimentos de partículas, substâncias, objetos ou corpos celestes.",
        21: "Utilizar leis físicas e(ou) químicas para interpretar processos naturais ou tecnológicos inseridos no contexto da termodinâmica e(ou) do eletromagnetismo.",
        22: "Compreender fenômenos decorrentes da interação entre a radiação e a matéria em suas manifestações em processos naturais ou tecnológicos, ou em suas implicações biológicas, sociais, econômicas ou ambientais.",
        23: "Avaliar possibilidades de geração, uso ou transformação de energia em ambientes específicos, considerando implicações éticas, ambientais, sociais e/ou econômicas.",
        24: "Utilizar códigos e nomenclatura da química para caracterizar materiais, substâncias ou transformações químicas.",
        25: "Caracterizar materiais ou substâncias, identificando etapas, rendimentos ou implicações biológicas, sociais, econômicas ou ambientais de sua obtenção ou produção.",
        26: "Avaliar implicações sociais, ambientais e/ou econômicas na produção ou no consumo de recursos energéticos ou minerais, identificando transformações químicas ou de energia envolvidas nesses processos.",
        27: "Avaliar propostas de intervenção no meio ambiente aplicando conhecimentos químicos, observando riscos ou benefícios.",
        28: "Associar características adaptativas dos organismos com seu modo de vida ou com seus limites de distribuição em diferentes ambientes, em especial em ambientes brasileiros.",
        29: "Interpretar experimentos ou técnicas que utilizam seres vivos, analisando implicações para o ambiente, a saúde, a produção de alimentos, matérias primas ou produtos industriais.",
        30: "Avaliar propostas de alcance individual ou coletivo, identificando aquelas que visam à preservação e a implementação da saúde individual, coletiva ou do ambiente.",
    },
    "CH": {
        1: "Interpretar historicamente e/ou geograficamente fontes documentais acerca de aspectos da cultura.",
        2: "Analisar a produção da memória pelas sociedades humanas.",
        3: "Associar as manifestações culturais do presente aos seus processos históricos.",
        4: "Comparar pontos de vista expressos em diferentes fontes sobre determinado aspecto da cultura.",
        5: "Identificar as manifestações ou representações da diversidade do patrimônio cultural e artístico em diferentes sociedades.",
        6: "Interpretar diferentes representações gráficas e cartográficas dos espaços geográficos.",
        7: "Identificar os significados histórico-geográficos das relações de poder entre as nações.",
        8: "Analisar a ação dos estados nacionais no que se refere à dinâmica dos fluxos populacionais e no enfrentamento de problemas de ordem econômico-social.",
        9: "Comparar o significado histórico-geográfico das organizações políticas e socioeconômicas em escala local, regional ou mundial.",
        10: "Reconhecer a dinâmica da organização dos movimentos sociais e a importância da participação da coletividade na transformação da realidade histórico-geográfica.",
        11: "Identificar registros de práticas de grupos sociais no tempo e no espaço.",
        12: "Analisar o papel da justiça como instituição na organização das sociedades.",
        13: "Analisar a atuação dos movimentos sociais que contribuíram para mudanças ou rupturas em processos de disputa pelo poder.",
        14: "Comparar diferentes pontos de vista, presentes em textos analíticos e interpretativos, sobre situação ou fatos de natureza histórico-geográfica acerca das instituições sociais, políticas e econômicas.",
        15: "Avaliar criticamente conflitos culturais, sociais, políticos, econômicos ou ambientais ao longo da história.",
        16: "Identificar registros sobre o papel das técnicas e tecnologias na organização do trabalho e/ou da vida social.",
        17: "Analisar fatores que explicam o impacto das novas tecnologias no processo de territorialização da produção.",
        18: "Analisar diferentes processos de produção ou circulação de riquezas e suas implicações socioespaciais.",
        19: "Reconhecer as transformações técnicas e tecnológicas que determinam as várias formas de uso e apropriação dos espaços rural e urbano.",
        20: "Selecionar argumentos favoráveis ou contrários às modificações impostas pelas novas tecnologias à vida social e ao mundo do trabalho.",
        21: "Identificar o papel dos meios de comunicação na construção da vida social.",
        22: "Analisar as lutas sociais e conquistas obtidas no que se refere às mudanças nas legislações ou nas políticas públicas.",
        23: "Analisar a importância dos valores éticos na estruturação política das sociedades.",
        24: "Relacionar cidadania e democracia na organização das sociedades.",
        25: "Identificar estratégias que promovam formas de inclusão social.",
        26: "Identificar em fontes diversas o processo de ocupação dos meios físicos e as relações da vida humana com a paisagem.",
        27: "Analisar de maneira crítica as interações da sociedade com o meio físico, levando em consideração aspectos históricos e(ou) geográficos.",
        28: "Relacionar o uso das tecnologias com os impactos socioambientais em diferentes contextos histórico-geográficos.",
        29: "Reconhecer a função dos recursos naturais na produção do espaço geográfico, relacionando-os com as mudanças provocadas pelas ações humanas.",
        30: "Avaliar as relações entre preservação e degradação da vida no planeta nas diferentes escalas.",
    },
}

# ── Taxonomia: área → disciplina → conteúdo → palavras-chave ────────────────
TAXONOMIA = {
    "LC": {
        "Língua Portuguesa": {
            "Gêneros textuais e funções da linguagem": [],
            "Texto argumentativo e intencionalidade": [],
            "Variação linguística e norma-padrão": [],
        },
        "Literatura": {"Texto literário e contexto de produção": []},
        "Inglês": {"Interpretação de texto em língua inglesa": []},
        "Espanhol": {"Interpretação de texto em língua espanhola": []},
        "Artes": {"Produção e recepção de textos artísticos": []},
        "Educação Física": {"Práticas corporais e cultura corporal": []},
        "Tecnologias da Informação e Comunicação": {"Gêneros digitais e tecnologias da comunicação": []},
    },
    "MT": {
        "Matemática": {
            "Aritmética e conjuntos numéricos": ["multiplo", "divisor", "mdc", "mmc", "numero primo", "fracao", "fracoes", "decimal", "notacao cientifica", "potencia de", "raiz quadrada", "numeros inteiros", "racionais", "divisibilidade", "resto da divisao", "algarismo", "arredond"],
            "Razão, proporção e regra de três": ["proporcional", "proporcao", "razao entre", "regra de tres", "diretamente", "inversamente", "escala", "velocidade media", "consumo", "por hora", "por minuto", "por quilometro", "rendimento de"],
            "Porcentagem e matemática financeira": ["porcentagem", "percentual", "%", "juros", "desconto", "acrescimo", "reajuste", "lucro", "prestac", "parcela", "financiamento", "inflacao", "imposto"],
            "Análise combinatória": ["combinac", "permutac", "arranjo", "anagrama", "maneiras", "modos distintos", "formas distintas", "formas diferentes", "possibilidades", "senha", "contagem"],
            "Sequências e progressões": ["sequencia", "progressao", "termo geral", "padrao se mantem", "enesimo"],
            "Grandezas, medidas e escalas": ["unidade de medida", "unidades de medida", "metro", "centimetro", "milimetro", "quilometro", "grama", "quilograma", "litro", "mililitro", "polegada", "conversao", "escala", "medida"],
            "Geometria plana": ["triangulo", "quadrado", "retangul", "circulo", "circunferencia", "area", "perimetro", "angulo", "poligono", "hexagono", "trapezio", "losango", "semelhanc", "pitagoras", "raio", "diametro", "setor circular", "malha quadriculada", "ladrilh", "piso", "simetria", "rotacao", "reflexao"],
            "Geometria espacial": ["cubo", "prisma", "cilindr", "cone", "esfera", "piramide", "volume", "solido", "paralelepipedo", "planificac", "vista superior", "vista frontal", "vista lateral", "tridimensional", "capacidade", "reservatorio", "embalagem", "aresta", "vertice", "face"],
            "Trigonometria": ["seno", "cosseno", "tangente", "trigonometr", "radiano"],
            "Geometria analítica": ["plano cartesiano", "coordenada", "eixo x", "eixo y", "equacao da reta", "abscissa", "ordenada", "distancia entre os pontos"],
            "Funções": ["funcao", "f(x)", "crescente", "decrescente", "exponencial", "logaritm", "parabola", "quadratica", "afim", "valor maximo", "valor minimo", "vertice da", "expressao algebrica", "modelada", "modelo matematico"],
            "Equações e inequações": ["equacao", "equacoes", "sistema de", "inequac", "incognita"],
            "Estatística": ["media", "mediana", "moda", "desvio padrao", "variancia", "dispersao", "frequencia", "amostra"],
            "Probabilidade": ["probabilidade", "chance", "sorteio", "sortead", "aleatori", "ao acaso", "dado honesto", "moeda"],
            "Leitura de gráficos e tabelas": ["grafico", "tabela", "infografico", "barras", "setores"],
        },
    },
    "CN": {
        "Física": {
            "Mecânica: movimento e forças": ["velocidade", "aceleracao", "forca", "atrito", "newton", "inercia", "movimento", "trajetoria", "queda", "lancamento", "colisao", "quantidade de movimento", "impulso", "torque", "alavanca", "polia", "empuxo", "pressao hidrostatica", "fluido", "arquimedes", "pascal", "stevin", "mola", "km/h", "m/s", "freio", "roldana", "centro de massa"],
            "Energia, trabalho e potência": ["energia cinetica", "energia potencial", "energia mecanica", "trabalho realizado", "potencia", "rendimento", "conservacao da energia", "hidreletrica", "eolica", "usina", "geracao de energia", "turbina", "joule"],
            "Gravitação e astronomia": ["gravitac", "orbita", "satelite", "planeta", "kepler", "lua ", "eclipse", "estrela", "astronom", "galaxia"],
            "Eletricidade e magnetismo": ["corrente eletrica", "tensao eletrica", "tensao", "resistor", "resistencia eletrica", "circuito", "lampada", "volt", "ampere", "watt", "kwh", "chuveiro", "campo magnetico", "ima", "inducao", "eletromagnet", "capacitor", "carga eletrica", "fusivel", "disjuntor", "bateria", "gerador", "motor eletrico", "transformador", "eletrico", "eletrica", "choque"],
            "Ondas, óptica e radiação": ["onda", "frequencia", "comprimento de onda", "som ", "sonor", "acustic", "luz", "luminos", "lente", "espelho", "refracao", "reflexao", "optic", "ultravioleta", "infravermelho", "micro-onda", "laser", "prisma", "difracao", "interferencia", "ressonancia", "decibel", "hertz", "raio x", "raios x", "fibra optica", "radiacao eletromagnetica", "espectro", "oscila"],
            "Calor e termodinâmica": ["calor", "temperatura", "termic", "dilatacao", "calorimetr", "calor especifico", "calor latente", "ebulicao", "evaporacao", "condensacao", "isolante", "conducao", "conveccao", "maquina termica", "carnot", "termodinamic", "refrigerador", "geladeira", "garrafa termica"],
        },
        "Química": {
            "Modelos atômicos e tabela periódica": ["atomo", "atomic", "eletron", "proton", "neutron", "isotopo", "tabela periodica", "modelo atomico", "rutherford", "bohr", "numero atomico", "eletronegatividade", "raio atomico", "camada de valencia"],
            "Transformações e reações químicas": ["reacao quimica", "reacoes quimicas", "transformacao quimica", "reagente", "produto da reacao", "equacao quimica", "precipitad", "substancia"],
            "Estequiometria e grandezas químicas": ["mol", "massa molar", "estequiometr", "reagente limitante", "avogadro", "balancea", "g/mol", "quantidade de materia", "rendimento da reacao"],
            "Materiais, ligações e propriedades": ["ligacao ionica", "ligacoes ionicas", "covalente", "ligacao metalica", "polaridade", "polar", "apolar", "intermolecular", "ligacoes de hidrogenio", "separacao de mistura", "destilacao", "filtracao", "decantacao", "liga metalica", "ponto de fusao", "ponto de ebulicao", "estado fisico", "solubilidade", "material", "metal"],
            "Soluções, ácidos, bases e sais": ["concentracao", "solucao", "soluto", "solvente", "diluicao", "acido", "base", "basico", "sal", "ph", "neutraliza", "indicador", "mol/l", "g/l", "titulacao", "oxido", "alcalin", "antiacido", "coligativ", "osmose"],
            "Oxirredução, eletroquímica e termoquímica": ["entalpia", "exotermic", "endotermic", "combustao", "calor de reacao", "kj", "oxirreducao", "oxidacao", "reducao", "pilha", "eletrolise", "potencial de reducao", "corrosao", "galvaniz", "eletrodo", "catodo", "anodo", "nox"],
            "Radioatividade": ["radioativ", "meia-vida", "decaimento", "fissao", "fusao nuclear", "nuclear", "uranio", "cesio", "particula alfa", "particula beta", "radiacao gama"],
            "Cinética e equilíbrio químico": ["velocidade da reacao", "velocidade de reacao", "catalisador", "energia de ativacao", "equilibrio quimico", "constante de equilibrio", "le chatelier", "deslocamento do equilibrio", "tampao", "hidrolise"],
            "Química orgânica": ["organic", "hidrocarboneto", "alcool", "etanol", "cetona", "aldeido", "ester", "eter", "acido carboxilico", "amina", "amida", "polimero", "plastico", "isomer", "benzeno", "funcao organica", "grupo funcional", "cadeia carbonica", "sabao", "detergente", "oleo", "gordura", "triglicer", "biodiesel", "petroleo", "carbonila", "hidroxila"],
            "Química ambiental e energia": ["poluicao", "poluente", "chuva acida", "efeito estufa", "dioxido de carbono", "co2", "tratamento de agua", "esgoto", "residuo", "reciclagem", "combustive", "biocombustive", "biomassa", "metais pesados", "mercurio", "chumbo", "lixo", "contaminacao"],
        },
        "Biologia": {
            "Citologia e bioquímica": ["celula", "celular", "membrana plasmatica", "mitocondri", "cloroplast", "organela", "ribossomo", "nucleo", "enzima", "proteina", "fotossintese", "respiracao celular", "atp", "metabolismo", "glicolise", "carboidrato", "lipidio", "mitose", "meiose", "aminoacido"],
            "Genética e biotecnologia": ["gene", "genetic", "dna", "rna", "cromossom", "alelo", "heranca", "hereditari", "mendel", "genotipo", "fenotipo", "mutacao", "transgenic", "clonagem", "biotecnolog", "crispr", "sequenciamento", "pcr", "recombinante", "genoma"],
            "Evolução": ["evolucao", "evolutiv", "selecao natural", "darwin", "lamarck", "especiacao", "ancestral", "filogen", "fossil", "irradiacao adaptativa"],
            "Ecologia e meio ambiente": ["ecossistema", "cadeia alimentar", "teia alimentar", "populacao", "comunidade", "nicho", "habitat", "bioma", "biodiversidade", "especie invasora", "especies exoticas", "predador", "presa", "mutualismo", "parasitismo", "competicao", "sucessao ecologica", "ciclo do carbono", "ciclo do nitrogenio", "desmatamento", "extincao", "conservacao", "polinizac", "decompositor", "eutrofizac", "ambiental"],
            "Fisiologia humana e animal": ["sistema nervoso", "hormonio", "sangue", "sanguine", "coracao", "rim", "renal", "figado", "digest", "sistema imun", "anticorpo", "antigeno", "neuronio", "musculo", "pulmao", "pulmonar", "glandula", "insulina", "reproducao", "gestacao", "embriao", "organismo humano", "corpo humano"],
            "Botânica e diversidade dos seres vivos": ["planta", "vegeta", "raiz", "folha", "flor", "fruto", "semente", "fungo", "protozoario", "alga", "invertebrado", "vertebrado", "taxonomi", "briofita", "pteridofita", "angiosperma", "gimnosperma", "inseto", "anfibio", "reptil", "mamifero", "ave "],
            "Saúde e doenças": ["doenca", "virus", "bacteria", "infeccao", "vacina", "epidemia", "pandemia", "parasita", "transmissao", "dengue", "malaria", "tuberculose", "profilaxia", "saneamento", "antibiotico", "medicamento", "sintoma", "saude"],
        },
    },
    "CH": {
        "História": {
            "Brasil Colônia": ["colonia", "colonial", "colonizac", "sesmaria", "capitania", "engenho", "bandeirante", "jesuita", "metropole portuguesa", "pau-brasil", "quilombo", "seculo xvi", "seculo xvii", "seculo xviii"],
            "Brasil Império": ["imperio do brasil", "imperial", "pedro ii", "pedro i", "monarquia", "regencia", "abolicao", "lei aurea", "independencia do brasil", "guerra do paraguai", "seculo xix"],
            "Brasil República": ["republica", "vargas", "estado novo", "getulio", "golpe de 1964", "ditadura militar", "regime militar", "constituicao de 1988", "juscelino", "redemocratizac", "tenentismo", "coronelismo", "diretas ja", "seculo xx"],
            "Antiguidade e Idade Média": ["grecia", "grego", "gregos", "roma", "romano", "egito", "mesopotamia", "medieval", "feudal", "idade media", "cruzada", "antiguidade", "polis", "atenas", "esparta"],
            "Idade Moderna e Contemporânea": ["renascimento", "reforma protestante", "iluminismo", "revolucao francesa", "revolucao industrial", "absolutismo", "mercantilismo", "guerra mundial", "guerra fria", "nazismo", "nazista", "fascismo", "imperialismo", "revolucao russa", "descolonizac", "grandes navegacoes", "totalitar"],
            "Povos indígenas, africanos e diversidade cultural": ["indigena", "indios", "africa", "africano", "afro", "escraviz", "escravidao", "negros", "quilombola", "patrimonio cultural", "candomble", "etnia", "etnico", "memoria"],
        },
        "Geografia": {
            "Geografia física e questões ambientais": ["relevo", "clima", "climatic", "chuva", "pluviometr", "vegetacao", "solo", "erosao", "bacia hidrografica", "placas tectonicas", "vulcan", "terremoto", "aquifero", "desertificac", "aquecimento global", "efeito estufa", "ilha de calor", "massa de ar", "ambiental", "rio ", "nascente", "floresta", "desmatamento", "queimada"],
            "Espaço agrário, indústria e economia": ["agricultura", "agronegocio", "agropecuar", "latifundio", "reforma agraria", "rural", "commodit", "soja", "industria", "industrializac", "fordismo", "toyotismo", "globalizac", "economia", "economic", "mercado", "multinacional", "transnacional", "exportac", "matriz energetica", "logistica", "cadeia produtiva"],
            "Espaço urbano e população": ["cidade", "urbano", "urbaniza", "metropol", "favela", "segregacao", "migra", "imigra", "emigra", "demografi", "populacao", "envelhecimento", "natalidade", "mobilidade urbana", "periferia"],
            "Geopolítica e cartografia": ["mapa", "cartograf", "projecao", "latitude", "longitude", "fuso horario", "geopolitic", "fronteira", "territorio", "onu", "bloco economico", "mercosul", "uniao europeia", "estado-nacao", "gps", "sensoriamento"],
        },
        "Filosofia": {
            "Filosofia antiga e medieval": ["socrates", "platao", "aristoteles", "pre-socratic", "sofista", "epicur", "estoic", "agostinho", "tomas de aquino", "heraclito", "parmenides", "filosofia antiga", "escolastic"],
            "Filosofia moderna e contemporânea": ["descartes", "kant", "hume", "locke", "hobbes", "rousseau", "maquiavel", "nietzsche", "sartre", "hegel", "bacon", "espinosa", "spinoza", "existencialis", "empiris", "racionalis", "foucault", "arendt", "habermas", "adorno", "horkheimer", "beauvoir", "wittgenstein", "montesquieu", "voltaire", "filosofo", "filosofia"],
            "Ética e política": ["etica", "moral", "virtude", "contrato social", "estado de natureza", "soberania", "poder politico", "liberdade"],
        },
        "Sociologia": {
            "Cultura, identidade e movimentos sociais": ["movimento social", "movimentos sociais", "feminis", "genero", "identidade", "racismo", "preconceito", "discrimina", "diversidade", "industria cultural", "cultura de massa", "minoria", "lgbt"],
            "Trabalho e sociedade": ["trabalho", "trabalhador", "emprego", "desemprego", "precariza", "sindicat", "classe social", "capitalis", "proletari", "burgues", "mais-valia", "desigualdade social", "informalidade", "uberiza"],
            "Cidadania, Estado e direitos": ["cidadania", "direitos humanos", "direitos sociais", "constituicao", "politica publica", "politicas publicas", "participacao politica", "voto", "eleic", "inclusao social", "violencia", "democracia", "democratic"],
            "Tecnologia, mídia e sociedade": ["redes sociais", "internet", "celular", "smartphone", "meios de comunicacao", "midia", "digital", "tecnologias da informacao", "plataforma"],
            "Pensamento sociológico": ["durkheim", "weber", "marx", "bauman", "giddens", "florestan", "gilberto freyre", "sergio buarque", "sociolog", "fato social"],
        },
    },
}

# ── Regras por habilidade ───────────────────────────────────────────────────
# Linguagens: a habilidade determina a disciplina e o conteúdo (competências da matriz).
LC_POR_COMPETENCIA = {
    1: ("Tecnologias da Informação e Comunicação", "Gêneros digitais e tecnologias da comunicação"),
    2: ("LEM", None),  # resolvido pela língua da questão (Inglês/Espanhol)
    3: ("Educação Física", "Práticas corporais e cultura corporal"),
    4: ("Artes", "Produção e recepção de textos artísticos"),
    5: ("Literatura", "Texto literário e contexto de produção"),
    6: ("Língua Portuguesa", "Gêneros textuais e funções da linguagem"),
    7: ("Língua Portuguesa", "Texto argumentativo e intencionalidade"),
    8: ("Língua Portuguesa", "Variação linguística e norma-padrão"),
    9: ("Tecnologias da Informação e Comunicação", "Gêneros digitais e tecnologias da comunicação"),
}

# Matemática: conteúdos admitidos por competência e conteúdo padrão.
MT_POR_COMPETENCIA = {
    1: (["Aritmética e conjuntos numéricos", "Porcentagem e matemática financeira", "Análise combinatória", "Sequências e progressões", "Razão, proporção e regra de três"], "Aritmética e conjuntos numéricos"),
    2: (["Geometria plana", "Geometria espacial", "Trigonometria", "Geometria analítica"], "Geometria plana"),
    3: (["Grandezas, medidas e escalas", "Geometria plana", "Geometria espacial"], "Grandezas, medidas e escalas"),
    4: (["Razão, proporção e regra de três", "Porcentagem e matemática financeira"], "Razão, proporção e regra de três"),
    5: (["Funções", "Equações e inequações", "Geometria analítica", "Sequências e progressões"], "Funções"),
    6: (["Leitura de gráficos e tabelas", "Estatística", "Porcentagem e matemática financeira"], "Leitura de gráficos e tabelas"),
    7: (["Estatística", "Probabilidade", "Análise combinatória"], "Estatística"),
}

# Ciências da Natureza: disciplinas admitidas e (disciplina, conteúdo) padrão por habilidade.
CN_POR_HABILIDADE = {
    1: (["Física"], ("Física", "Ondas, óptica e radiação")),
    2: (None, None),
    3: (None, None),
    4: (None, ("Biologia", "Ecologia e meio ambiente")),
    5: (["Física"], ("Física", "Eletricidade e magnetismo")),
    6: (["Física", "Química"], ("Física", "Eletricidade e magnetismo")),
    7: (None, ("Química", "Materiais, ligações e propriedades")),
    8: (None, ("Química", "Química ambiental e energia")),
    9: (["Biologia", "Química"], ("Biologia", "Ecologia e meio ambiente")),
    10: (None, ("Química", "Química ambiental e energia")),
    11: (["Biologia"], ("Biologia", "Genética e biotecnologia")),
    12: (None, ("Biologia", "Ecologia e meio ambiente")),
    13: (["Biologia"], ("Biologia", "Genética e biotecnologia")),
    14: (["Biologia"], ("Biologia", "Fisiologia humana e animal")),
    15: (["Biologia"], ("Biologia", "Citologia e bioquímica")),
    16: (["Biologia"], ("Biologia", "Evolução")),
    17: (None, None),
    18: (None, None),
    19: (None, None),
    20: (["Física"], ("Física", "Mecânica: movimento e forças")),
    21: (["Física", "Química"], ("Física", "Calor e termodinâmica")),
    22: (["Física", "Química"], ("Física", "Ondas, óptica e radiação")),
    23: (["Física", "Química"], ("Física", "Energia, trabalho e potência")),
    24: (["Química"], ("Química", "Transformações e reações químicas")),
    25: (["Química"], ("Química", "Materiais, ligações e propriedades")),
    26: (["Química"], ("Química", "Química ambiental e energia")),
    27: (["Química"], ("Química", "Química ambiental e energia")),
    28: (["Biologia"], ("Biologia", "Ecologia e meio ambiente")),
    29: (["Biologia"], ("Biologia", "Genética e biotecnologia")),
    30: (["Biologia"], ("Biologia", "Saúde e doenças")),
}

# Ciências Humanas: (disciplina, conteúdo) padrão por competência; a disciplina padrão
# recebe um pequeno bônus no placar do classificador.
CH_POR_COMPETENCIA = {
    1: ("História", "Povos indígenas, africanos e diversidade cultural"),
    2: ("Geografia", "Geopolítica e cartografia"),
    3: ("História", "Idade Moderna e Contemporânea"),
    4: ("Geografia", "Espaço agrário, indústria e economia"),
    5: ("Sociologia", "Cidadania, Estado e direitos"),
    6: ("Geografia", "Geografia física e questões ambientais"),
}
