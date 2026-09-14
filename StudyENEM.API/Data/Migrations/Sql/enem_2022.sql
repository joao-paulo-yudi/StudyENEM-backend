-- =============================================================================
-- StudyENEM · Banco de questões do ENEM 2022 (1ª aplicação, caderno AZUL)
--
-- Gerado automaticamente por backend/tools/enem-import/importar_enem.py.
-- NÃO EDITE MANUALMENTE: altere o importador e gere o arquivo novamente.
-- Executado pela migration CargaEnem2022 (StudyENEM.API/Data/Migrations).
--
-- Fontes:
--   INEP, Microdados do ENEM 2022 (ITENS_PROVA_2022.csv): gabarito oficial, habilidade,
--     parâmetros da TRI e itens desconsiderados.
--   API pública enem.dev: enunciados, alternativas e imagens (questões 1 a 180).
--   maritaca-ai/enem (Hugging Face, licença Apache-2.0): questões 1 a 5 de inglês.
--   INEP, cadernos de prova do caderno azul: conferência e correção das alternativas.
--   INEP, Matriz de Referência do ENEM: habilidades e objetos de conhecimento.
--
-- As chaves estrangeiras são resolvidas por chaves naturais (sigla da área, nomes da
-- disciplina e do conteúdo, código da habilidade), sem depender de ids gerados.
-- ON CONFLICT DO NOTHING torna o script idempotente.
-- =============================================================================

-- Áreas do conhecimento
INSERT INTO area (sigla, nome, ordem) VALUES
  ('LC', 'Linguagens, Códigos e suas Tecnologias', 1),
  ('CH', 'Ciências Humanas e suas Tecnologias', 2),
  ('CN', 'Ciências da Natureza e suas Tecnologias', 3),
  ('MT', 'Matemática e suas Tecnologias', 4)
ON CONFLICT DO NOTHING;

-- Habilidades da Matriz de Referência do ENEM (120)
INSERT INTO habilidade (area_id, codigo, competencia, descricao)
SELECT a.id, v.codigo, v.competencia, v.descricao
FROM (VALUES
  ('LC', 1, 1, 'Identificar as diferentes linguagens e seus recursos expressivos como elementos de caracterização dos sistemas de comunicação.'),
  ('LC', 2, 1, 'Recorrer aos conhecimentos sobre as linguagens dos sistemas de comunicação e informação para resolver problemas sociais.'),
  ('LC', 3, 1, 'Relacionar informações geradas nos sistemas de comunicação e informação, considerando a função social desses sistemas.'),
  ('LC', 4, 1, 'Reconhecer posições críticas aos usos sociais que são feitos das linguagens e dos sistemas de comunicação e informação.'),
  ('LC', 5, 2, 'Associar vocábulos e expressões de um texto em LEM ao seu tema.'),
  ('LC', 6, 2, 'Utilizar os conhecimentos da LEM e de seus mecanismos como meio de ampliar as possibilidades de acesso a informações, tecnologias e culturas.'),
  ('LC', 7, 2, 'Relacionar um texto em LEM, as estruturas linguísticas, sua função e seu uso social.'),
  ('LC', 8, 2, 'Reconhecer a importância da produção cultural em LEM como representação da diversidade cultural e linguística.'),
  ('LC', 9, 3, 'Reconhecer as manifestações corporais de movimento como originárias de necessidades cotidianas de um grupo social.'),
  ('LC', 10, 3, 'Reconhecer a necessidade de transformação de hábitos corporais em função das necessidades cinestésicas.'),
  ('LC', 11, 3, 'Reconhecer a linguagem corporal como meio de interação social, considerando os limites de desempenho e as alternativas de adaptação para diferentes indivíduos.'),
  ('LC', 12, 4, 'Reconhecer diferentes funções da arte, do trabalho da produção dos artistas em seus meios culturais.'),
  ('LC', 13, 4, 'Analisar as diversas produções artísticas como meio de explicar diferentes culturas, padrões de beleza e preconceitos.'),
  ('LC', 14, 4, 'Reconhecer o valor da diversidade artística e das inter-relações de elementos que se apresentam nas manifestações de vários grupos sociais e étnicos.'),
  ('LC', 15, 5, 'Estabelecer relações entre o texto literário e o momento de sua produção, situando aspectos do contexto histórico, social e político.'),
  ('LC', 16, 5, 'Relacionar informações sobre concepções artísticas e procedimentos de construção do texto literário.'),
  ('LC', 17, 5, 'Reconhecer a presença de valores sociais e humanos atualizáveis e permanentes no patrimônio literário nacional.'),
  ('LC', 18, 6, 'Identificar os elementos que concorrem para a progressão temática e para a organização e estruturação de textos de diferentes gêneros e tipos.'),
  ('LC', 19, 6, 'Analisar a função da linguagem predominante nos textos em situações específicas de interlocução.'),
  ('LC', 20, 6, 'Reconhecer a importância do patrimônio linguístico para a preservação da memória e da identidade nacional.'),
  ('LC', 21, 7, 'Reconhecer em textos de diferentes gêneros, recursos verbais e não verbais utilizados com a finalidade de criar e mudar comportamentos e hábitos.'),
  ('LC', 22, 7, 'Relacionar, em diferentes textos, opiniões, temas, assuntos e recursos linguísticos.'),
  ('LC', 23, 7, 'Inferir em um texto quais são os objetivos de seu produtor e quem é seu público-alvo, pela análise dos procedimentos argumentativos utilizados.'),
  ('LC', 24, 7, 'Reconhecer no texto estratégias argumentativas empregadas para o convencimento do público, tais como a intimidação, sedução, comoção, chantagem, entre outras.'),
  ('LC', 25, 8, 'Identificar, em textos de diferentes gêneros, as marcas linguísticas que singularizam as variedades linguísticas sociais, regionais e de registro.'),
  ('LC', 26, 8, 'Relacionar as variedades linguísticas a situações específicas de uso social.'),
  ('LC', 27, 8, 'Reconhecer os usos da norma padrão da língua portuguesa nas diferentes situações de comunicação.'),
  ('LC', 28, 9, 'Reconhecer a função e o impacto social das diferentes tecnologias da comunicação e informação.'),
  ('LC', 29, 9, 'Identificar pela análise de suas linguagens, as tecnologias da comunicação e informação.'),
  ('LC', 30, 9, 'Relacionar as tecnologias de comunicação e informação ao desenvolvimento das sociedades e ao conhecimento que elas produzem.'),
  ('CH', 1, 1, 'Interpretar historicamente e/ou geograficamente fontes documentais acerca de aspectos da cultura.'),
  ('CH', 2, 1, 'Analisar a produção da memória pelas sociedades humanas.'),
  ('CH', 3, 1, 'Associar as manifestações culturais do presente aos seus processos históricos.'),
  ('CH', 4, 1, 'Comparar pontos de vista expressos em diferentes fontes sobre determinado aspecto da cultura.'),
  ('CH', 5, 1, 'Identificar as manifestações ou representações da diversidade do patrimônio cultural e artístico em diferentes sociedades.'),
  ('CH', 6, 2, 'Interpretar diferentes representações gráficas e cartográficas dos espaços geográficos.'),
  ('CH', 7, 2, 'Identificar os significados histórico-geográficos das relações de poder entre as nações.'),
  ('CH', 8, 2, 'Analisar a ação dos estados nacionais no que se refere à dinâmica dos fluxos populacionais e no enfrentamento de problemas de ordem econômico-social.'),
  ('CH', 9, 2, 'Comparar o significado histórico-geográfico das organizações políticas e socioeconômicas em escala local, regional ou mundial.'),
  ('CH', 10, 2, 'Reconhecer a dinâmica da organização dos movimentos sociais e a importância da participação da coletividade na transformação da realidade histórico-geográfica.'),
  ('CH', 11, 3, 'Identificar registros de práticas de grupos sociais no tempo e no espaço.'),
  ('CH', 12, 3, 'Analisar o papel da justiça como instituição na organização das sociedades.'),
  ('CH', 13, 3, 'Analisar a atuação dos movimentos sociais que contribuíram para mudanças ou rupturas em processos de disputa pelo poder.'),
  ('CH', 14, 3, 'Comparar diferentes pontos de vista, presentes em textos analíticos e interpretativos, sobre situação ou fatos de natureza histórico-geográfica acerca das instituições sociais, políticas e econômicas.'),
  ('CH', 15, 3, 'Avaliar criticamente conflitos culturais, sociais, políticos, econômicos ou ambientais ao longo da história.'),
  ('CH', 16, 4, 'Identificar registros sobre o papel das técnicas e tecnologias na organização do trabalho e/ou da vida social.'),
  ('CH', 17, 4, 'Analisar fatores que explicam o impacto das novas tecnologias no processo de territorialização da produção.'),
  ('CH', 18, 4, 'Analisar diferentes processos de produção ou circulação de riquezas e suas implicações socioespaciais.'),
  ('CH', 19, 4, 'Reconhecer as transformações técnicas e tecnológicas que determinam as várias formas de uso e apropriação dos espaços rural e urbano.'),
  ('CH', 20, 4, 'Selecionar argumentos favoráveis ou contrários às modificações impostas pelas novas tecnologias à vida social e ao mundo do trabalho.'),
  ('CH', 21, 5, 'Identificar o papel dos meios de comunicação na construção da vida social.'),
  ('CH', 22, 5, 'Analisar as lutas sociais e conquistas obtidas no que se refere às mudanças nas legislações ou nas políticas públicas.'),
  ('CH', 23, 5, 'Analisar a importância dos valores éticos na estruturação política das sociedades.'),
  ('CH', 24, 5, 'Relacionar cidadania e democracia na organização das sociedades.'),
  ('CH', 25, 5, 'Identificar estratégias que promovam formas de inclusão social.'),
  ('CH', 26, 6, 'Identificar em fontes diversas o processo de ocupação dos meios físicos e as relações da vida humana com a paisagem.'),
  ('CH', 27, 6, 'Analisar de maneira crítica as interações da sociedade com o meio físico, levando em consideração aspectos históricos e(ou) geográficos.'),
  ('CH', 28, 6, 'Relacionar o uso das tecnologias com os impactos socioambientais em diferentes contextos histórico-geográficos.'),
  ('CH', 29, 6, 'Reconhecer a função dos recursos naturais na produção do espaço geográfico, relacionando-os com as mudanças provocadas pelas ações humanas.'),
  ('CH', 30, 6, 'Avaliar as relações entre preservação e degradação da vida no planeta nas diferentes escalas.'),
  ('CN', 1, 1, 'Reconhecer características ou propriedades de fenômenos ondulatórios ou oscilatórios, relacionando-os a seus usos em diferentes contextos.'),
  ('CN', 2, 1, 'Associar a solução de problemas de comunicação, transporte, saúde ou outro, com o correspondente desenvolvimento científico e tecnológico.'),
  ('CN', 3, 1, 'Confrontar interpretações científicas com interpretações baseadas no senso comum, ao longo do tempo ou em diferentes culturas.'),
  ('CN', 4, 1, 'Avaliar propostas de intervenção no ambiente, considerando a qualidade da vida humana ou medidas de conservação, recuperação ou utilização sustentável da biodiversidade.'),
  ('CN', 5, 2, 'Dimensionar circuitos ou dispositivos elétricos de uso cotidiano.'),
  ('CN', 6, 2, 'Relacionar informações para compreender manuais de instalação ou utilização de aparelhos, ou sistemas tecnológicos de uso comum.'),
  ('CN', 7, 2, 'Selecionar testes de controle, parâmetros ou critérios para a comparação de materiais e produtos, tendo em vista a defesa do consumidor, a saúde do trabalhador ou a qualidade de vida.'),
  ('CN', 8, 3, 'Identificar etapas em processos de obtenção, transformação, utilização ou reciclagem de recursos naturais, energéticos ou matérias-primas, considerando processos biológicos, químicos ou físicos neles envolvidos.'),
  ('CN', 9, 3, 'Compreender a importância dos ciclos biogeoquímicos ou do fluxo de energia para a vida, ou da ação de agentes ou fenômenos que podem causar alterações nesses processos.'),
  ('CN', 10, 3, 'Analisar perturbações ambientais, identificando fontes, transporte e(ou) destino dos poluentes ou prevendo efeitos em sistemas naturais, produtivos ou sociais.'),
  ('CN', 11, 3, 'Reconhecer benefícios, limitações e aspectos éticos da biotecnologia, considerando estruturas e processos biológicos envolvidos em produtos biotecnológicos.'),
  ('CN', 12, 3, 'Avaliar impactos em ambientes naturais decorrentes de atividades sociais ou econômicas, considerando interesses contraditórios.'),
  ('CN', 13, 4, 'Reconhecer mecanismos de transmissão da vida, prevendo ou explicando a manifestação de características dos seres vivos.'),
  ('CN', 14, 4, 'Identificar padrões em fenômenos e processos vitais dos organismos, como manutenção do equilíbrio interno, defesa, relações com o ambiente, sexualidade, entre outros.'),
  ('CN', 15, 4, 'Interpretar modelos e experimentos para explicar fenômenos ou processos biológicos em qualquer nível de organização dos sistemas biológicos.'),
  ('CN', 16, 4, 'Compreender o papel da evolução na produção de padrões, processos biológicos ou na organização taxonômica dos seres vivos.'),
  ('CN', 17, 5, 'Relacionar informações apresentadas em diferentes formas de linguagem e representação usadas nas ciências físicas, químicas ou biológicas, como texto discursivo, gráficos, tabelas, relações matemáticas ou linguagem simbólica.'),
  ('CN', 18, 5, 'Relacionar propriedades físicas, químicas ou biológicas de produtos, sistemas ou procedimentos tecnológicos às finalidades a que se destinam.'),
  ('CN', 19, 5, 'Avaliar métodos, processos ou procedimentos das ciências naturais que contribuam para diagnosticar ou solucionar problemas de ordem social, econômica ou ambiental.'),
  ('CN', 20, 6, 'Caracterizar causas ou efeitos dos movimentos de partículas, substâncias, objetos ou corpos celestes.'),
  ('CN', 21, 6, 'Utilizar leis físicas e(ou) químicas para interpretar processos naturais ou tecnológicos inseridos no contexto da termodinâmica e(ou) do eletromagnetismo.'),
  ('CN', 22, 6, 'Compreender fenômenos decorrentes da interação entre a radiação e a matéria em suas manifestações em processos naturais ou tecnológicos, ou em suas implicações biológicas, sociais, econômicas ou ambientais.'),
  ('CN', 23, 6, 'Avaliar possibilidades de geração, uso ou transformação de energia em ambientes específicos, considerando implicações éticas, ambientais, sociais e/ou econômicas.'),
  ('CN', 24, 7, 'Utilizar códigos e nomenclatura da química para caracterizar materiais, substâncias ou transformações químicas.'),
  ('CN', 25, 7, 'Caracterizar materiais ou substâncias, identificando etapas, rendimentos ou implicações biológicas, sociais, econômicas ou ambientais de sua obtenção ou produção.'),
  ('CN', 26, 7, 'Avaliar implicações sociais, ambientais e/ou econômicas na produção ou no consumo de recursos energéticos ou minerais, identificando transformações químicas ou de energia envolvidas nesses processos.'),
  ('CN', 27, 7, 'Avaliar propostas de intervenção no meio ambiente aplicando conhecimentos químicos, observando riscos ou benefícios.'),
  ('CN', 28, 8, 'Associar características adaptativas dos organismos com seu modo de vida ou com seus limites de distribuição em diferentes ambientes, em especial em ambientes brasileiros.'),
  ('CN', 29, 8, 'Interpretar experimentos ou técnicas que utilizam seres vivos, analisando implicações para o ambiente, a saúde, a produção de alimentos, matérias primas ou produtos industriais.'),
  ('CN', 30, 8, 'Avaliar propostas de alcance individual ou coletivo, identificando aquelas que visam à preservação e a implementação da saúde individual, coletiva ou do ambiente.'),
  ('MT', 1, 1, 'Reconhecer, no contexto social, diferentes significados e representações dos números e operações - naturais, inteiros, racionais ou reais.'),
  ('MT', 2, 1, 'Identificar padrões numéricos ou princípios de contagem.'),
  ('MT', 3, 1, 'Resolver situação-problema envolvendo conhecimentos numéricos.'),
  ('MT', 4, 1, 'Avaliar a razoabilidade de um resultado numérico na construção de argumentos sobre afirmações quantitativas.'),
  ('MT', 5, 1, 'Avaliar propostas de intervenção na realidade utilizando conhecimentos numéricos.'),
  ('MT', 6, 2, 'Interpretar a localização e a movimentação de pessoas/objetos no espaço tridimensional e sua representação no espaço bidimensional.'),
  ('MT', 7, 2, 'Identificar características de figuras planas ou espaciais.'),
  ('MT', 8, 2, 'Resolver situação-problema que envolva conhecimentos geométricos de espaço e forma.'),
  ('MT', 9, 2, 'Utilizar conhecimentos geométricos de espaço e forma na seleção de argumentos propostos como solução de problemas do cotidiano.'),
  ('MT', 10, 3, 'Identificar relações entre grandezas e unidades de medida.'),
  ('MT', 11, 3, 'Utilizar a noção de escalas na leitura de representação de situação do cotidiano.'),
  ('MT', 12, 3, 'Resolver situação-problema que envolva medidas de grandezas.'),
  ('MT', 13, 3, 'Avaliar o resultado de uma medição na construção de um argumento consistente.'),
  ('MT', 14, 3, 'Avaliar proposta de intervenção na realidade utilizando conhecimentos geométricos relacionados a grandezas e medidas.'),
  ('MT', 15, 4, 'Identificar a relação de dependência entre grandezas.'),
  ('MT', 16, 4, 'Resolver situação-problema envolvendo a variação de grandezas, direta ou inversamente proporcionais.'),
  ('MT', 17, 4, 'Analisar informações envolvendo a variação de grandezas como recurso para a construção de argumentação.'),
  ('MT', 18, 4, 'Avaliar propostas de intervenção na realidade envolvendo variação de grandezas.'),
  ('MT', 19, 5, 'Identificar representações algébricas que expressem a relação entre grandezas.'),
  ('MT', 20, 5, 'Interpretar gráfico cartesiano que represente relações entre grandezas.'),
  ('MT', 21, 5, 'Resolver situação-problema cuja modelagem envolva conhecimentos algébricos.'),
  ('MT', 22, 5, 'Utilizar conhecimentos algébricos/geométricos como recurso para a construção de argumentação.'),
  ('MT', 23, 5, 'Avaliar propostas de intervenção na realidade utilizando conhecimentos algébricos.'),
  ('MT', 24, 6, 'Utilizar informações expressas em gráficos ou tabelas para fazer inferências.'),
  ('MT', 25, 6, 'Resolver problema com dados apresentados em tabelas ou gráficos.'),
  ('MT', 26, 6, 'Analisar informações expressas em gráficos ou tabelas como recurso para a construção de argumentos.'),
  ('MT', 27, 7, 'Calcular medidas de tendência central ou de dispersão de um conjunto de dados expressos em uma tabela de frequências de dados agrupados (não em classes) ou em gráficos.'),
  ('MT', 28, 7, 'Resolver situação-problema que envolva conhecimentos de estatística e probabilidade.'),
  ('MT', 29, 7, 'Utilizar conhecimentos de estatística e probabilidade como recurso para a construção de argumentação.'),
  ('MT', 30, 7, 'Avaliar propostas de intervenção na realidade utilizando conhecimentos de estatística e probabilidade.')
) AS v(area, codigo, competencia, descricao)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;

-- Disciplinas (15)
INSERT INTO disciplina (area_id, nome)
SELECT a.id, v.nome
FROM (VALUES
  ('LC', 'Língua Portuguesa'),
  ('LC', 'Literatura'),
  ('LC', 'Inglês'),
  ('LC', 'Espanhol'),
  ('LC', 'Artes'),
  ('LC', 'Educação Física'),
  ('LC', 'Tecnologias da Informação e Comunicação'),
  ('CH', 'História'),
  ('CH', 'Geografia'),
  ('CH', 'Filosofia'),
  ('CH', 'Sociologia'),
  ('CN', 'Física'),
  ('CN', 'Química'),
  ('CN', 'Biologia'),
  ('MT', 'Matemática')
) AS v(area, nome)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;

-- Conteúdos (objetos de conhecimento) (58)
INSERT INTO conteudo (disciplina_id, nome)
SELECT d.id, v.nome
FROM (VALUES
  ('LC', 'Língua Portuguesa', 'Gêneros textuais e funções da linguagem'),
  ('LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade'),
  ('LC', 'Língua Portuguesa', 'Variação linguística e norma-padrão'),
  ('LC', 'Literatura', 'Texto literário e contexto de produção'),
  ('LC', 'Inglês', 'Interpretação de texto em língua inglesa'),
  ('LC', 'Espanhol', 'Interpretação de texto em língua espanhola'),
  ('LC', 'Artes', 'Produção e recepção de textos artísticos'),
  ('LC', 'Educação Física', 'Práticas corporais e cultura corporal'),
  ('LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação'),
  ('CH', 'História', 'Brasil Colônia'),
  ('CH', 'História', 'Brasil Império'),
  ('CH', 'História', 'Brasil República'),
  ('CH', 'História', 'Antiguidade e Idade Média'),
  ('CH', 'História', 'Idade Moderna e Contemporânea'),
  ('CH', 'História', 'Povos indígenas, africanos e diversidade cultural'),
  ('CH', 'Geografia', 'Geografia física e questões ambientais'),
  ('CH', 'Geografia', 'Espaço agrário, indústria e economia'),
  ('CH', 'Geografia', 'Espaço urbano e população'),
  ('CH', 'Geografia', 'Geopolítica e cartografia'),
  ('CH', 'Filosofia', 'Filosofia antiga e medieval'),
  ('CH', 'Filosofia', 'Filosofia moderna e contemporânea'),
  ('CH', 'Sociologia', 'Cultura, identidade e movimentos sociais'),
  ('CH', 'Sociologia', 'Trabalho e sociedade'),
  ('CH', 'Sociologia', 'Cidadania, Estado e direitos'),
  ('CH', 'Sociologia', 'Tecnologia, mídia e sociedade'),
  ('CN', 'Física', 'Mecânica: movimento e forças'),
  ('CN', 'Física', 'Energia, trabalho e potência'),
  ('CN', 'Física', 'Gravitação e astronomia'),
  ('CN', 'Física', 'Eletricidade e magnetismo'),
  ('CN', 'Física', 'Ondas, óptica e radiação'),
  ('CN', 'Física', 'Calor e termodinâmica'),
  ('CN', 'Química', 'Transformações e reações químicas'),
  ('CN', 'Química', 'Materiais, ligações e propriedades'),
  ('CN', 'Química', 'Soluções, ácidos, bases e sais'),
  ('CN', 'Química', 'Oxirredução, eletroquímica e termoquímica'),
  ('CN', 'Química', 'Radioatividade'),
  ('CN', 'Química', 'Cinética e equilíbrio químico'),
  ('CN', 'Química', 'Química orgânica'),
  ('CN', 'Química', 'Química ambiental e energia'),
  ('CN', 'Biologia', 'Citologia e bioquímica'),
  ('CN', 'Biologia', 'Genética e biotecnologia'),
  ('CN', 'Biologia', 'Evolução'),
  ('CN', 'Biologia', 'Ecologia e meio ambiente'),
  ('CN', 'Biologia', 'Fisiologia humana e animal'),
  ('CN', 'Biologia', 'Saúde e doenças'),
  ('MT', 'Matemática', 'Aritmética e conjuntos numéricos'),
  ('MT', 'Matemática', 'Razão, proporção e regra de três'),
  ('MT', 'Matemática', 'Porcentagem e matemática financeira'),
  ('MT', 'Matemática', 'Análise combinatória'),
  ('MT', 'Matemática', 'Sequências e progressões'),
  ('MT', 'Matemática', 'Grandezas, medidas e escalas'),
  ('MT', 'Matemática', 'Geometria plana'),
  ('MT', 'Matemática', 'Geometria espacial'),
  ('MT', 'Matemática', 'Funções'),
  ('MT', 'Matemática', 'Equações e inequações'),
  ('MT', 'Matemática', 'Estatística'),
  ('MT', 'Matemática', 'Probabilidade'),
  ('MT', 'Matemática', 'Leitura de gráficos e tabelas')
) AS v(area, disciplina, nome)
JOIN area a ON a.sigla = v.area
JOIN disciplina d ON d.area_id = a.id AND d.nome = v.disciplina
ON CONFLICT DO NOTHING;

-- Escala da TRI por área: nota = intercepto + inclinação × θ
-- (calibrada contra as notas oficiais de participantes dos microdados)
INSERT INTO escala_tri (area_id, ano, intercepto, inclinacao, calibracao_participantes, calibracao_rmse, calibracao_erro_maximo)
SELECT a.id, v.ano, v.intercepto, v.inclinacao, v.participantes, v.rmse, v.erro_maximo
FROM (VALUES
  ('LC', 2022, 499.9775, 108.0844, 3000, 0.0287, 0.0518),
  ('CH', 2022, 501.4891, 112.3103, 3000, 0.029, 0.0501),
  ('CN', 2022, 501.1432, 113.102, 3000, 0.0291, 0.0509),
  ('MT', 2022, 500.0212, 129.6453, 3000, 0.0289, 0.0519)
) AS v(area, ano, intercepto, inclinacao, participantes, rmse, erro_maximo)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;

-- Questões (185)
INSERT INTO questao (area_id, disciplina_id, conteudo_id, habilidade_id, ano, numero, dia, lingua_estrangeira,
                     codigo_item_inep, enunciado, gabarito, tri_a, tri_b, tri_c, motivo_exclusao_tri, metodo_classificacao)
SELECT a.id, d.id, c.id, h.id, v.ano, v.numero, v.dia, v.lingua,
       v.codigo_item, v.enunciado, v.gabarito, v.tri_a, v.tri_b, v.tri_c, v.motivo, v.metodo
FROM (VALUES
  -- Questão 1 (espanhol) · LC · Espanhol · Interpretação de texto em língua espanhola · H7
  (2022, 1, 1, 'espanhol', 'LC', 'Espanhol', 'Interpretação de texto em língua espanhola', 7, 118230, '![](/midia/enem/2022/q001-espanhol/b8e76f18-f22d-4401-bf90-fd34c74e07e5.jpg)

Disponível em: www.inali.gob.mx. Acesso em: 2 dez. 2018.

Esse cartaz tem a função social de', 'E', 1.79286, -0.35288, 0.09108, NULL, 'habilidade'),
  -- Questão 1 (ingles) · LC · Inglês · Interpretação de texto em língua inglesa · H8
  (2022, 1, 1, 'ingles', 'LC', 'Inglês', 'Interpretação de texto em língua inglesa', 8, 111918, 'As my official bio reads, I was made in Cuba, assembled in Spain, and imported to the United States — meaning my mother, seven months pregnant, and the rest of my family arrived as exiles from Cuba to Madrid, where I was born. Less than two months later, we emigrated once more and settled in New York City, then eventually in Miami, where I was raised and educated. Although technically we lived in the United States, the Cuban community was culturally insular in Miami during the 1970s, bonded together by the trauma of exile. What’s more, it seemed that practically everyone was Cuban: my teachers, my classmates, the mechanic, the bus driver. I didn’t grow up feeling different or treated as a minority. The few kids who got picked on in my grade school were the ones with freckles and funny last names like Dawson and O’Neil.
Ao relatar suas vivências, o autor destaca o(a)', 'D', 3.71022, 0.34919, 0.20287, NULL, 'habilidade'),
  -- Questão 2 (espanhol) · LC · Espanhol · Interpretação de texto em língua espanhola · H6
  (2022, 2, 1, 'espanhol', 'LC', 'Espanhol', 'Interpretação de texto em língua espanhola', 6, 118252, '**Pequeño hermano**

Es, no cabe duda, el instrumento más presente y más poderoso de todos los que entraron en nuestras vidas. Ni la televisión ni el ordenador, no hablemos ya del obsoleto fax o de las agendas o los libros electrónicos, ha tenido tal influencia, tal predicamento sobre nosotros. El móvil somos nosotros mismos. Todo desactivado e inerte, inocuo, ya les digo. Y de repente, tras un viaje y tres o cuatro imprudentes fotos, salta un aviso en la pantalla. Con sonido, además, pese a que tengo también todas las alertas desactivadas. Y mi monstruo doméstico me dice: Tienes un recuerdo nuevo. Lo repetiré: tienes un recuerdo nuevo. ¿Y tú qué sabes? ¿Y a ti, máquina demoníaca, qué te importa? ¿Cómo te atreves a decirme qué son o no son mis recuerdos? ¿Qué es esta intromisión, este descaro? El pequeño hermano lo sabe casi todo. Sólo hay una esperanza: que la obsolescencia programada mate antes al pequeño hermano y que nosotros sigamos vivos, con los recuerdos que nos dé la gana.

FERNANDEZ, D, Disponível em: www.lavanguardia.com.

Acesso em:  5 dez. 2018 (adaptado).

No texto, autor faz uma crítica ao(à)', 'D', 1.93731, 0.91995, 0.14292, NULL, 'habilidade'),
  -- Questão 2 (ingles) · LC · Inglês · Interpretação de texto em língua inglesa · H7
  (2022, 2, 1, 'ingles', 'LC', 'Inglês', 'Interpretação de texto em língua inglesa', 7, 111835, 'Two hundred years ago, Jane Austen lived in a world where single men boasted vast estates; single ladies were expected to speak several languages, sing and play the piano. In both cases, it was, of course, advantageous if you looked good too. So, how much has — or hasn’t — changed? Dating apps opaquely outline the demands of today’s relationship market; users ruminate long and hard over their choice of pictures and what they write in their biographies to hook in potential lovers, and that’s just your own profile. What do you look for in a future partner’s profile — potential signifiers of a popular personality, a good job, a nice car? These apps are a poignant reminder of the often classist attitudes we still adopt, as well as the financial and aesthetic expectations we demand from potential partners.
O texto aborda relações interpessoais com o objetivo de', 'C', 2.64617, 0.79049, 0.1896, NULL, 'habilidade'),
  -- Questão 3 (espanhol) · LC · Espanhol · Interpretação de texto em língua espanhola · H8
  (2022, 3, 1, 'espanhol', 'LC', 'Espanhol', 'Interpretação de texto em língua espanhola', 8, 76318, 'En los suburbios de La Habana, llaman al amigo _mi tierra o mi sangre._En Caracas, el amigo es _mi pana o mi llave_: _pana_, por panadería, la fuente del buen pan para las hambres del alma; y _llave_ por…—_Llave_, por _llave_—me dice Mario Benedetti. Y me cuenta que cuando vivía en Buenos Aires, en los tiempos del terror, él llevaba cinco llaves ajenas en su llavero: cinco llaves, de cinco casas, de cinco amigos: las llaves que lo salvaron.

GALEANO, E. **El libro de los abrazos**. Madri: Siglo Veintiuno, 2015.

Nesse texto, o autor demonstra como as diferentes expressões existentes em espanhol para se referir a “amigo” variam em função', 'C', 0.56882, 1.97791, 0.12768, NULL, 'habilidade'),
  -- Questão 3 (ingles) · LC · Inglês · Interpretação de texto em língua inglesa · H6
  (2022, 3, 1, 'ingles', 'LC', 'Inglês', 'Interpretação de texto em língua inglesa', 6, 140767, '![Tirinha apresentada em quatro quadrinhos. O primeiro quadrinho apresenta um castelo localizado no alto de uma colina, cercado por floresta e montanhas. O sol está baixo. Duas pessoas conversam dentro dele. Uma delas diz: “Now that you are my bride, you will never leave this castle!”. A outra exclama: “Wow! Your library is amazing!”. No segundo quadrinho, apresentados de forma estilizada, estão um homem grandalhão usando chapéu e segurando um bastão, e uma mulher com os cabelos presos em rabo de cavalo e usando um vestido. Ele fala: “Beyond the castle is a high wall with no gate, and beyond that is a deep, dark forest with no path”. A mulher, que está retirando um livro de uma estante alta e repleta de livros, comenta: “I suppose it’s my library too, now we’re married”. No terceiro quadrinho, o homem ergue o dedo indicador e diz: “The forest is crawling with ravenous wolves, malignant birds and the spirits of long-dead travellers.”. A mulher passa por ele carregando três livros e exclama: “So many books! I can’t believe my luck!”. No último quadrinho, o homem, que está transformado em um ser com asas e patas e voando em direção contrária à da mulher, fala: “When the sun sets, I transform into a wild beast and soar into the night, seized by a terrible bloodlust!”. A mulher está sentada em um banco ao lado de dois livros. Ela segura um terceiro livro nas mãos à frente do rosto enquanto fala: “Ok. I’ll stay here and read. See you in the morning.”.](/midia/enem/2022/q003-ingles/fileoutpart5.webp)


Nessa tirinha, o comportamento da mulher expressa', 'B', 4.34313, 0.36871, 0.44865, NULL, 'habilidade'),
  -- Questão 4 (espanhol) · LC · Espanhol · Interpretação de texto em língua espanhola · H5
  (2022, 4, 1, 'espanhol', 'LC', 'Espanhol', 'Interpretação de texto em língua espanhola', 5, 140527, '**Los niños de nuestro olvido**

Escribo sobre un destino  
Que apenas puedo tocar  
En tanto un niño se inventa  
Con pegamento un hogar

Mientras busco las palabras  
Para hacer esta canción  
Un niño esquiva las balas  
Que buscan su corazón

Acurrucado en mí calle  
Duerme un niño y la piedad  
Arma lejos un pesebre  
Y juega a la navidad

Arma lejos un pesebre  
Y juega a la navidad  
Y juega a la navidad  
Y juega, y juega, y juega…

La niñez de nuestro olvido  
Pide limosna en un bar  
Y lava tu parabrisas  
Por un peso, por un pan

Si las flores del futuro  
Crecen con tanto dolor  
Seguramente mañana  
Será un mañana sin sol

No texto, a expressão “un mañana sin sol” é usada para concluir uma critica ao(à)', 'A', 1.12895, -0.11509, 0.20583, NULL, 'habilidade'),
  -- Questão 4 (ingles) · LC · Inglês · Interpretação de texto em língua inglesa · H5
  (2022, 4, 1, 'ingles', 'LC', 'Inglês', 'Interpretação de texto em língua inglesa', 5, 140731, '## A Teen’s View of Social Media
Instagram is made up of all photos and videos. There is the home page that showcases the posts from people you follow, an explore tab which offers posts from accounts all over the world, and your own page, with a notification tab to show who likes and comments on your posts.
It has some downsides though. It is known to make many people feel insecure or down about themselves because the platform showcases the highlights of everyone’s lives, while rarely showing the negatives. This can make one feel like their life is not going as well as others, contributing to the growing rates of anxiety or depression in many teens today. There is an underlying desire for acceptance through the number of likes or followers one has.
O termo “downsides” introduz a ideia de que o Instagram é responsável por', 'D', 2.88489, 0.49591, 0.18224, NULL, 'habilidade'),
  -- Questão 5 (espanhol) · LC · Espanhol · Interpretação de texto em língua espanhola · H5
  (2022, 5, 1, 'espanhol', 'LC', 'Espanhol', 'Interpretação de texto em língua espanhola', 5, 140567, '![](/midia/enem/2022/q005-espanhol/2a1a630d-3c73-4b12-81e5-219ee4f917b7.jpg)

MURIG. Disponível em: https://murigcolectivafeminista.wordpress.com.

Acesso em: 26 out. 2021(adaptado)

No texto, as palavras “crianzas” e “tribu” são usadas para', 'A', 1.95054, -0.11616, 0.18874, NULL, 'habilidade'),
  -- Questão 5 (ingles) · LC · Inglês · Interpretação de texto em língua inglesa · H6
  (2022, 5, 1, 'ingles', 'LC', 'Inglês', 'Interpretação de texto em língua inglesa', 6, 140626, 'I tend the mobile now like an injured bird
We text, text, text our significant words.
I re-read your first, your second, your third, Look for your small xx, feeling absurd.
The codes we send arrive with a broken chord.
I try to picture your hands, their image is blurred.
Nothing my thumbs press will ever be heard.
Nesse poema de Carol Duffy, o eu lírico evidencia um sentimento de', 'E', 2.55762, 0.57348, 0.15419, NULL, 'habilidade'),
  -- Questão 6 · LC · Língua Portuguesa · Variação linguística e norma-padrão · H25
  (2022, 6, 1, NULL, 'LC', 'Língua Portuguesa', 'Variação linguística e norma-padrão', 25, 60382, '**Urgência emocional**

Se tudo é para ontem, se a vida engata uma primeira e sai em disparada, se não há mais tempo para paradas estratégicas, caímos fatalmente no vício de querer que os amores sejam igualmente resolvidos num átimo de segundo. Temos pressa para ouvir “eu te amo”. Não vemos a hora de que fiquem estabelecidas as regras de convívio: somos namorados, ficantes, casados, amantes? Urgência emocional. Uma cilada. Associamos diversas palavras ao AMOR: paixão, romance, sexo, adrenalina, palpitação. Esquecemos, no entanto, da palavra que viabiliza esse sentimento: “paciência”. Amor sem paciência não vinga. Amor não pode ser mastigado e engolido com emergência, com fome desesperada. É uma refeição que pode durar uma vida.

MEDEIROS, M. Disponível em: http:/porumavidasimples.blogspot.com.br. Acesso em: 20 ago. 2017 (adaptado).

Nesse texto de opinião, as marcas linguísticas revelam uma situação distensa e de pouca formalidade, o que se evidencia pelo(a)', 'E', 1.77346, 0.68047, 0.08704, NULL, 'habilidade'),
  -- Questão 7 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H22
  (2022, 7, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 22, 111929, '**TEXTO I**

![](/midia/enem/2022/q007/01826c2e-3f38-4271-86de-f85c879bd70f.webp)

Disponível em: https://amigodobicho.wordpress.com/. Acesso em: 10 dez. 2017.

**TEXTO II**

**Nas ruas, na cidade e no parque**

Ninguém nunca prendeu o Delegado. O vaivém de rua em rua e sua longa vida são relembrados e recontados. Exemplo de sobrevivência, liderança, inteligência canina, desde pequenininho seu focinho negro e seus olhos delineados desenharam um mapa mental olfativo-visual de Lavras. Corria de quem precisava correr e se aproximava de quem não lhe faria mal, distinguia este daquele. Assim, tornou-se um cão comunitário. Nunca se soube por que escolheu a rua, talvez lhe tenham feito mal dentro de quatro paredes. Idoso, teve câncer e desapareceu. O querido foi procurado pela cidade inteira por duas protetoras, mas nunca encontrado.

**COSTA, A. R. N. Viver o amor aos cães: Parque Francisco de Assis. Carmo do Cachoeira: Irdin, 2014 (adaptado).**

Os dois textos abordam a temática de animais de rua, porém, em relação ao Texto I, o Texto II', 'A', 2.15283, 1.51639, 0.20049, NULL, 'habilidade'),
  -- Questão 8 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H23
  (2022, 8, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 23, 118120, 'É ruivo? Tem olhos azuis? É homem ou mulher? Usa chapéu? Quem jogou Cara a Cara na infância sabe de cor o roteiro de perguntas para adivinhar quem é o personagem misterioso do seu oponente.

Agora, o jogo está prestes a ganhar uma nova versão. A designer polonesa Zuzia Kozerska-Girard está desenvolvendo uma variação do _Guess Who?_ (nome do Cara a Cara em inglês), em que as personalidades do tabuleiro são, na verdade, mulheres notáveis da história e  
da atualidade, como a artista Frida Kahlo, a ativista Malala Yousafzai, a astronauta Valentina Tereshkova e a aviadora Amelia Earhart. O _Who’s She?_ (“Quem é ela?”, em português) traz, no total, 28 mulheres que representam diversas profissões, nacionalidades e idades.

A ideia é que, em vez de perguntar sobre a aparência das personagens, as questões sejam direcionadas aos feitos delas: ganhou algum Nobel, fez alguma descoberta? Para cada personagem há um cartão com fatos divertidos e interessantes sobre sua vida. Uma campanha entrou no ar com o objetivo de arrecadar dinheiro para desenvolver o _Who’s She?_. A meta inicial era reunir 17 mil dólares. Oito dias antes de a campanha acabar, o projeto já angariou quase 350 mil dólares.

A chegada do jogo à casa do comprador varia de acordo com a quantia doada — quanto mais você doou, mais rápido vai poder jogar.

Disponível em: www.super.abril.com.br. Acesso em: 4 dez. 2018 (adaptado).

Ao divulgar a adaptação do jogo para questões relativas a ações e habilidades de mulheres notáveis, o texto busca', 'A', 1.53331, 2.16698, 0.23705, NULL, 'habilidade'),
  -- Questão 9 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H24
  (2022, 9, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 24, 66576, '![](/midia/enem/2022/q009/b1a38f51-88f6-4686-9189-734021ee6771.webp)

**Disponível em: : www.portaldapropaganda.com.br. Acesso em: 29 out. 2013 (adaptado).**

Para convencer o público-alvo sobre a necessidade de um trânsito mais seguro, essa peça publicitária apela para o(a)', 'A', 2.66065, -0.7431, 0.13295, NULL, 'habilidade'),
  -- Questão 10 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H28
  (2022, 10, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 28, 49544, 'Ciente de que, no campo da criação, as inovações tecnológicas abrem amplo leque de possibilidades – ao permitir, e mesmo estimular, que o artista explore a fundo, em seu processo criativo, questões como a aleatoriedade, o acaso, a não linearidade e a hipermídia –, Leo Cunha comenta que, no que tange ao campo da divulgação, as alternativas são ainda mais evidentes: “Afinal, é imensa a capacidade de reprodução, multiplicação e compartilhamento das obras artísticas/culturais. Ao mesmo tempo, ganham dimensão os dilemas envolvidos com a questão da autoria, dos direitos autorais, da reprodução e intervenção não autorizadas, entre outras questões”. Já segundo a professora Yacy-Ara Froner, o uso de ferramentas tecnológicas não pode ser visto como um fim em si mesmo. Isso porque computadores, samplers, programas de imersão, internet e intranet, vídeo, televisão, rádio, GPD etc. são apenas suportes com os quais os artistas exercem sua imaginação.

SILVA JR., M. G. Movidas pela dúvida. **Minas faz Ciências**, n. 52, dez-fev. 2013 (adaptado).

Segundo os autores citados no texto, a expansão de possibilidades no campo das manifestações artísticas promovida pela internet pode pôr em risco o(a)', 'C', 2.43974, 1.15872, 0.12513, NULL, 'habilidade'),
  -- Questão 11 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H29
  (2022, 11, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 29, 41810, 'Ora, sempre que surge uma nova técnica, ela quer demonstrar que revogará as regras e coerções que presidiram o nascimento de todas as outras invenções do passado. Ela se pretende orgulhosa e única. Como se a nova técnica carreasse com ela, automaticamente, para seus novos usuários, uma propensão natural a fazer economia de qualquer aprendizagem. Como se ela se preparasse para varrer tudo que a precedeu, ao mesmo tempo transformando em analfabetos todos os que ousassem repeli-la.

Fui testemunha dessa mudança ao longo de toda a minha vida. Ao passo que, na realidade, é o contrário que acontece. Cada nova técnica exige uma longa iniciação numa nova linguagem, ainda mais longa na medida em que nosso espírito é formatado pela utilização das linguagens que precederam o  nascimento da recém-chegada.

ECO, U.; CARRIÈRE, J.-C. **Não contem com o fim do livro**. Rio de Janeiro: Record, 2010 (adaptado).

O texto revela que, quando a sociedade promove o desenvolvimento de uma nova técnica, o que mais impacta seus usuários é a', 'A', 0.92958, 0.15096, 0.01173, NULL, 'habilidade'),
  -- Questão 12 · LC · Língua Portuguesa · Variação linguística e norma-padrão · H27
  (2022, 12, 1, NULL, 'LC', 'Língua Portuguesa', 'Variação linguística e norma-padrão', 27, 42674, '**Papos**

— Me disseram…  
— Disseram-me.  
— Hein?  
— O correto é “disseram-me”. Não “me disseram”.  
— Eu falo como quero. E te digo mais… Ou é “digo-te”?  
— O quê?  
— Digo-te que você…  
— O “te” e o “você” não combinam.  
— Lhe digo?  
— Também não. O que você ia me dizer?  
— Que você está sendo grosseiro, pedante e chato. \[…\]  
— Dispenso as suas correções. Vê se esquece-me. Falo como bem entender. Mais uma correção e eu…  
— O quê?  
— O mato.  
— Que mato?  
— Mato-o. Mato-lhe. Mato você. Matar-lhe-ei-te. Ouviu bem? Pois esqueça-o e para-te. Pronome no lugar certo é elitismo!  
— Se você prefere falar errado…  
— Falo como todo mundo fala. O importante é me entenderem. Ou entenderem-me?

VERISSIMO, L. F. **Comédias para se ler na escola**.  
Rio de Janeiro: Objetiva, 2001 (adaptado).

Nesse texto, o uso da norma-padrão defendido por um dos personagens torna-se inadequado em razão do(a)', 'B', 2.26956, 0.51892, 0.2337, NULL, 'habilidade'),
  -- Questão 13 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H30
  (2022, 13, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 30, 120622, 'São vários os fatores, internos e externos, que influenciam os hábitos das pessoas no acesso à internet, assim como nas práticas culturais realizadas na rede. A utilização das tecnologias de informação e comunicação está diretamente relacionada aos aspectos como conhecimento de seu uso, acesso à linguagem letrada, nível de instrução, escolaridade, letramento digital etc. Os que detêm tais recursos (os mais escolarizados) são os que mais acessam a rede e também os que possuem maior índice de acumulatividade das práticas. A análise dos dados nos possibilita dizer que a falta de acesso à rede repete as mesmas adversidades e exclusões já verificadas na sociedade brasileira no que se refere a analfabetos, menos escolarizados, negros população indígena e desempregados. Isso significa dizer que a internet, se não produz diretamente a exclusão, certamente a reproduz, tendo em vista que os que mais a acessam são justamente os mais jovens, escolarizados, remunerados, trabalhadores qualificados, homens e brancos.

**SILVA, F. A. B ZIVIANE, P; GHEZZI, D. R.** As tecnologias digitais e seus usos Brasília, Rio de Janeiro. Ipea. 2019 (adaptado)

Ao analisarem a correlação entre os hábitos e o perfil socioeconômico dos usuários da internet no Brasil, os
pesquisadores', 'B', 2.558, 0.65099, 0.12178, NULL, 'habilidade'),
  -- Questão 14 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H22
  (2022, 14, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 22, 42940, '**TEXTO I**  
A língua não é uma nomenclatura, que se apõe a uma realidade pré-categorizada, ela é que classifica a realidade. No léxico, percebe-se, de maneira mais imediata, o fato de que a língua condensa as experiências de um dado povo.

FIORIN, J. L Língua, modernidade e tradição. **Diversitas**, n. 2. mar-set 2014

**TEXTO II**  
As expressões coloquiais ainda estão impregnadas de discriminação contra os negros. Basta recordar algumas delas, como passar um “dia negro”, ter um “lado negro”, ser a “ovelha negra” da família ou praticar “magia negra”.

Disponível em: https://brasil.elpais.com Acesso em: 22 maio 2018.

O Texto II exemplifica o que se afirma no Texto I, na medida em que defende a ideia de que as escolhas lexicais são resultantes de um', 'D', 1.30734, -0.29879, 0.00797, NULL, 'habilidade'),
  -- Questão 15 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H4
  (2022, 15, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 4, 111926, '![](/midia/enem/2022/q015/8319bd69-f738-464b-bf9b-14f73e03df8f.webp)

Disponível em: www.facebook.com/senadofederal. Acesso em: 9 dez. 2017.

Considerando-se a função social dos posts, essa imagem evidencia a apropriação de outro gênero com o objetivo de', 'B', 2.48072, 0.89717, 0.27108, NULL, 'habilidade'),
  -- Questão 16 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H3
  (2022, 16, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 3, 141427, 'Ela era linda. Gostava de dançar, fazia teatro em São Paulo e sonhava ser atriz em Hollywood. Tinha 13 anos quando ganhou uma câmera de vídeo – e uma irmã. As duas se tornaram suas companheiras de experimentações. Adolescente, Elena vivia a criar filminhos e se empenhava em dirigir a pequena Petra nas cenas que inventava. Era exigente com a irmã. E acreditava no potencial da menina para satisfazer seus arroubos de diretora precoce. Por cinco anos, integrou algumas das melhores companhias paulistanas de teatro e participou de preleções para filmes e trabalhos na TV. Nunca foi chamada. No início de 1990, Elena tinha 20 anos quando se mudou para Nova York para cursar artes cênicas e batalhar uma chance no mercado americano. Deslocada, ansiosa, frustrada após alguns testes de elenco malsucedidos, decepcionada com a ausência de reconheci mento e vitimada por uma depressão que se agravava com a falta de perspectivas, Elena pôs fim à vida no segundo semestre. Petra tinha 7 anos. Vinte anos depois, é ela, a irmã caçula, que volta a Nova York para percorrer os últimos passos da irmã, vasculhar seus arquivos e transformar suas memórias em imagem e poesia.

_Elena_ é um filme sobre a irmã que parte e sobre a irmã que fica. É um filme sobre a busca, a perda, a saudade, mas também sobre o encontro, o legado, a memória. Um filme sobre a Elena de Petra e sobre a Petra de Elena, sobre o que ficou de uma na outra e, essencialmente, um filme sobre a delicadeza.

**VANUCHI, C. Época, 19 out. 2012 (adaptado)**

O texto é exemplar de um gênero discursivo que cumpre a função social de', 'E', 2.40522, 2.28139, 0.1137, NULL, 'habilidade'),
  -- Questão 17 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H4
  (2022, 17, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 4, 141464, '**PALAVRA**  
As gramáticas classificam as palavras em substantivo, adjetivo, verbo, advérbio, conjunção, pronome, numeral, artigo e preposição. Os poetas classificam as palavras pela alma porque gostam de brincar com elas, e para brincar com elas é preciso ter intimidade primeiro. É a alma da palavra que define, explica, ofende ou elogia, se coloca entre o significante e o significado para dizer o que quer, dar sentimento às coisas, fazer sentido. A palavra nuvem chove. A palavra triste chora. A palavra sono dorme. A palavra tempo passa. A palavra fogo queima. A palavra faca corta. A palavra carro corre. A palavra “palavra” diz. O que quer.

E nunca desdiz depois. As palavras tem corpo e alma, mas são diferentes das pessoas em vários pontos. As palavras dizem o que querem, está dito, e pronto.

**FALCÃO, A. Pequeno dicionário de palavras ao vento. São Paulo: Salamandra, 2013 (adaptado).**

Esse texto, que simula um verbete para a palavra “palavra”, constitui-se como um poema porque', 'B', 0.94658, 1.25172, 0.21415, NULL, 'habilidade'),
  -- Questão 18 · LC · Língua Portuguesa · Gêneros textuais e funções da linguagem · H18
  (2022, 18, 1, NULL, 'LC', 'Língua Portuguesa', 'Gêneros textuais e funções da linguagem', 18, 67229, 'Morte lenta ao luso infame que inventou a calçada portuguesa. Maldito D. Manuel l e sua corja de tenentes Eusébios. Quadrados de pedregulho irregular socados à mão. À mäo! É claro que ia soltar, ninguém reparou que ia soltar? Branco, preto, branco, preto, as ondas do mar de Copacabana. De que me servem as ondas do mar de Copacabana? Me deem chão liso, sem protuberâncias calcárias. Mosaico estúpido. Mania de mosaico. Joga concreto em cima e aplaina. Buraco, cratera, pedra solta, bueiro-bomba. Depois dos setenta, a vida se transforma numa interminável corrida de obstáculos. A queda é a maior ameaça para o idoso. “Idoso”, palavra odienta. Pior, só “terceira idade”. A queda separa a velhice da senilidade extrema. O tombo destrói a cadeia que liga a cabeça aos pés. Adeus, corpo. Em casa, vou de corrimão em corrimão, tateio móveis e paredes, e tomo banho sentado. Da poltrona para a janela, da janela para a cama, da cama para a poltrona, da poltrona para a janela. Olha aí, outra vez, a pedrinha traiçoeira atrás de me pegar. Um dia eu caio, hoje não.

**TORRES. F. Fim. São Paulo: Cia das Letras, 2013.**

O recurso que caracteriza a organização estrutural desse texto é o(a)', 'A', 2.64295, 1.76932, 0.18786, NULL, 'habilidade'),
  -- Questão 19 · LC · Educação Física · Práticas corporais e cultura corporal · H9
  (2022, 19, 1, NULL, 'LC', 'Educação Física', 'Práticas corporais e cultura corporal', 9, 120124, 'Pisoteamento, arrastão, empurra-empurra, agressões, vandalismo e até furto a um torcedor que estava caído no asfalto após ter sido atropelado nas imediações do estádio do Maracanã. As cenas de selvageria tiveram como estopim a invasão de milhares de torcedores sem ingresso, que furaram o bloqueio policial e transformaram o estádio em terra de ninguém. Um reflexo não só do quadro de insegurança que assola o Rio de Janeiro, mas também de como a violência social se embrenha pelo esporte mais popular do país. Em 2017, foram registrados 104 episódios de violência no futebol brasileiro, que resultaram em 11 mortes de torcedores. Desde 1995, quando 101 torcedores ficaram feridos e um morreu durante uma batalha campal no estádio do Pacaembu, autoridades brasileiras têm focado as ações de enfrentamento à violência no futebol em grupos uniformizados, alguns proibidos de frequentar estádios. Porém, a postura meramente repressiva contra torcidas organizadas é ineficaz em uma sociedade que registra mais de 61000 homicídios por ano. “É impossível dissociar a escalada de violência no futebol do panorama de desordem pública, social, econômica e política vivida pelo país”, de acordo com um doutor em sociologia do esporte.

**Disponível em: https://brasil.elpais.com. Acesso em: 22 jun. 2019 (adaptado).**

Nesse texto, a violência no futebol está caracterizada como um(a)', 'C', 2.93292, 0.03337, 0.17638, NULL, 'habilidade'),
  -- Questão 20 · LC · Educação Física · Práticas corporais e cultura corporal · H10
  (2022, 20, 1, NULL, 'LC', 'Educação Física', 'Práticas corporais e cultura corporal', 10, 45201, 'Seis em cada dez pessoas com 15 anos ou mais não praticam esporte ou atividade física. São mais de 100 milhões de sedentários. Esses são dados do estudo _Práticas de esporte e atividade física_, da Pnad 2015, realizado pelo IBGE. A falta de tempo e de interesse são os principais motivos apontados para o sedentarismo. Paralelamente, 73,3% das pessoas de 15 anos ou mais afirmaram que o poder público deveria investir em esporte ou atividades físicas. Observou-se uma relação direta entre escolaridade e renda na realização de esportes ou atividades físicas. Enquanto 17,3% das pessoas que não tinham instrução realizavam diversas práticas corporais, esse percentual chegava a 56,7% das pessoas com superior completo. Entre as pessoas que têm práticas de esporte e atividade física regulares, o percentual de praticantes ia de 31,1%, na classe sem rendimento, a 65,2%, na classe de cinco salários mínimos ou mais. A falta de tempo foi mais declarada pela população adulta, com destaque entre as pessoas de 25 a 39 anos. Entre os adolescentes de 15 a 17 anos, o principal motivo foi não gostarem ou não quererem. Já o principal motivo para praticar esporte, declarado por 11,2 milhões pessoas, foi relaxar ou se divertir, seguido de melhorar a qualidade de vida ou o bem-estar. A falta de instalação esportiva acessível ou nas proximidades foi um motivo pouco citado, demonstrando que a não prática estaria menos associada à infraestrutura disponível.

**Disponível em: www.esporte.gov.br. Acesso em: 9 ago. 2017 (adaptado).**

Com base na pesquisa e em uma visão ampliada de saúde, para a prática regular de exercícios ter influência significativa na saúde dos brasileiros, é necessário o desenvolvimento de estratégias que', 'C', 2.64453, 1.04534, 0.13269, NULL, 'habilidade'),
  -- Questão 21 · LC · Literatura · Texto literário e contexto de produção · H15
  (2022, 21, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 15, 140827, '**A escrava**

– Admira-me —, disse uma senhora de sentimentos sinceramente abolicionistas —; faz-me até pasmar como se possa sentir, e expressar sentimentos escravocratas, no presente século, no século dezenove! A moral religiosa e a moral cívica aí se erguem, e falam bem alto esmagando a hidra que envenena a família no mais sagrado santuário seu, e desmoraliza, e avilta a nação inteira! Levantai os olhos ao Gólgota, ou percorrei-os em torno da sociedade, e dizei-me:

— Para que se deu em sacrifício, o Homem Deus, que ali exalou seu derradeiro alento? Ah! Então não era verdade que seu sangue era o resgate do homem! É então uma mentira abominável ter esse sangue comprado a liberdade!? E depois, olhai a sociedade… Não vedes o abutre que a corrói constantemente!… Não sentis a desmoralização que a enerva, o cancro que a destrói?

Por qualquer modo que encaremos a escravidão, ela é, e sempre será um grande mal. Dela a decadência do comércio; porque o comércio e a lavoura caminham de mãos dadas, e o escravo não pode fazer florescer a lavoura; porque o seu trabalho é forçado.

REIS, M. F. **Úrsula outras obras**. Brasília: Câmara dos Deputados, 2018

Inscrito na estética romântica da literatura brasileira, o conto descortina aspectos da realidade nacional no século XIX ao', 'B', 2.05337, 0.67994, 0.17382, NULL, 'habilidade'),
  -- Questão 22 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H22
  (2022, 22, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 22, 39101, '**TEXTO I**

**Projeto Mural Eletrônico desenvolvido no INT, semelhante a um totem, promete tornar o acesso à informação disponível para todos**

A inclusão de pessoas com deficiência se constituiu um dos principais desafios e preocupações para a sociedade ao longo das últimas décadas. E o uso da tecnologia tem se revelado um aliado fundamental em muitas iniciativas voltadas para essa área. Exemplo disso é uma das recentes criações do Instituto Nacional de Tecnologia (INT) – unidade de pesquisa do Ministério da Ciência, Tecnologia, Inovações e Comunicações (MCTIC). Ali, com o objetivo de que as diferenças entre pessoas não sejam sinônimo de obstáculos no acesso à informação ou na comunicação, engenheiros e tecnólogos vêm trabalhando no desenvolvimento do projeto Mural Eletrônico.

O Mural Eletrônico nasceu da necessidade de promover a inclusão nas escolas. Com interface multimídia e interativa, todos têm a possibilidade de acessar o Mural Eletrônico. Por meio do equipamento, podem ser disponibilizados vídeos com Libras, leitura sonora de textos, que também estarão acessíveis em uma plataforma de braile dinâmico, ao lado do teclado.

**KIFFER, D. Inclusão ampla e irrestita. Rio Pesquisa, n. 36, set. 2016 (adaptado).**

**Texto II**

**Projeto Surdonews, desenvolvido na UFRJ, garante acesso de surdos à informação e contribui para sua “inclusão cientifica”**

Para não permitir que a falta de informação seja um fator para o isolamento e a inacessibilidade da comunidade surda, a jornalista e pesquisadora Roberta Savedra Schiaffino criou o projeto “Surdonews: montando os quebra-cabeças das notícias para o surdo”. Trata-se de uma página no Facebook, com notícias constantemente atualizadas e apresentadas por surdos em Libras, e veiculadas por meio de videos.

A ideia de criar o projeto surgiu quando Roberta, ela própria surda profunda, ainda cursava o mestrado. Para isso, ela procurou traçar um diagnóstico do conhecimento informal entre as pessoas com surdez. Ela entrevistou cinquenta alunos surdos do ensino fundamental e viu que eles tinham muita dificuldade de ler, além de não captar a notícia falada. “Isso é muito grave, pois 90% do saber de um indivíduo vem do conhecimento informal, adquirido em feiras científicas, conversas, cinema, teatro, incluindo a mídia, por todas as suas possibilidades disseminadoras”, explica a pesquisadora. “Prezamos pelo conteúdo científico em nossas pautas. Contudo, independentemente disso, nosso principal trabalho é, além de informar e atualizar, fazer com que os textos não sejam empobrecidos no processo de ‘tradução’ e, sim, acessíveis”.

**KIFFER, D. Comunicação sem barreiras. Rio Pesquisa, n. 37, dez. 2016 (adaptado).**

Considerando-se o tema tecnologias e acessibilidade, os textos I e II aproximam-se porque apresentam projetos que', 'E', 2.07003, 1.19098, 0.13567, NULL, 'habilidade'),
  -- Questão 23 · LC · Literatura · Texto literário e contexto de produção · H16
  (2022, 23, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 16, 9716, 'Mas seu olhar verde, inconfundível, impressionante, iluminava com sua luz misteriosa as sombrias arcadas superciliares, que pareciam queimadas por ela, dizia logo a sua origem cruzada e decantada através das misérias e dos orgulhos de homens de aventura, contadores de histórias fantásticas, e de mulheres caladas e sofredoras que acompanhavam os maridos e amantes através das matas intermináveis, expostas às febres, às feras, às cobras do sertão indecifrável, ameaçador e sem fim, que elas percorriam com a ambição única de um “pouso” onde pudessem viver, por alguns dias, a vida ilusória de família e de lar, sempre no encalço dos homens, enfebrados pela procura do ouro e do diamante.

PENNA, C. **Fronteira**. Rio de Janeiro: Tecnoprint, s/d.

Ao descrever os olhos de Maria Santa, o narrador estabelece correlações que refletem a', 'E', 0.9036, 1.48142, 0.05685, NULL, 'habilidade'),
  -- Questão 24 · LC · Língua Portuguesa · Variação linguística e norma-padrão · H26
  (2022, 24, 1, NULL, 'LC', 'Língua Portuguesa', 'Variação linguística e norma-padrão', 26, 141440, '**O complexo de falar difícil**

O que importa realmente é que o(a) detentor(a) do notável saber jurídico saiba quando e como deve fazer uso desse português versão 2.0, até porque não tem necessidade de alguém entrar numa padaria de manhã com aquela cara de sono falando o seguinte: “Por obséquio, Vossa Senhoria teria a hipotética possibilidade de estabelecer com minha pessoa uma relação de compra e venda, mediante as imposições dos códigos Civil e do Consumidor, para que seja possível a obtenção de 10 pãezinhos em temperatura estável para que a relação pecuniária no valor de R$ 5,00, seja plenamente legitima e capaz de saciar minha fome matinal?”

O problema é que temos uma cultura de valorizar quem demonstra ser inteligente ao invés de valorizar quem é. Pela nossa lógica, todo mundo que fala difícil tende a ser mais inteligente do que quem valoriza o simples, e 99,9% das pessoas que estivessem na padaria iriam ficar boquiabertas se alguém fizesse uso das palavras que eu disse acima em plenas 7 da manhã em vez de dizer: “Bom dia! O senhor poderia me vender cinco reais de pão francês?”.

Agora entramos na parte interessante: o que realmente é falar difícil? Simplesmente fazer uso de palavras que a maioria não faz ideia do que seja é um ato de falar difícil? Eu penso que não, mas é assim que muita gente age. Falar difícil é fazer uso do simples, mas com coerência e coesão, deixar tudo amarradinho gramaticamente falando. Falar difícil pode fazer alguém parecer inteligente, mas não por muito tempo. É claro que em alguns momentos na verdade vários não temos como fugir do português rebuscado, do juridiquês propriamente dito, como no caso de documentos jurídicos entre outros.

**ARAÚJO, H. Disponível em: https://diariojurista.com.br. Acesso em: 20 nov. 2021 (adaptado).**

Nesse artigo de opinião, ao fazer uso de uma fala rebuscada no exemplo da compra do pão, o autor evidencia a importância de(a)', 'E', 2.72306, 0.13273, 0.20082, NULL, 'habilidade'),
  -- Questão 25 · LC · Educação Física · Práticas corporais e cultura corporal · H9
  (2022, 25, 1, NULL, 'LC', 'Educação Física', 'Práticas corporais e cultura corporal', 9, 141203, 'A conquista da medalha de prata por Rayssa Leal, no _skate street_ nos Jogos Olímpicos, é exemplo da representatividade feminina no esporte, avalia a âncora do jornal da rede de televisão da CNN. A apresentadora, que também anda de skate, celebrou a vitória da brasileira, que entrou para a história como a atleta mais nova a subir num pódio defendendo o Brasil. “Essa representatividade do esporte nos Jogos faz pensarmos que não temos que ficar nos encaixando em nenhum lugar. Posso gostar de passar notícia e, mesmo assim, gostar de skate, subir montanha, mergulhar, andar de bike, fazer yoga”. Temos que parar de ficar enquadrando as pessoas dentro das regras. A gente vive num padrão no qual a menina ganha boneca, mas por que também não fazer um esporte de aventura? Por que o homem pode se machucar, cair de joelhos, e a menina tem que estar sempre lindinha dentro de um padrão? Acabamos limitando os talentos das pessoas”, afirmou a jornalista, sobre a prática do skate por mulheres.

**Disponível em: www.cnnbrasil.com.br. Acesso em: 31 out. 2021 (adaptado).**

O discurso da jornalista traz questionamentos sobre a relação da conquista da skatista com a', 'C', 1.71461, -0.15137, 0.18763, NULL, 'habilidade'),
  -- Questão 26 · LC · Língua Portuguesa · Gêneros textuais e funções da linguagem · H19
  (2022, 26, 1, NULL, 'LC', 'Língua Portuguesa', 'Gêneros textuais e funções da linguagem', 19, 96502, '**Assentamento**

Assentamento  
Zanza daqui  
Zanza pra acolá  
Fim de feira, periferia afora  
A cidade não mora mais em mim  
Francisco, Serafim  
Vamos embora  
Ver o capim  
Ver o baobá  
Vamos ver a campina quando flora  
A piracema, rios contravim  
Binho, Bel, Bia, Quim  
Vamos embora  
Quando eu morrer  
Cansado de guerra  
Morro de bem  
Com a minha terra:  
Cana, caqui  
Inhame, abóbora  
Onde só vento se semeava outrora  
Amplidão, nação, sertão sem fim  
Ó Manuel, Miguilim  
Vamos embora

**BUARQUE, C. As cidades. Rio de Janeiro: RCA, 1998 (fragmento).**

Nesse texto, predomina a função poética da linguagem. Entretanto, a função emotiva pode ser identificada no verso:', 'C', 1.14926, -0.51604, 0.00912, NULL, 'habilidade'),
  -- Questão 27 · LC · Língua Portuguesa · Texto argumentativo e intencionalidade · H21
  (2022, 27, 1, NULL, 'LC', 'Língua Portuguesa', 'Texto argumentativo e intencionalidade', 21, 141410, '![](/midia/enem/2022/q027/033b9d75-d730-4b7f-abfd-79a09bc6c18b.webp)

Disponível em: http://viva-porto.pt. Acesso em: 24 nov. 2021 (adaptado).

A articulação entre os elementos verbais e os não verbais do texto tem como propósito desencadear a', 'B', 2.62079, 0.2007, 0.10693, NULL, 'habilidade'),
  -- Questão 28 · LC · Língua Portuguesa · Gêneros textuais e funções da linguagem · H20
  (2022, 28, 1, NULL, 'LC', 'Língua Portuguesa', 'Gêneros textuais e funções da linguagem', 20, 120626, '**As línguas silenciadas do Brasil**

Para aprender a língua de seu povo, o professor Txaywa Pataxó, de 29 anos, precisou estudar os fatores que, por diversas vezes, quase provocaram a extinção da língua patxôhã. Mergulhou na história do Brasil e descobriu fatos violentos que dispersaram os pataxós, forçados a abandonar a própria língua para escapar da perseguição. “Os pataxós se espalharam, principalmente, depois do Fogo de 1951. Queimaram tudo e expulsaram a gente das nossas terras. Isso constrange o nosso povo até hoje”, conta Txaywa, estudante da Universidade Federal de Minas Gerais e professor na aldeia Barra Velha, região de Porto Seguro (BA). Mais de quatro décadas depois, membros da etnia retornaram ao antigo local e iniciaram um movimento de recuperação da língua patxôhã. Os filhos de Sameary Pataxó já são fluentes — e ela, que se mudou quando já era adulta para a aldeia, tenta aprender um pouco com eles. “É a nossa identidade. Você diz quem você é por meio da sua língua”, afirma a professora de ensino fundamental sobre a importância de restaurar a língua dos pataxós. O patxôhã está entre as  
línguas indígenas faladas no Brasil: o IBGE estimou 274 línguas no último censo. A publicação Povos indígenas no Brasil 2011/2016, do Instituto Socioambiental, calcula 160. Antes da chegada dos portugueses, elas totalizavam mais de mil.

**Disponível em: https://brasil.elpais.com. Acesso em: 11 jun. 2019 (adaptado).**

O movimento de recuperação da língua patxôhã assume um caráter identitário peculiar na medida em que', 'B', 0.82491, 0.89707, 0.03562, NULL, 'habilidade'),
  -- Questão 29 · LC · Literatura · Texto literário e contexto de produção · H15
  (2022, 29, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 15, 111954, '**Esaú e Jacó**

Bárbara entrou, enquanto o pai pegou da viola e passou ao patamar de pedra, à porta da esquerda. Era uma criaturinha leve e breve, saia bordada, chinelinha no pé. Não se lhe podia negar um corpo airoso. Os cabelos, apanhados no alto da cabeça por um pedaço de fita enxovalhada, faziam-lhe um solidéu natural, cuja borla era suprida por um raminho de arruda. Já vai nisto um pouco de sacerdotisa. O mistério estava nos olhos. Estes eram opacos, não sempre nem tanto que não fossem também lúcidos e agudos, e neste último estado eram igualmente compridos; tão compridos e tão agudos que entravam pela gente abaixo, revolviam o coração e tornavam cá fora, prontos para nova entrada e outro revolvimento. Não te minto dizendo que as duas sentiram tal ou qual fascinação. Bárbara interrogou-as; Natividade disse ao que vinha e entregou-lhe os retratos dos filhos e os cabelos cortados, por lhe haverem dito que bastava.

– Basta, confirmou Bárbara. Os meninos são seus filhos?

– São.

ASSIS, M. **Obra completa**. Rio de Janeiro: Nova Aguilar, 1994.

No relato da visita de duas mulheres ricas a uma vidente no Morro do Castelo, a ironia — um dos traços mais representativos da narrativa machadiana — consiste no', 'D', 0.78612, 1.19878, 0.06459, NULL, 'habilidade'),
  -- Questão 30 · LC · Literatura · Texto literário e contexto de produção · H15
  (2022, 30, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 15, 26545, 'A senhora manifestava-se por atos, por gestos, e sobretudo por um certo silêncio, que amargava, que esfolava. Porém desmoralizar escancaradamente o marido, não era com ela.\[…\]

As negras receberam ordem para meter no serviço a gente do tal compadre Silveira: as cunhadas, ao fuso; os cunhados, ao campo, tratar do gado com os vaqueiros; a mulher e as irmãs, que se ocupassem da ninhada. Margarida não tivera filhos, e como os desejasse com a força de suas vontades, tratava sempre bem aos pequenitos e às mães que os estavam criando. Não era isso uma sentimentalidade cristã, uma ternura, era o egoísta e cru instinto da maternidade, obrando por mera simpatia carnal. Quanto ao pai do lote (referia-se ao Antônio), esse que fosse ajudar ao vaqueiro das bestas.

Ordens dadas, o Quinquim referendava. Cada um moralizava o outro, para moralizar-se.

PAIVA, M. O. **Dona Guidinha do Poço**. Rio de Janeiro: Tecnoprint, s/d

No trecho do romance naturalista, a forma como o narrador julga comportamentos e emoções das personagens femininas revela influência do pensamento', 'C', 4.15101, 1.348, 0.0928, NULL, 'habilidade'),
  -- Questão 31 · LC · Literatura · Texto literário e contexto de produção · H16
  (2022, 31, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 16, 89149, 'Era o êxodo da seca de 1898. Uma ressurreição de cemitérios antigos — esqueletos redivivos, com o aspecto terroso e o fedor das covas podres.

Os fantasmas estropiados como que iam dançando, de tão trôpegos e trêmulos, num passo arrastado de quem leva as pernas, em vez de ser levado por elas.

Andavam devagar, olhando para trás, como quem quer voltar. Não tinham pressa em chegar, porque não sabiam aonde iam. Expulsos de seu paraíso por espadas de fogo, iam, ao acaso, em descaminhos, no arrastão dos maus fados.

Fugiam do sol e o sol guiava-os nesse forçado nomadismo.

Adelgaçados na magreira cômica, cresciam, como se o vento os levantasse. E os braços afinados desciam-lhes aos joelhos, de mãos abanando.

Vinham escoteiros. Menos os hidrópicos — de ascite consecutiva à alimentação tóxica — com os fardos das barrigas alarmantes.

Não tinham sexo, nem idade, nem condição nenhuma. Eram os retirantes. Nada mais.

ALMEIDA, J. A. **A bagaceira**. Rio de Janeiro: J. Olympio, 1978.

Os recursos composicionais que inserem a obra no chamado “Romance de 30” da literatura brasileira manifestam-se aqui no(a)', 'A', 1.05565, 0.45772, 0.03348, NULL, 'habilidade'),
  -- Questão 32 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H3
  (2022, 32, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 3, 44570, '![](/midia/enem/2022/q032/fe5e06b1-daf2-46e0-9485-5b2f32e59641.webp)

**Disponível em: https://tab.uol.com.br/. Acesso em: 25 ago. 2017 (adaptado).**

O texto sobre os chamados nativos digitais traz informações com a função de', 'A', 1.04632, 0.65812, 0.23788, NULL, 'habilidade'),
  -- Questão 33 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H1
  (2022, 33, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 1, 86703, '**Notas**

Soluços, lágrimas, casa armada, veludo preto nos portais, um homem que veio vestir o cadáver, outro que tomou a medida do caixão, caixão, essa, tocheiros, convites, convidados que entravam, lentamente, a passo surdo, e apertavam a mão à família, alguns tristes, todos sérios e calados, padre e sacristão, rezas, aspersões d’água benta, o fechar do caixão a prego e martelo, seis pessoas que o tomam da essa, e o levantam, e o descem a custo pela escada, não obstante os gritos, soluços e novas lágrimas da família, e vão até o coche fúnebre, e o colocam em cima e traspassam e apertam as corrêas, o rodar do coche, o rodar dos carros, um a um… Isto que parece um simples inventário, eram notas que eu havia tomado para um capítulo triste e vulgar que não escrevo.

ASSIS, M. **Memórias Póstumas de Brás Cubas**. Disponível em: www.domíniopúblico.gov.br. Acesso em: 25 jul, 2022.

O recurso linguístico que permite o Machado de Assis considerar o capítulo de Memórias Póstumas de Brás Cubas como inventário é a:', 'A', 2.08922, 0.96392, 0.23742, NULL, 'habilidade'),
  -- Questão 34 · LC · Educação Física · Práticas corporais e cultura corporal · H11
  (2022, 34, 1, NULL, 'LC', 'Educação Física', 'Práticas corporais e cultura corporal', 11, 119767, 'Criado há cerca de 20 anos na Califórnia, o mountainboard é um esporte de aventura que utiliza uma espécie de skate off-road para realizar manobras similares às das modalidades de snowboard, surf e do próprio skate. A atividade chegou ao Brasil em 1997 e hoje possui centenas de praticantes, um circuito nacional respeitável e mais de uma dezena de pistas espalhadas pelo país. Segundo consta na história oficial, o mountainboard foi criado por praticantes de snowboard que sentiam falta de praticar o esporte nos períodos sem neve. Para isso, eles desenvolveram um equipamento bem simples: uma prancha semelhante ao modelo utilizado na neve (menor e um pouco menos flexível), com dois eixos bem resistentes, alças para encaixar os pés e quatro pneus com câmaras de ar para regular a velocidade que pode ser alcançada em diferentes condições. Com essa configuração, o esporte se mostrou possível em diversos tipos de terreno: grama, terra, pedras, asfalto e areia. Além desses pisos, também é possível procurar pelas próprias trilhas para treinar as manobras.

**Disponível em: www.webventure.com.br. Acesso em: 19 jun. 2019.**

A história da prática do mountainboard representa uma das principais marcas das atividades de aventura, caracterizada pela', 'D', 2.11177, -0.55865, 0.18565, NULL, 'habilidade'),
  -- Questão 35 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H1
  (2022, 35, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 1, 140898, '**Ser cronista**

Sei que não sou, mas tenho meditado ligeiramente no assunto.

Crônica é um relato? É uma conversa? É um resumo de um estado de espírito? Não sei, pois antes de começar a escrever para o Jornal do Brasil, eu só tinha escrito romances e contos.

E também sem perceber, à medida que escrevia para aqui, ia me tornando pessoal demais, correndo o risco deem breve publicar minha vida passada e presente, o que não pretendo. Outra coisa notei: basta eu saber que estou escrevendo para jornal, isto é, para algo aberto facilmente por todo o mundo, e não para um livro, que só é aberto por quem realmente quer, para que, sem mesmo sentir, o modo de escrever se transforme. Não é que me desagrade mudar, pelo contrário. Mas queria que fossem mudanças mais profundas e interiores que não viessem a se refletir no escrever. Mas mudar só porque isso é uma coluna ou uma crônica? Ser mais leve só porque o leitor assim o quer? Divertir? Fazer passar uns minutos de leitura? E outra coisa: nos meus livros quero profundamente a comunicação profunda comigo e com o leitor. Aqui no Jornal apenas falo com o leitor e agrada-me que ele fique agradado. Vou dizer a verdade: não estou contente.

**LISPECTOR, C. In: A descoberta do mundo. Rio de Janeiro: Rocco, 1999.**

No texto, ao refletir sobre a atividade de cronista, a autora questiona características do gênero crônica, como', 'C', 1.69478, 2.32558, 0.16355, NULL, 'habilidade'),
  -- Questão 36 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H2
  (2022, 36, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 2, 111961, '**Projeto na Câmara de BH quer a vacinação gratuita de cães contra a leishmaniose**

_A doença é grave e vem causando preocupação na região metropolitana da capital mineira_

Ela é uma doença grave, transmitida pela picada do mosquito-palha, e afeta tanto os seres humanos quanto os cachorros: a leishmaniose. Por ser um problema de saúde pública, a doença pode ganhar uma ação preventiva importante, caso um projeto de lei seja aprovado na Câmara Municipal de Belo Horizonte (CMBH). Diante do alto número de casos da doença na Grande BH, a Comissão de Saúde e Saneamento da CMBH aprovou a proposta de realização de campanhas públicas de vacinação gratuita de cães contra a leishmaniose, tema do PL 404/17, apreciado pelo colegiado em reunião ordinária, no dia 6 de dezembro.

**Disponível em: https://www.revistaencontro.com.br/. Acesso em: 11 dez. 2017.**

Essa notícia, além de cumprir sua função informativa, assume o papel de', 'C', 1.6838, 0.70642, 0.29621, NULL, 'habilidade'),
  -- Questão 37 · LC · Tecnologias da Informação e Comunicação · Gêneros digitais e tecnologias da comunicação · H30
  (2022, 37, 1, NULL, 'LC', 'Tecnologias da Informação e Comunicação', 'Gêneros digitais e tecnologias da comunicação', 30, 141390, '**“Vida perfeita” em redes sociais pode afetar a saúde mental**

Nas várias redes sociais que povoam a internet, os chamados digital influencers estão sempre felizes e pregam a felicidade como um estilo de vida. Essas pessoas espalham conteúdo para milhares de seguidores, ditando tendências e mostrando um estilo de vida sonhando por muitos, como o corpo esbelto, viagens incríveis, casas deslumbrantes, carros novos e alegria em tempo integral, algo bem improvável de ocorrer o tempo todo, aponta Carla Furtado, mestre em psicologia e fundadora do Instituto Feliciência.

A problemática pode surgir com a busca incessante por essa felicidade, que gera efeitos colaterais em quem consome diariamente a “vida perfeita” de outros. Daí vem o conceito de positividade tóxica: a expressão tem sido usada para abordar uma espécie de pressão pela adoção de um discurso positivo,  aliada a uma vida editada para as redes sociais. Para manter a saúde mental e evitar ser atingido pela positividade tóxica, o uso racional das redes sociais é o mais indicado, aconselha a médica psiquiatra Renata Nayara Figueiredo, presidente da Associação Psiquiátrica de Brasília (APBr).

Disponível em: https://agenciabrasil.ebc.com.br. Acesso em: 21 nov. 2021  (adaptado).

Associada ao ideário de uma “vida perfeita”, a positividade tóxica mencionada no texto é um fenômeno social recente, que se constitui com base em', 'A', 1.54579, -0.30477, 0.00839, NULL, 'habilidade'),
  -- Questão 38 · LC · Artes · Produção e recepção de textos artísticos · H12
  (2022, 38, 1, NULL, 'LC', 'Artes', 'Produção e recepção de textos artísticos', 12, 120368, '**TEXTO I**

![](/midia/enem/2022/q038/951f4c93-65de-4b4b-af99-7d63a81bfee9.webp)

EL GRECO. **Laocoonte**. Óleo sobre tela, 1,37cm x 1,72cm.

National Gallery of Art, Washington, Estados Unidos, circa 1610-  
1614\. Disponível em: https://images.nga.gov. Acesso em: 28 jun  
2019 (adaptado).

**TEXTO II**

Essa impressionante obra apresenta o sacerdote Laocoonte sendo punido pelos deuses por tentar alertar os troianos da ameaça do Cavalo de Troia, que escondia um grupo de soldados gregos. Enviadas pelos deuses, serpentes marinhas são vistas matando Laocoonte e seus dois filhos como forma de punição.

KAY, A. In: FARTHING, S. (Org.). **Tudo sobre arte**.  
Rio de Janeiro: Sextante, 2011 (adaptado).

Produzida no início do século XVII, a obra maneirista distingue-se pela', 'B', 3.46434, 2.20555, 0.0675, NULL, 'habilidade'),
  -- Questão 39 · LC · Artes · Produção e recepção de textos artísticos · H13
  (2022, 39, 1, NULL, 'LC', 'Artes', 'Produção e recepção de textos artísticos', 13, 54528, '![](/midia/enem/2022/q039/f8b8fbe9-4995-4418-a831-315a156941c4.webp)

JUDD, D. **Sem título**. 1969.

Disponível em: https://dasartes.com.br. Acesso em: 16 jun. 2022.

Embora não fosse um grupo ou um movimento organizado, o Minimalismo foi um dos muitos rótulos (incluindo estruturas primárias, objetos unitários, arte ABC e Cool Art) aplicados pelos críticos para descrever estruturas aparentemente simples que alguns artistas estavam criando. Quando a arte minimalista começou a surgir, muitos críticos e um público opinativo julgaram-na fria, anônima e imperdoável. Os materiais industriais pré-fabricados frequentemente usados não pareciam “arte”.

DEMPSEY, A. **Estilos, escolhas e movimentos**. São Paulo: Cosac & Naify, 2003 (adaptado).

De acordo com os textos I e II, compreende-se que a obra minimalista é uma', 'E', 2.90825, 2.05309, 0.10359, NULL, 'habilidade'),
  -- Questão 40 · LC · Literatura · Texto literário e contexto de produção · H16
  (2022, 40, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 16, 6864, '**Firmo, o vaqueiro**

No dia seguinte, à hora em que saía o gado, estava eu debruçado à varanda quando vi o cafuzo que preparava o animal viajeiro:  
– Raimundinho, como vai ele?…  
De longe apontou a palhoça.  
– Sim.  
O braço caiu-lhe, olhou-me algum tempo comovido; depois, saltando para o animal, levou o polegar à boca fazendo estalar a unha nos dentes: “Às quatro da manhã…  
Atirei um verso e disse, para bulir com ele: Pega, velho! Não respondeu. Tio Firmo, mesmo velho e doente, não era homem para deixar um verso no chão… Fui ver, coitado!… estava morto. E deu de esporas para que eu não lhe visse as lágrimas.

NETTO, C. In: MARCHEZAN, L. G. (Org.).  
**O conto regionalista.** São Paulo: Martins Fontes, 2009.

A passagem registra um momento em que a expressividade lírica é reforçada pela', 'D', 0.57225, 0.0979, 0.01556, NULL, 'habilidade'),
  -- Questão 41 · LC · Literatura · Texto literário e contexto de produção · H17
  (2022, 41, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 17, 10776, '**O bebê de tarlatana rosa**

– \[…\] Na terça desliguei-me do grupo e caí no mar alto da depravação, só, com uma roupa leve por cima da pele e todos os maus instintos fustigados. De resto a cidade inteira estava assim. É o momento em que por trás das máscaras as meninas confessam paixões aos rapazes, é o instante em que as ligações mais secretas transparecem, em que a virgindade é dúbia e todos nós a achamos inútil, a honra uma caceteação, o bom senso uma fadiga. Nesse momento tudo é possível, os maiores absurdos, os maiores crimes; nesse momento há um riso que galvaniza os sentidos e o beijo se desata naturalmente.

Eu estava trepidante, com uma ânsia de acanalhar-me, quase mórbida. Nada de raparigas do galarim perfumadas e por demais conhecidas, nada do contato familiar, mas o deboche anônimo, o deboche ritual de chegar, pegar, acabar, continuar. Era ignóbil. Felizmente muita gente sofre do mesmo mal no carnaval.

RIO, J. **Dentro da noite**. São Paulo: Antíqua, 2002.

No texto, o personagem vincula ao carnaval atitudes e reações coletivas diante das quais expressa', 'B', 1.35922, -0.10494, 0.00701, NULL, 'habilidade'),
  -- Questão 42 · LC · Literatura · Texto literário e contexto de produção · H17
  (2022, 42, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 17, 90238, '**10 de maio**

Fui na delegacia e falei com o tenente. Que homem amavel! Se eu soubesse que ele era tão amavel, eu teria ido na delegacia na primeira intimação. \[…\] O tenente interessou-se pela educação dos meus filhos. Disse-me que a favela é um ambiente propenso, que as pessoas tem mais possibilidade de delinquir do que tornar-se util a patria e ao país. Pensei: se ele sabe disto, porque não faz  
um relatorio e envia para os politicos? O Senhor Janio Quadros, o Kubstchek, e o Dr. Adhemar de Barros? Agora falar para mim, que sou uma pobre lixeira. Não posso resolver nem as minhas dificuldades.  
… O Brasil precisa ser dirigido por uma pessoa que já passou fome. A fome tambem é professora.

Quem passa fome aprende a pensar no próximo, e nas crianças.

JESUS, C. M. **Quarto de despejo: diário de uma favelada**.  
São Paulo: Ática, 2014.

A partir da intimação recebida pelo filho de 9 anos, a autora faz uma reflexão em que transparece a', 'D', 1.32058, 0.69547, 0.07827, NULL, 'habilidade'),
  -- Questão 43 · LC · Literatura · Texto literário e contexto de produção · H17
  (2022, 43, 1, NULL, 'LC', 'Literatura', 'Texto literário e contexto de produção', 17, 78112, 'Vanda vinha do interior de Minas Gerais e de dentro de um livro de Charles Dickens. Sem dinheiro para criá-la, sua mãe a dera, com seus sete anos, a uma conhecida. Ao recebê-la, a mulher perguntou o que a garotinha gostava de comer. Anotou tudo num papel. Mal a mãe virou as costas, no entanto, a fulana amassou a lista e, como uma vilã de folhetim, decretou: “A partir de hoje, você não vai mais nem sentir o cheiro dessas comidas!”.

Vanda trabalhou lá até os quinze anos, quando recebeu a carta de uma prima com uma nota de cem cruzeiros, saiu de casa com a roupa do corpo e fugiu num ônibus para São Paulo.

Todas as vezes que eu e minha irmã a importunávamos com nossas demandas de criança mimada, ela nos contava histórias da infância de gata-borralheira, fazia-nos apertar seu nariz quebrado por uma das filhas da “patroa” com um rolo de amassar pão e nos expulsava da cozinha: “Sai pra lá, peste, e me deixa acabar essa janta”.

PRATA, A. **Nu de botas**. São Paulo: Cia. das Letras, 2013 (adaptado).

Pela ótica do narrador, a trajetória da empregada de sua casa assume um efeito expressivo decorrente', 'E', 0.76335, 0.46065, 0.00865, NULL, 'habilidade'),
  -- Questão 44 · LC · Artes · Produção e recepção de textos artísticos · H12
  (2022, 44, 1, NULL, 'LC', 'Artes', 'Produção e recepção de textos artísticos', 12, 81994, '**TEXTO I**

![](/midia/enem/2022/q044/510dde52-fd88-4c3a-88bd-cedac5510317.jpg)

SILVEIRA, R. **In absentia**, 1983. Instalação, 17ª Bienal de São Paulo. Disponível em: www.bienal.org.br. Acesso em: set. 2016 (adaptado).

**TEXTO II**

O termo ready-made foi criado por Marcel Duchamp (1887-1968) para designar um tipo de objeto, por ele inventado, que consiste em um ou mais artigos de uso cotidiano, produzidos em massa, selecionados sem critérios estéticos e expostos como obras de arte em espaços especializados (museus e galerias). Seu primeiro ready-made, de 1912, é uma roda de bicicleta montada sobre um banquinho  (Roda de bicicleta). Ao transformar qualquer objeto em obra de arte, o artista realiza uma crítica radical ao sistema da arte.

Disponível em: www.bienal.org.br. Acesso em: 1 set. 2016 (adaptado)

A instalação In absentia propõe um diálogo com o ready-made Roda de bicicleta, demonstrando que', 'C', 0.91022, 0.76591, 0.01172, NULL, 'habilidade'),
  -- Questão 45 · LC · Artes · Produção e recepção de textos artísticos · H14
  (2022, 45, 1, NULL, 'LC', 'Artes', 'Produção e recepção de textos artísticos', 14, 141261, 'O Recife fervilhava no começo da década de 1990, e os artistas trabalhavam para resgatar o prestígio da cultura pernambucana. Era preciso se inspirar, literalmente, nas raízes sobre as quais a cidade se construiu. Foi aí que, em 1992, com a publicação de um manifesto escrito pelo músico e jornalista Fred Zero Quatro, da banda Mundo Livre S/A, nasceu o manguebeat. O nome vem de “mangue”, vegetação típica da região, e “beat”, para representar as batidas e as influências musicais que o movimento abraçaria a partir dali. Era a hora e a vez de os caranguejos – aos quais os músicos recifenses gostavam de se comparar – mostrarem as caras: o maracatu e suas alfaias se misturaram com as batidas do hip-hop, as guitarras do rock, elementos eletrônicos e o sotaque recifense de Chico Science. A busca pelo novo rendeu uma perspectiva diferente do Brasil ao olhar para o Recife. A cidade deixou de ser o lugar apenas do frevo e do carnaval, transformando-se na ebulição musical que continua a acontecer mesmo após os 25 anos do lançamento do primeiro disco da Nação Zumbi, Da lama ao caos.

FORCIONI, G. et al. O mangue está de volta. **Revista Esquinas**, n. 87, set 2019 (adaptado).

Chico Science foi fundamental para a renovação da música pernambucana, fato que se deu pela', 'E', 2.31367, 0.48334, 0.18144, NULL, 'habilidade'),
  -- Questão 46 · CH · Geografia · Geografia física e questões ambientais · H26
  (2022, 46, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 26, 140506, 'Espera, resignado, o dia 13 daquele mês porque, em tal data, usança avoenga lhe faculta sondar o futuro, interrogando a providência. É a experiência tradicional de Santa Luzia. No dia 12 ao anoitecer expõe ao relento, em linha, seis pedrinhas de sal, que representam, em ordem sucessiva da esquerda para a direita, os seis meses vindouros, de janeiro a junho. Ao alvorecer de 13 observa-as: se estão intactas, pressagiam a seca; se a primeira apenas se deliu,  transmudada em aljôfar límpido, é certa a chuva em janeiro; se a segunda, em fevereiro; se a maioria ou todas, é inevitável O inverno benfazejo. Esta experiência é belíssima.

CUNHA, E. **Os sertões**. São Paulo: Editora Três, 1984.

No experimento descrito, a relação com a paisagem e com a religiosidade permite que o sertanejo seja', 'D', 0.98121, 1.34897, 0.06218, NULL, 'palavras-chave'),
  -- Questão 47 · CH · Filosofia · Filosofia moderna e contemporânea · H24
  (2022, 47, 1, NULL, 'CH', 'Filosofia', 'Filosofia moderna e contemporânea', 24, 83806, 'Sempre que a relevância do discurso entra em jogo, a questão torna-se política por definição, pois é o discurso que faz do homem um ser político. E tudo que os homens fazem, sabem ou experimentam só tem sentido na medida em que pode ser discutido. Haverá, talvez, verdades que ficam além da linguagem e que podem ser de grande relevância para o homem no singular, isto é, para o homem que, seja o que for, não é um ser político. Mas homens no plural, isto é, os homens que vivem e se movem e agem neste mundo, só podem experimentar o significado das coisas por poderem falar e ser inteligíveis entre si e consigo mesmos.

ARENDT, H. **A condição humana**. Rio de Janeiro: Forense Universitária, 2004.

No trecho, a filósofa Hannah Arendt mostra a importância da linguagem no processo de', 'E', 1.98269, 0.65728, 0.08702, NULL, 'palavras-chave'),
  -- Questão 48 · CH · Sociologia · Cultura, identidade e movimentos sociais · H24
  (2022, 48, 1, NULL, 'CH', 'Sociologia', 'Cultura, identidade e movimentos sociais', 24, 141322, 'Eu estava pagando o sapateiro e conversando com um preto que estava lendo um jornal. Ele estava revoltado com um guarda civil que espancou um preto e amarrou numa árvore. O guarda civil é branco. E há certos brancos que transforma o preto em bode expiatório. Quem sabe se guarda civil ignora que já foi extinta a escravidão e ainda estamos em regime de chibata?

JESUS, C. M. **Quarto de despejo: diário de uma favelada**. São Paulo: Ática, 2014.

O texto que guarda a grafia original da autora, expõe uma característica da sociedade brasileira, que é o(a):', 'A', 2.8995, -0.42411, 0.19356, NULL, 'palavras-chave'),
  -- Questão 49 · CH · Geografia · Geografia física e questões ambientais · H30
  (2022, 49, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 30, 140639, '![](/midia/enem/2022/q049/ba3420e0-0e8e-42b0-bf25-a995abbb85d2.webp)

**PAZ, A. D. Disponível em: www.ct.ufpb.br. Acesso em: 15 out. 2021. (adaptado.)**

A intensificação da ocupação urbana demonstrada afeta de forma imediata o(a)', 'B', 2.71371, 0.59055, 0.19782, NULL, 'palavras-chave'),
  -- Questão 50 · CH · Geografia · Geografia física e questões ambientais · H27
  (2022, 50, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 27, 140682, 'Na construção da ferrovia Madeira-Marmoré, o que dizer dos doentes, eternos moribundos a vagar entre delírios fabris, doses de quinino e corredores da morte? O Hospital da Candelária era santuário e túmulo, monumento ao progresso científico e preâmbulo da escuridão. Foi ali, com suas instalações moderníssimas, que médicos e sanitaristas dirigiram seu combate aos males tropicais. As maiores vitimas, contudo, permaneceriam na sombra a margem do palco, cobaias sem consolo, credores sem nome de uma sociedade que  não lhes concedera tempo algum para ser decifrada.

FOOT HARDWAN, F. Trem fantasma: modernidade na selva

São Paulo: Cia das letras,1968 adaptado

No texto, há uma crítica ao modo de ocupação do espaço amazônico pautada na', 'E', 1.88815, 1.59325, 0.13196, NULL, 'palavras-chave'),
  -- Questão 51 · CH · Geografia · Espaço agrário, indústria e economia · H17
  (2022, 51, 1, NULL, 'CH', 'Geografia', 'Espaço agrário, indústria e economia', 17, 87207, 'Uma nova economia surgiu em escala global no último quartel do século XX. Chamo-a de informacional, para identificar suas características global e em rede funda – mentais e diferenciadas e enfatizar sua interligação. É informacional porque depende basicamente de sua capa – cidade de gerar, processar e aplicar de forma eficiente a informação baseada em conhecimentos. É global porque seus componentes estão organizados em escala global, diretamente ou mediante uma rede de conexões entre agentes econômicos. É rede porque é feita em uma rede  
global de interação entre redes empresariais.

CASTELLS, M. A sociedade em rede – a era da informação:  
economia, sociedade e cultura. São Paulo: Paz e Terra, 1999  
(adaptado).

Qual mudança estrutural é resultado da forma de organização econômica descrita no texto?', 'E', 4.79392, 1.19623, 0.12998, NULL, 'palavras-chave'),
  -- Questão 52 · CH · Geografia · Espaço agrário, indústria e economia · H18
  (2022, 52, 1, NULL, 'CH', 'Geografia', 'Espaço agrário, indústria e economia', 18, 88045, 'Olhar O Brasil e não ver o sertão  
É como negar o queijo com a faca na mão  
Esse gigante em movimento  
Movido a tijolo e cimento  
Precisa de arroz com feijão  
Que tenha comida na mesa  
Que agradeça sempre a grandeza  
De cada pedaço de pão  
Agradeça a Clemente  
Que leva a semente  
Em seu embornal  
Zezé e o penoso balé  
De pisar no cacau  
Maria que amanhece o dia  
Lá no milharal

**VANDER LEE. Do Brasil, In: Pensei que fosse o céu: ao vivo. Rio de Janeiro: Indie Records, 2006 (fragmento).**

A letra da canção valoriza uma dimensão do espaço rural brasileiro em sua relação com a cidade ao ressaltar sua função de', 'D', 3.62371, 0.51644, 0.275, NULL, 'revisão manual'),
  -- Questão 53 · CH · História · Brasil Império · H21
  (2022, 53, 1, NULL, 'CH', 'História', 'Brasil Império', 21, 140568, 'O número cada vez maior de mulheres letradas e interessadas pela literatura e pelas novelas, muitas divulgadas em capítulos, seções, classificadas comumente como folhetim, alçou a um gênero de ficção corrente já em 1840, fazendo parte do florescimento da literatura nacional brasileira, instigando a formação e a ampliação de um público leitor feminino, ávido por novidades, pelo apelo dos folhetins e “narrativas modernas” que encenavam “os dramas e os conflitos de uma mulher em processo de transformação patriarcal e provinciana que, progressivamente, começava a se abrir para modernizar seus costumes”. No Segundo Reinado, as mulheres foram se tornando público determinante na construção da literatura e da imprensa nacional. E não apenas público, porquanto crescerá o número de escritoras que colaboram para isso e emergirá uma imprensa feminina, editada, escrita e dirigida por e para mulheres.

**ABRANTES, A. Do álbum de família à vitrine impressa: trajetos de retratos (PB, 1920), Revista Temas em Educação, n. 24, 2015 (adaptado).**

O registro das atividades descritas associa a inserção da figura feminina nos espaços de leitura e escrita do Segundo Reinado ao(à)', 'A', 1.48568, 0.87454, 0.17248, NULL, 'revisão manual'),
  -- Questão 54 · CH · História · Brasil Império · H25
  (2022, 54, 1, NULL, 'CH', 'História', 'Brasil Império', 25, 125706, 'Os caixeiros do comércio a retalho do Rio de Janeiro estiveram entre as primeiras categorias de trabalhadores a se organizar em associações e a exigir a intervenção dos poderes públicos na mediação de suas lutas por direitos. Na década de 1880, os caixeiros participaram da arena política e ganharam as ruas com vários outros, como os republicanos e os abolicionistas.

**POPINIGIS, F. “Todas as liberdades são irmãs: os caixeiros e as lutas dos trabalhadores por  direitos entre o Império e a República. Estudos Históricos, n. 59, set-dez. 2018 (adaptado)**

A atuação dos trabalhadores mencionados no texto representou, na capital do Império, um momento de', 'E', 0.5628, 2.08511, 0.00958, NULL, 'revisão manual'),
  -- Questão 55 · CH · Geografia · Geografia física e questões ambientais · H28
  (2022, 55, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 28, 140631, 'Solos salinos ou alomórficos apresentam como característica comum uma concentração muito alta de sais solúveis e/ou de sódio trocável. Eles ocorrem nos locais mais baixos do relevo, em regiões áridas e semiáridas e próximas do mar. Em regiões semiáridas, por exemplo, o polígono das secas do Nordeste brasileiro, os locais menos elevados recebem água que se escoa dos declives adjacentes, durante as chuvas que caem em alguns meses do ano. Essa água traz soluções de sais minerais e evapora-se rapidamente antes de infiltrar-se totalmente, havendo então, cada vez que esse processo é repetido, um pequeno acúmulo de sais no horizonte superficial que, com o passar dos anos, provoca a salinização do solo. Nas últimas décadas, a expansão das atividades agrícolas na região tem ampliado esse processo.

**LEPSCH, |. F. Solos: formação e conservação. São Paulo: Melhoramentos, 1993 (adaptado).**

As atividades agrícolas, desenvolvidas na região mencionada, intensificam o problema ambiental exposto ao', 'B', 1.57605, 2.33974, 0.25072, NULL, 'palavras-chave'),
  -- Questão 56 · CH · Sociologia · Tecnologia, mídia e sociedade · H20
  (2022, 56, 1, NULL, 'CH', 'Sociologia', 'Tecnologia, mídia e sociedade', 20, 141364, '![](/midia/enem/2022/q056/0a4f1ebf-a011-4562-9d7d-c09766683612.webp)

**CAZO. Disponível em: www.humorpolitico.com.br. Acesso em: 21 nov. 2021 (adaptado).**

**TEXTO II**  
É como se os problemas fossem criados pela pandemia quando, em verdade, isso só demonstra o quanto eles sofrem uma tentativa de serem naturalizados. Eles estavam lá, empurrados para debaixo de vários tapetes. Diversos levantamentos realizados indicam que parcela significativa dos estudantes não têm acesso à internet em suas casas, não têm computadores; têm celulares, mas com pacotes baratos que não permitem assistir a todas as aulas. E, caso tenham celulares e dados, pergunta-se: É possível elaborar um texto no celular? É possível interagir na aula remota pelo celular?

**ASSIS. A. E. S. Q. Educação e pandemia. Educação em Revista, n. 37, 2021 (adaptado).**

A crítica contida no texto e na figura evidencia o seguinte aspecto da sociedade contemporárea:', 'A', 1.83281, -0.1754, 0.04287, NULL, 'revisão manual'),
  -- Questão 57 · CH · Filosofia · Filosofia moderna e contemporânea · H23
  (2022, 57, 1, NULL, 'CH', 'Filosofia', 'Filosofia moderna e contemporânea', 23, 141355, 'O leproso é visto dentro de uma prática de rejeição, ao exílio-cerca; deixa-se que se perca lá dentro como numa massa que não têm muita importância diferenciar; os pestilentos são considerados num policiamento tático meticuloso onde as diferenciações individuais são os efeitos limitantes de um poder que se multiplica, se articula e se subdivide. O grande fechamento por um lado; o bom treinamento por outro. A lepra e a sua divisão; a peste e seus recortes. Uma é marcada; a outra, analisada e repartida. O exílio do leproso e a prisão da peste não trazem consigo o mesmo sonho político.

**FOUCAULT, M. Vigiar e punir: nascimento da prisão. Petrópolis: Vozes, 1987.**

Os modelos autoritários descritos no texto apontam para um sistema de controle que se baseia no(a):', 'A', 2.81233, 1.85756, 0.17604, NULL, 'revisão manual'),
  -- Questão 58 · CH · História · Povos indígenas, africanos e diversidade cultural · H14
  (2022, 58, 1, NULL, 'CH', 'História', 'Povos indígenas, africanos e diversidade cultural', 14, 125654, '**TEXTO I**  
Em março de 1889, quando apareceram as primeiras romarias atraídas pelos milagres da beata Maria de Araújo, Juazeiro inseriu-se no rol da fundação do espaço religioso. Construía-se mais um centro, como Aparecida do Norte, Canindé ou Lourdes.

**RAMOS, F. R. L. O meio do mundo: território sagrado em Juazeiro do Padre Cícero. Fortaleza: Imprensa Universitária, 2014.**

**TEXTO II**  
Não sabemos ao certo quantas pessoas estavam presentes na capela no momento em que a hóstia sangrou na boca de Maria de Araújo. O Padre Cícero nos conta que o fato surpreendeu não só aos presentes, mas o fenômeno continuou acontecendo todas as quartas e sextas na Capela de Nossa Senhora das Dores a partir daquele dia. Os paninhos manchados do sangue que escorria da hóstia e da boca da beata, a princípio ficaram sob a guarda do Padre Cícero, mas logo foram expostos à visitação pública e, além disso, o sangramento foi proclamado como milagre sem o conhecimento e sem a autorização do bispo diocesano.

**NOBRE, E. Incêndios da alma. Rio de Janeiro. Multifoco. 2016 (Adaptado).**

As práticas religiosas mencionadas nos textos estão associadas, respectivamente, à:', 'E', 1.49576, 0.47561, 0.01589, NULL, 'revisão manual'),
  -- Questão 59 · CH · Geografia · Espaço agrário, indústria e economia · H19
  (2022, 59, 1, NULL, 'CH', 'Geografia', 'Espaço agrário, indústria e economia', 19, 118066, 'Em 2003, teve início o Programa de Aquisição de Alimentos e, com ele, várias mudanças na perspectiva dos mercados institucionais. Trata-se do primeiro programa de compras públicas com uma orientação exclusiva para a agricultura familiar, articulando-a explicitamente com a segurança alimentar e nutricional. O Programa é destinado à aquisição de produtos agropecuários  
produzidos por agricultores enquadrados no Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf), incluídas aqui as categorias: assentados da reforma agrária, trabalhadores rurais sem terra, acampados, quilombolas, agroextrativistas, famílias atingidas por barragens e comunidades indígenas.

**GRISA, C.; ISOPO, S. P. Dez anos de PAA: As contribuições e os desafios para o desenvolvimento rural. In: GRISA, C.; SCHNEIDER, S. (Org.). Políticas públicas de desenvolvimento rural no Brasil. Porto Alegre: UFRGS, 2015.**

A ação governamental descrita constitui-se uma importante conquista para os pequenos produtores em virtude da:', 'C', 1.933, 0.69054, 0.17203, NULL, 'palavras-chave'),
  -- Questão 60 · CH · Sociologia · Tecnologia, mídia e sociedade · H20
  (2022, 60, 1, NULL, 'CH', 'Sociologia', 'Tecnologia, mídia e sociedade', 20, 140429, 'Um experimento denominado FunFit foi desenvolvido com o objetivo de fazer com que os membros de uma comunidade local se tornassem mais ativos fisicamente. Todos os participantes do estudo foram vinculados a dois outros membros da comunidade que receberiam pequenos incentivos em dinheiro para serem estimulados a aumentar a sua atividade física, que era medida por acelerômetros nos celulares fornecidos pelo estado. Assim, se a pessoa andasse mais do que o habitual, seus conhecidos receberiam o dinheiro. Os resultados foram assombrosos: o esquema mostrou-se de quatro a oito vezes mais eficaz do que o método de oferecer incentivos individuais.

**MOROZOV, E. Big Tech: a ascensão dos dados e a morte da politica. São Paulo: Ubu, 2018 (adaptado).**

Contrariando a visão prevalente sobre o impacto tecnológico nas relações humanas, o texto revela que os celulares podem desempenhar uma função', 'B', 2.16917, 0.75171, 0.18087, NULL, 'revisão manual'),
  -- Questão 61 · CH · Sociologia · Trabalho e sociedade · H16
  (2022, 61, 1, NULL, 'CH', 'Sociologia', 'Trabalho e sociedade', 16, 141030, 'A dublagem é o novo campo a ser explorado pela inteligência artificial, e há empresas dedicadas a fazer com que as vozes originais de atores sejam transpostas para outros idiomas. A novidade reforça a tendência da automação de postos de trabalho nas mais diversas áreas. Tem potencial para facilitar a vida de estúdios e produtoras e, ao mesmo tempo, tornar mais escassas as oportunidades para dubladores e atores que trabalham com isso.

**GAGLIONI, C. Disponível em: www.nexojornal.com.br. Acesso em: 25 ou. 2021.**

A consequência da mudança tecnológica apresentada no texto é a', 'E', 3.15825, 0.30776, 0.14196, NULL, 'revisão manual'),
  -- Questão 62 · CH · Geografia · Geopolítica e cartografia · H9
  (2022, 62, 1, NULL, 'CH', 'Geografia', 'Geopolítica e cartografia', 9, 140585, 'Brasil e Argentina chegaram a um acordo para a redução em 10% da Tarifa Externa Comum (TEC) do Mercosul. O consenso foi alcançado durante negociação entre o ministro das Relações Exteriores do Brasil e o seu equivalente argentino, no Palácio do Itamaraty, em Brasília, no início do mês de outubro de 2021. A redução da TEC é um antigo desejo do Brasil, que pretende abrir mais sua economia e, com isso, ajudar a controlar a inflação. Já a Argentina temia que a medida pudesse afetar sua produção industrial. O acordo vai abranger uma ampla gama de produtos e ainda será apresentado ao Paraguai e Uruguai, para que seja formalizado.

**Brasil e Argentina fecham acordo para corte de 10% na tarifa do Mercosul. Disponível em: https://oglobo.globo.com. Acesso em: 8 out. 2021 (adaptado).**

A necessidade de negociação diplomática para viabilizar o acordo tarifário mencionado é explicada pela seguinte característica do Mercosul:', 'C', 2.18434, 1.60479, 0.16086, NULL, 'revisão manual'),
  -- Questão 63 · CH · História · Antiguidade e Idade Média · H11
  (2022, 63, 1, NULL, 'CH', 'História', 'Antiguidade e Idade Média', 11, 112145, 'Ainda que a fome ocorrida na Itália em 536 tenha origem nos eventos climáticos, suas implicações são tanto políticas quanto econômicas. Nos primeiros séculos da Idade Média, o auxílio aos famintos se inscreve no domínio da gestão pública, mesmo quando a ação de seus agentes é apresentada sob o ângulo da piedade e da caridade individuais, como é o caso da Gália merovíngia. Assim, o fato de que as respostas à fome são mostradas, na Gália, como o fruto de iniciativas pessoais fundadas no imperativo da caridade deriva da natureza das fontes do século VI.

**SILVA, M.C. Os agentes públicos e a fome nos primeiros séculos da Idade Média. Varia Historia, n. 60, set-dez. 2016 (Adaptado).**

Na conjuntura histórica destacada no texto, o dever de agir em face da situação de crise apresentada pertencia à jurisdição', 'B', 0.47387, 2.25057, 0.00901, NULL, 'palavras-chave'),
  -- Questão 64 · CH · Geografia · Geografia física e questões ambientais · H29
  (2022, 64, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 29, 84199, 'As forças tectônicas dentro da litosfera, controladas pelo calor interno das profundezas, geram terremotos, erupções e soerguimento de montanhas. As forças meteorológicas dentro da atmosfera e da hidrosfera, contoladas pelo calor do Sol, produzem tempestades,  
inundações, geleiras e outros agentes de erosão.

**PRESS, F. et al. Para entender a Terra. Porto Alegre: Bookman, 2002 (adaptado).**

A interação dinâmica entre as forças naturais citadas favorece a ocupação do espaço geográfico, na medida em que provoca a formação de', 'A', NULL, NULL, NULL, 'Correlação bisserial negativa: item desconsiderado pelo INEP no cálculo da nota', 'palavras-chave'),
  -- Questão 65 · CH · Sociologia · Cultura, identidade e movimentos sociais · H22
  (2022, 65, 1, NULL, 'CH', 'Sociologia', 'Cultura, identidade e movimentos sociais', 22, 141048, '![](/midia/enem/2022/q065/976097b0-d433-498d-946f-1770a46340fb.webp)

**Disponível em:https://hdmais.com.br. Acesso em: 8 out. 2021.**

O ápice da ilustração se traduz por uma conduta social caracterizada pela', 'B', 1.63923, -0.72645, 0.00905, NULL, 'revisão manual'),
  -- Questão 66 · CH · História · Brasil Império · H14
  (2022, 66, 1, NULL, 'CH', 'História', 'Brasil Império', 14, 140914, '**TEXTO I**

A primeira grande lei educacional do Brasil, de 1827, determinava que, nas “escolas de primeiras letras” do Império, meninos e meninas estudassem separados e tivessem currículos diferentes. No Senado, o Visconde de Cayru foi um dos defensores de que o currículo de matemática das garotas fosse o mais enxuto possível. Nas palavras dele, o “belo sexo” não tinha capacidade intelectual para ir muito longe: – Sobre as contas, são bastantes \[para as meninas\] as quatro espécies, que não estão fora do seu alcance e lhes podem ser de constante uso na vida.

**TEXTO II**

No Senado, o único a defender publicamente que as meninas tivessem, em matemática, um currículo idêntico ao dos meninos foi o Marquês de Santo Amaro (RJ). Ele argumentou: – Não me parece confome, às luzes do tempo em que vivemos, deixarmos de facilitar às brasileiras a aquisição desses conhecimentos \[mais aprofundados de matemática\]. A oposição que se manifesta não pode nascer senão do arraigado e péssimo costume em que estavam os antigos, os quais nem queriam que suas filhas aprendessem a ler.

WESTIN, R. Senado Notícias. Disponível em: www12.senado.leg.br. Acesso em: 20 out. 2021 (adaptado).

Os discursos expressam pontos de vista divergentes respectivemerte pela oposição entre', 'C', 0.85459, 2.13235, 0.12367, NULL, 'revisão manual'),
  -- Questão 67 · CH · Sociologia · Cultura, identidade e movimentos sociais · H10
  (2022, 67, 1, NULL, 'CH', 'Sociologia', 'Cultura, identidade e movimentos sociais', 10, 141148, 'Após sete anos da ocupação de um terreno abandonado em Santo André, no ABC paulista, os condomínios Novo Pinheirinho e Santos Dias foram inaugurados, com a presença de representantes dos governos federal, estadual e municipal. A ocupação começou em 2012 e, desde então, o movimento vinha reivindicando o direito de usufruir do espaço para a construção de casas. A Cartas Magna, em seu art. 6°, garante a todos os brasileiros o direito à moradia.

PUTTI, A. Disponível em: www.cartacapital.com.br.  
Acesso em: 13 nov. 2021 (adaptado).

O texto apresenta uma estratégia usada pelo movimento social para', 'D', 3.48759, 0.79822, 0.18644, NULL, 'revisão manual'),
  -- Questão 68 · CH · Geografia · Geopolítica e cartografia · H7
  (2022, 68, 1, NULL, 'CH', 'Geografia', 'Geopolítica e cartografia', 7, 111964, '**TEXTO I**  
A Marinha identifica, na voz de Thomas Barnett, uma ampla região potencialmente insubmissa ou simplesmente irredutível às normas gerais de funcionamento promovidas pelos Estados Unidos e sancionadas pelo Fundo Monetário Internacional, pela Organização Mundial do Comércio e pelo Banco Mundial. E não necessariamente por sua consciência rebelde, mas sim, em muitos casos, pela insubstancialidade de suas instituições estatais.

**TEXTO II**

![](/midia/enem/2022/q068/f472fda8-7fa2-43b7-bcc3-72db46b0d92d.webp)

CECEÑA. A. E. Hegemonias e emancipações no século XXI.  
Buenos Aires: Clacso. 2005.

As preocupações do governo estadunidense expressas no texto e no mapa evidenciam uma estratégia para', 'D', 2.81132, 0.5445, 0.20515, NULL, 'revisão manual'),
  -- Questão 69 · CH · Geografia · Geopolítica e cartografia · H15
  (2022, 69, 1, NULL, 'CH', 'Geografia', 'Geopolítica e cartografia', 15, 82962, 'Colegas, na mente e no coração do povo, a Crimeia sempre foi uma porção inseparável da Rússia. Essa firme convicção se baseia na verdade e na justiça e foi passada de geração em geração, ao longo do tempo, sob quaisquer circunstâncias, apesar de todas as drásticas mudanças que nosso país atravessou durante todo o século XX.

Disponível em: http://g1.globo.com. Acesso em: 28 jul. 2014.

Considerando a dinâmica geopolítica subjacente ao texto, a justificativa utilizada por Vladimir Putin, em 2014, para anexação dessa península apela para o argumento de que', 'A', 1.7267, 1.34237, 0.16873, NULL, 'revisão manual'),
  -- Questão 70 · CH · Sociologia · Cultura, identidade e movimentos sociais · H15
  (2022, 70, 1, NULL, 'CH', 'Sociologia', 'Cultura, identidade e movimentos sociais', 15, 97262, '**TEXTO I**

**Interseccionalidade:** intercruzamento de desigualdades que gera padrões complexos de discriminação

![](/midia/enem/2022/q070/1539c835-a8b9-444d-949c-51d59d8d33fe.webp)

**Disponível em: www.agenciadenoticias.ibge.gov.br. Acesso em: 2 dez. 2018.**

Considerando o conceito apresentando no Texto I e os dados apresentados no Texto II, no Brasil, são fatores que intensificam o fenômeno da discriminação:', 'A', 1.46058, -0.44013, 0.20483, NULL, 'palavras-chave'),
  -- Questão 71 · CH · Sociologia · Cidadania, Estado e direitos · H23
  (2022, 71, 1, NULL, 'CH', 'Sociologia', 'Cidadania, Estado e direitos', 23, 44230, 'O princípio básico do Estado de direito é o da eliminação do arbítrio no exercício dos poderes  públicos, com a consequente garantia de direitos dos indivíduos perante esses poderes. Estado de direito significa que nenhum indivíduo, presidente ou cidadão comum está acima da lei. Os governos democráticos exercem a autoridade por meio da lei e estão eles próprios sujeitos as constrangimentos impostos pela lei.

**CANOTILHO, J. J. G. Estado de direito, Lisboa: Gradiva, 1999 (adaptado).**

Nas sociedades contemporâneas, consiste em violação do princípio básico enunciado no texto:', 'A', 2.73837, 0.8616, 0.21624, NULL, 'palavras-chave'),
  -- Questão 72 · CH · Geografia · Espaço urbano e população · H18
  (2022, 72, 1, NULL, 'CH', 'Geografia', 'Espaço urbano e população', 18, 141384, '**Brasileiros levam mais tempo de casa para o trabalho**

Pesquisa do IBGE aponta que a situação é maio grave no Sudeste: 13% das pessoas levam mais de um hora para chegar ao trabalho. Nas regiões metropolitanas de São Paulo e do Rio, o IBGE registrou os maiores percentuais de trabalhadores que levam mais de uma hora no trajeto até o emprego. Quem vê o Marcelo chegar ao trabalho nem imagina a maratona que ele enfrenta todos os dias antes das 5 h. “Acordo 4 h 30, saio de casa 5 h, pego trem 5 h 20, chego na Central umas 6 h 50, pego ônibus e chego no trabalho mais ou menos 7 h 10”, conta. Segundo especialista, são os mais pobres os que moram mais longe do emprego.

**Disponivel em: www.portaldotransito.com.br. Acesso em: 23 nov 2021 (adaptado)**

A pesquisa desenvolvida retrata a seguinte dinâmica populacional:', 'D', 3.39376, 1.05605, 0.15958, NULL, 'revisão manual'),
  -- Questão 73 · CH · História · Idade Moderna e Contemporânea · H13
  (2022, 73, 1, NULL, 'CH', 'História', 'Idade Moderna e Contemporânea', 13, 75825, 'A história do Primeiro de Maio de 1890 — na França e na Europa, o primeiro de todos os Primeiros de Maio – é, sob vários aspectos, exemplar. Resultante de um ato político deliberado, essa manifestação ilustra o lado voluntário da construção de uma classe — a classe operária — à qual os socialistas tentam dar uma unidade política e cultural através daquela pedagogia da festa cujo princípio, eficácia e limites há muito tempo tinham sido experimentados pela Revolução Francesa.

**PERROT, M. Os excluídos da história: operários, mulheres e prisioneiros. Rio de Janeiro: Paz e Terra, 1988.**

Com base no texto, a fixação dessa data comemorativa tinha por objetivo', 'B', 2.34384, 0.97017, 0.12421, NULL, 'palavras-chave'),
  -- Questão 74 · CH · Geografia · Geografia física e questões ambientais · H6
  (2022, 74, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 6, 118110, '![](/midia/enem/2022/q074/03a69ed2-9038-4cca-8947-88663cbe1d23.webp)

**PEREIRA, E. B. et al. Atlas brasileiro de energia solar. São José dos Campos: Inpe, 2006**

Uma característica regional que justifica o maior potencial anual médio para o aproveitamento da energia solar é a reduzida', 'C', 2.22329, 1.79851, 0.25237, NULL, 'palavras-chave'),
  -- Questão 75 · CH · História · Povos indígenas, africanos e diversidade cultural · H5
  (2022, 75, 1, NULL, 'CH', 'História', 'Povos indígenas, africanos e diversidade cultural', 5, 140721, 'O povo Kambeba é o povo da águas. Os mais velhos costumam contar que o povo nasceu de uma gota-d’água que caiu do céu em uma grande chuva. Nessa gota estavam duas gotículas: o homem e a mulher. “Por essa narrativa e cosmologia indígena de que nós somos o povo das águas é que o rio nos tem fundamental importância”, diz Márcia Wayna Kambeba, mestre em Geografia e escritora. Todos os dias, ela ia com o pai observar o rio. Ia em silêncio e, antes que tomasse para si a palavra, era interrompida. “Ouço o rio”, o pai dizia. Depois de cerca de duas horas a ouvir as águas do Solimões, ela mergulhava. “Confie no rio e aprenda com ele”. “Fui entender mais tarde, com meus estudos e vivências, que meu pai estava me apresentando à sabedoria milenar do rio”.

**Rios amazônicos influenciam no agro e em reservatórios do Sudeste. Disponível em:  www.uol.com.br. Acesso em: 14 out. 2021.**

Pelo descrito no texto, o povo Kambeba tem o rio como um(a)', 'E', 0.81842, 0.92559, 0.02544, NULL, 'palavras-chave'),
  -- Questão 76 · CH · Geografia · Geografia física e questões ambientais · H29
  (2022, 76, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 29, 140441, 'Lá embaixo está o açude Itans, com seu formigueiro a cavar a terra. É mesmo impressionante o esforço daquele formigar de homens ao sol, lavados em suor, que não param em longas filas pacientes acompanhando centenas de burricos que sobem e descem, numa ciranda comovente e silenciosa, cada burrico com duas caixas de terra no lombo. É o labor organizado para a salvação da terra e do homem. Depois do semideserto que tanto nos acabrunhou o espírito por falta de chuvas, o esforço destes milhares de sertanejos, todos vestidos de brim mescla e calçando alpercatas, no combate consciente à esterilidade da natureza, com famílias alojadas em pequeninas casas de taipas e telha – embrião de futura cidade – impressionava-nos profundamente.

**VALLE, F. M. História do Açude Itans, município de Caicó (RN). Brasília, 1994 (adaptado)**

Na construção do empreendimento descrito, destaca-se a presença de', 'D', 1.76207, 1.31972, 0.21908, NULL, 'palavras-chave'),
  -- Questão 77 · CH · História · Brasil Colônia · H27
  (2022, 77, 1, NULL, 'CH', 'História', 'Brasil Colônia', 27, 140550, 'Para os Impérios Coloniais, o problema das doenças que atingiam os escravos era algo com que cotidianamente deparavam os senhores. Em vista disso, uma série de obras dedicadas à administração de escravos foi publicada com vista a implementar uma moderna gestão da mão de obra escravista em convergência com O Iluminismo. Nesse contexto, o saber médico adquiria um papel extremamente relevante. Este era encarado como um instrumento fundamental ao desenvolvimento colonial, dada a percepção do impacto que as doenças tropicais causavam na população branca e nos povos escravizados.

**ABREU, J. L. N. A Colônia enferma e a saúde dos povos: a medicina das “luzes” e as informações sobre as enfermidades da América portuguesa. História, Ciências, Saúde – Manguinhos, n. 3, jul.-set. 2007 (adaptado).**

De acordo com o texto, a importância da medicina se justifica no âmbito dos objetivos', 'A', 3.5293, 0.41127, 0.19018, NULL, 'palavras-chave'),
  -- Questão 78 · CH · Geografia · Geopolítica e cartografia · H6
  (2022, 78, 1, NULL, 'CH', 'Geografia', 'Geopolítica e cartografia', 6, 67980, '![](/midia/enem/2022/q078/1032a7bb-17e5-4711-ad16-aa16988017fa.webp)

**Disponível em: http://imguol.com. Acesso em: 30 mar. 2014 (adaptado).**

Considerando-se que a distância entre o local onde os destroços do avião foram avistados e a cidade de Perth é de 2 cm, a escala aproximada dessa representação cartográfica é:', 'E', 4.03907, 1.33056, 0.05942, NULL, 'revisão manual'),
  -- Questão 79 · CH · História · Povos indígenas, africanos e diversidade cultural · H5
  (2022, 79, 1, NULL, 'CH', 'História', 'Povos indígenas, africanos e diversidade cultural', 5, 140378, 'Hoje sou um ser inanimado, mas já tive vida pulsante em seivas vegetais, ful um ser vivo; é bem verdade que do reino vegetal, mas isso não me tirou a percepção de vida vivida como tamborete. Guardo apreço pelos meus criadores, as mãos que me fizeram, me venderam, 6 pelas mulheres que me usaram para suas vendas e de tantas outras maneiras. Essas pessoas, sim, tiveram suas subjetividades, singularidades e pluralidades, que estão incorporadas a mim. É preciso considerar que a nossa história, de móveis de museus, está para além da mera vinculação aos estilos e à patrimonialização que recebemos como bem material vinculado ao patrimônio imaterial. A nossa história está ligada aos dons individuais das pessoas e suas práticas sociais. Alguns indivíduos consagravam-se por terem determinados requisitos, tais como o conhecimento de modelos clássicos ou destreza nos desenhos.

**FREITAS, J. M.; OLIVEIRA, L. R. Memórias de um tamborete de baiana: as muitas vozes em um objeto de museu. Revista Brasileira de Pesquisa (Auto)Blográfica, n. 14, maio-ago. 2020 (Adaptado).**

Ao descrever-se como patrimônio museológico, o objeto abordado no texto associa a sua história às', 'A', 2.1636, 0.57483, 0.15916, NULL, 'palavras-chave'),
  -- Questão 80 · CH · Filosofia · Filosofia antiga e medieval · H3
  (2022, 80, 1, NULL, 'CH', 'Filosofia', 'Filosofia antiga e medieval', 3, 95823, 'Advento da _Polis_, nascimento da filosofia: entre as duas ordens de fenômenos, os vínculos são demasiado estreitos para que o pensamento racional não apareça, em suas origens, solidário das estruturas sociais e mentais próprias da cidade grega. Assim recolocada na história, a filosofia despoja-se desse caráter de revelação absoluta que às vezes lhe foi atribuído, saudando, na jovem ciência dos jônios, a razão intemporal que veio encarnar-se no Tempo. A escola de Mileto não viu nascer a Razão; ela construiu uma Razão, uma primeira forma de racionalidade. Essa razão grega não é a razão experimental da ciência contemporânea.

**VERNANT, J. P. Origens do pensamento grego. Rio de Janeiro: Difel, 2002.**

Os vínculos entre os fenômenos indicados no trecho foram fortalecidos pelo surgimento de uma categoria de pensadores, a saber:', 'C', 1.30094, 0.82448, 0.0937, NULL, 'palavras-chave'),
  -- Questão 81 · CH · História · Brasil República · H12
  (2022, 81, 1, NULL, 'CH', 'História', 'Brasil República', 12, 95739, '**Decreto-Lei n. 1 949, de 27/17/1937**

Art. 1.o Fica criado o Departamento de Imprensa e Propaganda (DIP), diretamente  subordinado ao presidente da República.  
Art. 2.o O DIP tem por fim:  
**h)** coordenar e incentivar as relações da imprensa com os poderes públicos no sentido de maior aproximação da mesma com os fatos que se ligam aos interesses nacionais;

**n)** autorizar mensalmente a devolução dos depósitos efetuados pelas empresas jornalísticas para importação de papel para imprensa , uma vez demonstrada, a seu juízo, a eficiência e a utilidade pública dos jornais ou periódicos por elas administrados ou dirigidos.

**BRASIL apud CARONE, E. A Terceira República. (1937-1945). São Paulo: Difel, 1982. (Adaptado).**

Com base nos trechos do decreto, as finalidades do órgão criado permitiram ao governo promover o(a)', 'D', 4.24795, 0.96273, 0.16049, NULL, 'palavras-chave'),
  -- Questão 82 · CH · Geografia · Geografia física e questões ambientais · H6
  (2022, 82, 1, NULL, 'CH', 'Geografia', 'Geografia física e questões ambientais', 6, 140643, '![](/midia/enem/2022/q082/9d037d23-4819-4184-9aab-bb87c3b40c73.webp)

**Geoestatísticas de recursos naturais da Amazônia Legal. Rio de Janeiro: IBGE, 2011 (adaptado).**

O mapa espacializa um recurso natural com alto potencial para ocorrência de:', 'B', 2.21197, 1.4236, 0.21778, NULL, 'palavras-chave'),
  -- Questão 83 · CH · Geografia · Geopolítica e cartografia · H8
  (2022, 83, 1, NULL, 'CH', 'Geografia', 'Geopolítica e cartografia', 8, 141072, 'Nascidas o Líbano, as duas irmãs não puderam ser registradas no país, porque lá é exigido que os nascidos sejam filhos de pais e mães libaneses. Seus pais, de nacionalidade síria, também não puderam registrá-las no país de origem. Na Síria, crianças só são registradas por pais oficialmente casados, o que não era o caso deles.

**Disponível em: https://agenciabrasi.ebc.com.br. Acesso em: 7 nov. 2021.**

Em situações como a apresentada no texto, as pessoas ao nascerem já se encontram na condição sociopolítica de', 'B', 2.78275, 0.64418, 0.18557, NULL, 'habilidade'),
  -- Questão 84 · CH · Filosofia · Filosofia moderna e contemporânea · H3
  (2022, 84, 1, NULL, 'CH', 'Filosofia', 'Filosofia moderna e contemporânea', 3, 111893, '**TEXTO I**  
Uma filosofia da percepção que queira reaprender a ver o mundo restituirá à pintura e às artes em geral seu lugar verdadeiro.

**MERLEAU-PONTY, M. Conversas: 1948. São Paulo: Martins Fontes, 2004.**

TEXTO II  
Os grandes autores de cinema nos pareceram confrontáveis não apenas com pintores, arquitetos, músicos, mas também com pensadores. Eles pensam com imagens, em vez de conceitos.

**DELEUZE, G. Cinema 1: a imagem-movimento. São Paulo: Brasiliense, 1983 (adaptado).**

De que modo os textos sustentam a existência de um saber ancorado na sensibilidade?', 'C', 0.56617, 1.5801, 0.03472, NULL, 'revisão manual'),
  -- Questão 85 · CH · História · Idade Moderna e Contemporânea · H4
  (2022, 85, 1, NULL, 'CH', 'História', 'Idade Moderna e Contemporânea', 4, 125944, '**TEXTO I**  
Manda o Santo Ofício da Inquisição que ninguém, seja qual for seu estado, idade ou condição, pare com carroça, caleça ou montaria nem atrapalhe com mesas ou cadeiras o centro das ruas, que vão da Inquisição a São Domingos, nem atravesse a procissão em ponto algum da ida ou da volta, amanhã, 19 do corrente, em que se celebrará auto de fé. E também que nem nesse dia nem nos dos açoites ouse alguém atirar  nos réus maçãs, pedras, laranjas nem outra coisa qualquer.

**PALMA, R. Anais da Inquisição de Lima. São Paulo: Edusp; Giordano, 1992 (adaptado).**

**TEXTO II**  
Como acontece em todos os ritos, o sentido do auto da fé é conferido pela sequência dos atos que o compõem. Os lugares, as posturas, os gestos, as palavras são fixados previamente em toda a sua complexidade. Por isso, o auto da fé apresenta momentos fortes – durante a preparação, a encenação, o ato e a recepção – que convém seguir em seus pormenores.

**BETHENCOURT, F. História das Inquisições: Portugal, Espanha e Itália – séculos XV-XIX. São Paulo: Cia. das Letras, 2000**

O rito mencionado nos textos demonstra a capacidade da Igreja em', 'D', 1.69059, 0.29126, 0.1166, NULL, 'revisão manual'),
  -- Questão 86 · CH · Filosofia · Filosofia antiga e medieval · H1
  (2022, 86, 1, NULL, 'CH', 'Filosofia', 'Filosofia antiga e medieval', 1, 96291, 'Empédocles estabelece quatro elementos corporais – fogo, ar, água e terra –, que são eternos e que mudam aumentando e diminuindo mediante mistura e  separação; mas os princípios propriamente ditos, pelos quais são movidos, são o Amor e o Ódio. Pois é preciso que os elementos permaneçam alternadamente em movimento, sendo ora misturados pelo Amor, ora separados pelo Ódio.

SIMPLÍCIO. Física, 25, 21. In: **Os pré-socráticos**. São Paulo: Nova Cultural, 1996.

O texto propõe uma reflexão sobre o entendimento de Empédocles acerca da arché, uma preocupação típica do pensamento pré-socrático, porque', 'C', 2.9037, 1.66082, 0.10307, NULL, 'palavras-chave'),
  -- Questão 87 · CH · Geografia · Espaço urbano e população · H19
  (2022, 87, 1, NULL, 'CH', 'Geografia', 'Espaço urbano e população', 19, 140572, 'Macrocefalia urbana pode ser entendida como a massiva concentração das atividades econômicas em algumas metrópoles que propicia o desencadeamento de processos descompassados: redirecionamento e convergência de fluxos migratórios, déficit no numero de empregos, ocupação desordenada em determinadas regiões da cidade e estigmatizarão de estratos sociais , que comprometem substancialmente a segurança pública urbana.

SANTOS, M. **O espaço dividido:** os dois circuitos da economia urbana dos países subdesenvolvidos. São Paulo: Edusp. 2004.

O processo de concentração espacial apresentado foi estimulado por qual fator geográfico?', 'B', 2.46583, 0.73772, 0.17053, NULL, 'palavras-chave'),
  -- Questão 88 · CH · Filosofia · Filosofia antiga e medieval · H2
  (2022, 88, 1, NULL, 'CH', 'Filosofia', 'Filosofia antiga e medieval', 2, 96516, 'Entretanto, nosso amigo Basso tem o ânimo alegre. Isso resulta da filosofia: estar alegre diante da morte, forte e contente qualquer que seja o estado do corpo, sem desfalecer, ainda que desfaleça.

**Sêneca, L. Cartas morais. Lisboa: Calouste Gulbenkian, 1990.**

O excerto refere-se a uma carta de Sêneca na qual se apresenta como um bem fundamental da filosofia promover a', 'E', 1.96743, 2.20588, 0.08863, NULL, 'revisão manual'),
  -- Questão 89 · CH · História · Povos indígenas, africanos e diversidade cultural · H5
  (2022, 89, 1, NULL, 'CH', 'História', 'Povos indígenas, africanos e diversidade cultural', 5, 140190, 'Quando os espanhóis chegaram à América, estava em seu apogeu o império teocrático dos Incas, que estendia seu poder sobre o que hoje chamamos Peru, Bolívia e Equador, abarcava parte da Colômbia e do Chile e alcançava até o norte argentino e a selva brasileira; a confederação dos Astecas tinha conquistado um alto nível de eficiência no vale do México, e no Yucután, na América Central, a esplêndida civilização dos Maias persistia nos povos herdeiros, organizados para o trabalho e para a guerra. Os Maias tinham sido grandes astrônomos, mediram o tempo e o espaço com assombrosa precisão, e tinham descoberto o valor do número zero antes de qualquer povo da história. No museu de Lima, podem ser vistos centenas de crânios que receberam placas de ouro e prata por parte dos cirurgiões Incas.

GALEANO, E. **As veias abertas da América Latina.** Porto Alegre: L&PM, 2012.

As sociedades mencionadas deixaram como legado uma diversidade de', 'C', 1.94428, 0.27387, 0.14788, NULL, 'revisão manual'),
  -- Questão 90 · CH · História · Povos indígenas, africanos e diversidade cultural · H3
  (2022, 90, 1, NULL, 'CH', 'História', 'Povos indígenas, africanos e diversidade cultural', 3, 111984, 'Em Vitória (ES), no bairro Goiabeiras, encontramos as paneleiras, mulheres que são conhecidas pelos saberes/fazeres das tradicionais panelas de barro, ícones da culinária capixaba. A tradição passada de mãe para filha é de origem indígena e sofreu influência de outras etnias, como a afro e a luso. Dessa mistura, acredita-se que a fabricação das panelas de barro já tenha 400 anos. A fabricação das panelas de barro se dá em várias etapas, desde a obtenção de matéria-prima à confecção das panelas. As matérias-primas tradicionalmente utilizadas são provenientes do meio natural, como: argila, retirada do barreiro no Vale do Mulembá; madeira, atualmente proveniente das sobras da construção civil; e tinta, extraída da casca do manguezal, o popular mangue-vermelho.

**TRISTÃO, M. A educação ambiental e o pós-colonialismo. Revista de Educação, n. 53, ago. 2014.**

Uma característica de práticas tradicionais como a exemplificada no texto é vinculação entre os recursos do mundo natural e a', 'A', 1.90716, 1.36087, 0.22521, NULL, 'palavras-chave'),
  -- Questão 91 · CN · Química · Oxirredução, eletroquímica e termoquímica · H27
  (2022, 91, 2, NULL, 'CN', 'Química', 'Oxirredução, eletroquímica e termoquímica', 27, 141574, 'A figura ilustra esquematicamente um processo de  
remediação de solos contaminados com tricloroeteno  
(TCE), um agente desengraxante. Em razão de  
vazamentos de tanques de estocagem ou de manejo  
inapropriado de resíduos industriais, ele se encontra  
presente em águas subterrâneas, nas quais forma  
uma fase líquida densa não aquosa (DNAPL) que se  
deposita no fundo do aquífero. Essa tecnologia de  
descontaminação emprega o íon persulfato (S2  
O8  
2−), que  
é convertido no radical •SO4  
− por minerais que contêm  
Fe(III). O esquema representa de forma simplificada o  
mecanismo de ação química sobre o TCE e a formação  
dos produtos de degradação.

![](/midia/enem/2022/q091/0c8a2451-b60e-4a4f-9eb8-4cac8fe9536d.webp)

BERTAGI, L. T.; BASÍLIO, A. O.; PERALTA-ZAMORA, P. Aplicações ambientais de persulfato:  
remediação de águas subterrâneas e solos contaminados. Química Nova, n. 9, 2021 (adaptado)

Esse procedimento de remediação de águas subterrâneas
baseia-se em reações de', 'A', 0.69982, 1.45358, 0.03441, NULL, 'revisão manual'),
  -- Questão 92 · CN · Biologia · Saúde e doenças · H30
  (2022, 92, 2, NULL, 'CN', 'Biologia', 'Saúde e doenças', 30, 18228, 'De acordo com a Organização Mundial da Saúde, a filariose e a leishmaniose são consideradas doenças  
tropicais infecciosas e constituem uma preocupação para a saúde pública por ser alto o índice de mortalidade a elas associado.

Uma medida profilática comum a essas duas doenças é o(a)', 'D', 1.95358, 1.46498, 0.11246, NULL, 'palavras-chave'),
  -- Questão 93 · CN · Física · Energia, trabalho e potência · H23
  (2022, 93, 2, NULL, 'CN', 'Física', 'Energia, trabalho e potência', 23, 111668, 'Em 2017, foi inaugurado, no estado da Bahia, o Parque Solar Lapa, composto por duas usinas (Bom Jesus  
da Lapa e Lapa) e capaz de gerar cerca de 300 GWh de energia por ano. Considere que cada usina apresente potência igual a 75 MW, com o parque totalizando uma potência instalada de 150 MW. Considere ainda que a irradiância solar média é de 1 500 W/m² e que a eficiência dos painéis é de 20%.

**Parque Solar Lapa entra em operação**. Disponível em: www.canalbioenergia.com.br. Acesso em: 9 jun. 2022 (adaptado).

Nessas condições, a área total dos painéis solares que compõem o Parque Solar Lapa é mais próxima de:', 'B', 1.98964, 1.87763, 0.19415, NULL, 'palavras-chave'),
  -- Questão 94 · CN · Química · Transformações e reações químicas · H27
  (2022, 94, 2, NULL, 'CN', 'Química', 'Transformações e reações químicas', 27, 111694, '![](/midia/enem/2022/q094/a62bc797-e3bd-4754-bc9b-433469b0a49f.webp)

Os riscos apresentados pelos produtos dependem de suas propriedades e da reatividade quando em contato com outras substâncias. Para prevenir os riscos devido à natureza química dos produtos, devemos conhecer a lista de substâncias incompatíveis e de uso cotidiano em fábricas, hospitais e laboratórios, a fim de observar cuidados na estocagem, manipulação e descarte. O quadro elenca algumas dessas incompatibilidades, que podem levar à ocorrência de acidentes.

Considere que houve o descarte indevido de dois conjuntos de substâncias:  
(1) ácido clorídrico concentrado com cianeto de potássio;  
(2) ácido nítrico concentrado com sacarose.

Disponível em: www.fiocruz.br. Acesso em: 6 dez. 2017 (adaptado).

O descarte dos conjuntos (1) e (2) resultará, respectivamente, em', 'A', 2.07884, 2.23408, 0.17191, NULL, 'palavras-chave'),
  -- Questão 95 · CN · Física · Eletricidade e magnetismo · H21
  (2022, 95, 2, NULL, 'CN', 'Física', 'Eletricidade e magnetismo', 21, 111558, 'O físico Hans C. Oersted observou que um fio transportando corrente elétrica produz um campo magnético. A presença  
do campo magnético foi verificada ao aproximar uma bússola de um fio conduzindo corrente elétrica.  
A figura ilustra um fio percorrido por uma corrente elétrica i, constante e com sentido para cima. Os pontos A, B e C  
estão num plano transversal e equidistantes do fio. Em cada ponto foi colocada uma bússola.

![](/midia/enem/2022/q095/2a216ed1-eeab-4213-bcac-34e5166e97dd.webp)

Considerando apenas o campo magnético por causa da corrente i, as respectivas configurações das bússolas nos pontos A, B e C serão', 'D', 3.29206, 1.65709, 0.14008, NULL, 'palavras-chave'),
  -- Questão 96 · CN · Física · Eletricidade e magnetismo · H21
  (2022, 96, 2, NULL, 'CN', 'Física', 'Eletricidade e magnetismo', 21, 81969, '![](/midia/enem/2022/q096/970c1d36-8b55-4012-b912-db3efb32fbe4.webp)

O quadro mostra valores de corrente elétrica e seus efeitos sobre o corpo humano.

A corrente elétrica que percorrerá o corpo de um indivíduo depende da tensão aplicada e da resistência  
elétrica média do corpo humano. Esse último fator está intimamente relacionado com a umidade da pele, que seca apresenta resistência elétrica da ordem de 500 kΩ, mas, se molhada, pode chegar a apenas 1 kΩ.  
Apesar de incomum, é possível sofrer um acidente utilizando baterias de 12 V. Considere que um indivíduo com a pele molhada sofreu uma parada respiratória ao tocar simultaneamente nos pontos A e B de uma associação de duas dessas baterias.

DURAN, J. E. R. **Biofísica: fundamentos e aplicações**. São Paulo: Pearson Prentice Hall, 2003 (adaptado).

Qual associação de baterias foi responsável pelo acidente?', 'A', 2.00512, 1.35453, 0.16882, NULL, 'palavras-chave'),
  -- Questão 97 · CN · Química · Radioatividade · H26
  (2022, 97, 2, NULL, 'CN', 'Química', 'Radioatividade', 26, 141597, 'O urânio é empregado como fonte de energia em reatores nucleares. Para tanto, o seu mineral deve  
ser refinado, convertido a hexafluoreto de urânio e posteriormente enriquecido, para aumentar de 0,7% a 3% a abundância de um isótopo específico — o urânio-235. Uma das formas de enriquecimento utiliza a pequena diferença de massa entre os hexafluoretos de urânio-235 e de urânio-238 para separá-los por efusão, precedida pela vaporização. Esses vapores devem efundir repetidamente  
milhares de vezes através de barreiras porosas formadas por telas com grande número de pequenos orifícios. No entanto, devido à complexidade e à grande quantidade de energia envolvida, cientistas e engenheiros continuam a pesquisar procedimentos alternativos de enriquecimento.

ATKINS, P.; JONES, L. **Princípios de química**: questionando a vida moderna e o meio ambiente. Porto Alegre: Bookman, 2006 (adaptado).

Considerando a diferença de massa mencionada entre os dois isótopos, que tipo de procedimento alternativo ao da efusão pode ser empregado para tal finalidade?', 'B', 2.13571, 1.60964, 0.14865, NULL, 'palavras-chave'),
  -- Questão 98 · CN · Biologia · Genética e biotecnologia · H29
  (2022, 98, 2, NULL, 'CN', 'Biologia', 'Genética e biotecnologia', 29, 141725, 'A Agência Nacional de Vigilância Sanitária (Anvisa) aprovou um produto de terapia gênica no país, indicado para o tratamento da distrofia hereditária da retina. O procedimento é recomendado para crianças acima de 12 meses e adultos com perda de visão causada pela mutação do gene humano RPE65. O produto, elaborado por engenharia genética, é composto por um vírus, no qual foi inserida uma cópia do gene normal humano RPE65 para corrigir o funcionamento das células da retina.

ANVISA. Disponível em: www.gov.br/anvisa. Acesso em: 4 dez. 2021 (adaptado)

O sucesso dessa terapia advém do fato de que o produto favorecerá a', 'E', 1.82114, 1.93167, 0.06674, NULL, 'palavras-chave'),
  -- Questão 99 · CN · Biologia · Ecologia e meio ambiente · H28
  (2022, 99, 2, NULL, 'CN', 'Biologia', 'Ecologia e meio ambiente', 28, 41054, 'A extinção de espécies é uma ameaça real que afeta diversas regiões do país. A introdução de espécies exóticas pode ser considerada um fator maximizador desse processo. A jaqueira (_Artocarpus heterophyllus_), por exemplo, é uma árvore originária da Índia e de regiões do Sudeste Asiático que foi introduzida ainda na era colonial e se aclimatou muito bem em praticamente todo o território nacional.

Casos como o dessa árvore podem provocar a redução da biodiversidade, pois elas', 'A', 1.2012, 0.97602, 0.22536, NULL, 'palavras-chave'),
  -- Questão 100 · CN · Física · Mecânica: movimento e forças · H20
  (2022, 100, 2, NULL, 'CN', 'Física', 'Mecânica: movimento e forças', 20, 90130, 'Em um dia de calor intenso, dois colegas estão a brincar com a água da mangueira. Um deles quer saber até que altura o jato de água alcança, a partir da saída de água, quando a mangueira está posicionada totalmente na direção vertical. O outro colega propõe então o seguinte experimento: eles posicionarem a saída de água da mangueira na direção horizontal, a 1 m de altura em relação ao chão, e então medirem a distância horizontal entre a mangueira e o local onde a água atinge o chão. A medida dessa distância foi de 3 m, e a partir disso eles calcularam o alcance vertical do jato de água. Considere a aceleração da gravidade de 10 m ![](/midia/enem/2022/q100/109f2a39-f073-4841-9cec-bed51e1c1f12.webp)

O resultado que eles obtiveram foi de', 'B', 1.73494, 2.08841, 0.27619, NULL, 'palavras-chave'),
  -- Questão 101 · CN · Química · Química ambiental e energia · H26
  (2022, 101, 2, NULL, 'CN', 'Química', 'Química ambiental e energia', 26, 31381, 'O etanol é um combustível produzido a partir da fermentação da sacarose presente no caldo de cana-de-açúcar. Um dos fatores que afeta a produção desse álcool é o grau de deterioração da sacarose, que se inicia após o corte, por causa da ação de microrganismos. Foram analisadas cinco amostras de diferentes tipos de cana-de-açúcar e cada uma recebeu um código de identificação.

No quadro são apresentados os dados de concentração de sacarose e de microrganismos presentes nessas amostras.

![](/midia/enem/2022/q101/afa4fc86-8d89-4713-a690-8306324d23ed.webp)

Pretende-se escolher o tipo de cana-de-açúcar que conterá o maior teor de sacarose 10 horas após o corte e que, consequentemente, produzirá a maior quantidade de etanol por fermentação. Considere que existe uma redução de aproximadamente 50% da concentração de sacarose nesse tempo, para cada 1,0 mg ![](/midia/enem/2022/q101/d492e2a3-b988-4c38-802d-20d5f73c3b72.webp) de microrganismos presentes na cana-de-açúcar.

Disponível em: www.inovacao.unicamp.br. Acesso em: 11 ago. 2012 (adaptado).

Qual tipo de cana-de-açúcar deve ser escolhido?', 'C', 1.75013, 1.52509, 0.16155, NULL, 'revisão manual'),
  -- Questão 102 · CN · Biologia · Genética e biotecnologia · H29
  (2022, 102, 2, NULL, 'CN', 'Biologia', 'Genética e biotecnologia', 29, 141731, 'Entre as diversas técnicas para diagnóstico da covid-19, destaca-se o teste genético. Considerando as diferentes variantes e cargas virais, um exemplo é a PCR, reação efetuada por uma enzima do tipo polimerase. Essa técnica permite identificar, com confiabilidade, o material genético do SARS-CoV-2, um vírus de RNA.  
Para comprovação da infecção por esse coronavírus, são coletadas amostras de secreções do indivíduo. Uma etapa que antecede a reação de PCR precisa ser realizada para permitir a amplificação do material genético do vírus.

Essa etapa deve ser realizada para', 'E', 1.52512, 3.19204, 0.11283, NULL, 'palavras-chave'),
  -- Questão 103 · CN · Física · Mecânica: movimento e forças · H20
  (2022, 103, 2, NULL, 'CN', 'Física', 'Mecânica: movimento e forças', 20, 85445, 'Tribologia é o estudo da interação entre duas superfícies em contato, como desgaste e atrito, sendo de extrema importância na avaliação de diferentes  
produtos e de bens de consumo em geral. Para testar a conformidade de uma muleta, realiza-se um ensaio tribológico, pressionando-a verticalmente contra o piso com uma força ![](/midia/enem/2022/q103/731a52b0-b8d4-4a15-8a7c-aabc67d6dcde.webp), conforme ilustra a imagem, em que CM representa o centro de massa da muleta.

Mantendo-se a força ![](/midia/enem/2022/q103/04cf32d8-f517-483e-b0d5-189de111bc7a.webp) paralela à muleta, varia-se lentamente o ângulo entre a muleta e a vertical, até o máximo ângulo imediatamente anterior ao de escorregamento, denominado ângulo crítico. Esse ângulo também pode ser calculado a partir da identificação dos pontos de aplicação, da direção e do sentido das forças peso ![](/midia/enem/2022/q103/9027d4f1-c0a1-4b18-ac9f-2639e6b4360b.webp), normal ![](/midia/enem/2022/q103/e11f6a77-dda3-4525-a045-894baf71d307.webp) e de atrito estático ![](/midia/enem/2022/q103/d65b67dc-a285-43d4-a72b-a9c1b521c3b5.webp).

![](/midia/enem/2022/q103/7cfea492-83f7-4ea1-bf6a-a3dc29d4edb9.webp)

O esquema que representa corretamente todas as forças que atuam sobre a muleta quando ela atinge o ângulo crítico é:', 'E', 4.44898, 1.4048, 0.15587, NULL, 'palavras-chave'),
  -- Questão 104 · CN · Biologia · Fisiologia humana e animal · H18
  (2022, 104, 2, NULL, 'CN', 'Biologia', 'Fisiologia humana e animal', 18, 97727, 'Diversas substâncias são empregadas com a intenção de incrementar o desempenho esportivo de atletas de alto nível. O chamado _doping_ sanguíneo, por exemplo, pela utilização da eritropoietina, é proibido pelas principais federações de esportes no mundo. A eritropoietina é um hormônio produzido pelos rins e fígado e sua principal ação é regular o processo de eritropoiese. Seu uso administrado intravenosamente em quantidades superiores àquelas presentes naturalmente no organismo permite que o indivíduo aumente a sua capacidade de realização de exercícios físicos.

Esse tipo de doping está diretamente relacionado ao aumento da', 'E', 2.35097, 1.00991, 0.30639, NULL, 'palavras-chave'),
  -- Questão 105 · CN · Física · Mecânica: movimento e forças · H18
  (2022, 105, 2, NULL, 'CN', 'Física', 'Mecânica: movimento e forças', 18, 28034, 'Em um autódromo, os carros podem derrapar em uma curva e bater na parede de proteção. Para diminuir o impacto de uma batida, pode-se colocar na parede uma barreira de pneus, isso faz com que a colisão seja mais demorada e o carro retorne com velocidade reduzida. Outra opção é colocar uma barreira de blocos de um material que se deforma, tornando-a tão demorada quanto a colisão com os pneus, mas que não permite a volta do carro após a colisão.

Comparando as duas situações, como ficam a força média exercida sobre o carro e a energia mecânica dissipada?', 'A', 1.51222, 1.41874, 0.14908, NULL, 'palavras-chave'),
  -- Questão 106 · CN · Química · Química orgânica · H24
  (2022, 106, 2, NULL, 'CN', 'Química', 'Química orgânica', 24, 97915, 'A penicilamina é um medicamento de uso oral utilizado no tratamento de várias doenças. Esse composto é excretado na urina, cujo pH se situa entre 5 e 7. A penicilamina, cuja fórmula estrutural plana está apresentada, possui três grupos funcionais que podem ser ionizados:

![](/midia/enem/2022/q106/836c6396-bd57-477b-b379-b509c4b99242.webp)

Qual estrutura derivada da penicilamina é predominantemente encontrada na urina?', 'C', 2.39896, 2.76588, 0.1897, NULL, 'revisão manual'),
  -- Questão 107 · CN · Química · Cinética e equilíbrio químico · H24
  (2022, 107, 2, NULL, 'CN', 'Química', 'Cinética e equilíbrio químico', 24, 85860, 'A biomassa celulósica pode ser utilizada para a produção de etanol de segunda geração. Entretanto, é necessário que os polissacarídeos sejam convertidos em mono e dissacarídeos, processo que pode ser conduzido em meio ácido, conforme mostra o esquema:

![](/midia/enem/2022/q107/d19f3bc6-e4ed-4f93-9a0b-55f98ab20380.webp)

OGEDA, T. L.; PETRI, D. F. S. \[…\] **Química Nova**, n. 7, 2010 (adaptado).

Nessa conversão de polissacarídeos, a função do íon H+ é', 'C', 5.31621, 2.04288, 0.17088, NULL, 'palavras-chave'),
  -- Questão 108 · CN · Química · Soluções, ácidos, bases e sais · H25
  (2022, 108, 2, NULL, 'CN', 'Química', 'Soluções, ácidos, bases e sais', 25, 44969, 'O ácido tartárico é o principal ácido do vinho e está diretamente relacionado com sua qualidade. Na avaliação de um vinho branco em produção, uma analista neutralizou uma alíquota de 25,0 mL do vinho com NaOH a 0,10 mol L−1, consumindo um volume igual a 8,0 mL dessa base. A reação para esse processo de titulação é representada pela equação química:

![](/midia/enem/2022/q108/9210b1e4-7666-4817-9757-f1642ea64a91.webp)

A concentração de ácido tartárico no vinho analisado é mais próxima de:', 'B', 3.07166, 1.89127, 0.25272, NULL, 'palavras-chave'),
  -- Questão 109 · CN · Química · Radioatividade · H22
  (2022, 109, 2, NULL, 'CN', 'Química', 'Radioatividade', 22, 96189, 'Oelementoiodo(I)temfunçãobiológicaeéacumulado  
na tireoide. Nos acidentes nucleares de Chernobyl e  
Fukushima, ocorreu a liberação para a atmosfera do  
radioisótopo 131I, responsável por enfermidades nas  
pessoas que foram expostas a ele. O decaimento de uma  
massa de 12 microgramas do isótopo 131I foi monitorado  
por 14 dias, conforme o quadro.

![](/midia/enem/2022/q109/354aeb9d-9351-404a-b131-174ac378eaaf.webp)

Após o período de 40 dias, a massa residual desse
isótopo é mais próxima de', 'D', 2.54149, 1.20769, 0.21012, NULL, 'revisão manual'),
  -- Questão 110 · CN · Biologia · Evolução · H16
  (2022, 110, 2, NULL, 'CN', 'Biologia', 'Evolução', 16, 141712, 'Desde a proposição da teoria de seleção natural  
por Darwin, os seres vivos nunca mais foram olhados  
da mesma forma. No que diz respeito à reprodução de  
anfíbios anuros, os cientistas já descreveram diferentes  
padrões reprodutivos, como os exemplificados a seguir:  
Espécie 1 – As fêmeas produzem cerca de  
5 000 gametas, que são fecundados na água, em  
lagoas temporárias de estação chuvosa. Todo o  
desenvolvimento embrionário, do ovo à metamorfose,  
ocorre, nesse ambiente, independente dos pais.  
Espécie 2 – As fêmeas produzem aproximadamente  
200 gametas, que são depositados em poças próximas a  
corpos-d’água. Os embriões são vigiados pelos machos  
durante boa parte do seu desenvolvimento.  
Espécie 3 – As fêmeas produzem por volta de  
20 gametas, que são fecundados sobre a superfície das  
folhas de plantas cujos galhos estão dispostos acima da  
superfície de corpos-d’água e aí se desenvolvem até  
a eclosão.  
Espécie 4 – As fêmeas produzem poucos gametas  
que, quando fecundados, são “abocanhados” pelos  
machos. Os embriões se desenvolvem no interior do  
saco vocal do macho até a metamorfose, quando saem  
através da boca do pai.

Os padrões descritos evidenciam que', 'D', 1.87507, 0.91052, 0.15109, NULL, 'palavras-chave'),
  -- Questão 111 · CN · Física · Gravitação e astronomia · H17
  (2022, 111, 2, NULL, 'CN', 'Física', 'Gravitação e astronomia', 17, 43073, 'O eixo de rotação da Terra apresenta uma inclinação  
em relação ao plano de sua órbita em torno do Sol,  
interferindo na duração do dia e da noite ao longo do ano.

![](/midia/enem/2022/q111/12bd97ef-3334-4258-aec9-17981bd0b299.webp)

Uma pessoa instala em sua residência uma placa  
fotovoltaica, que transforma energia solar em elétrica.  
Ela monitora a energia total produzida por essa placa  
em 4 dias do ano, ensolarados e sem nuvens, e lança os  
resultados no gráfico.

![](/midia/enem/2022/q111/b90aa72c-e072-4867-955a-bb795396fd8e.webp)

Disponível em: www.fisica.ufpr.br. Acesso em: 27 maio 2022 (adaptado)

Próximo a que região se situa a residência onde as placas
foram instaladas?', 'A', 1.48588, 0.96735, 0.24215, NULL, 'palavras-chave'),
  -- Questão 112 · CN · Física · Mecânica: movimento e forças · H7
  (2022, 112, 2, NULL, 'CN', 'Física', 'Mecânica: movimento e forças', 7, 89554, 'Um pai faz um balanço utilizando dois segmentos paralelos e iguais da mesma corda para fixar uma tábua a uma barra horizontal. Por segurança, opta por um tipo de corda cuja tensão de ruptura seja 25% superior à tensão máxima calculada nas seguintes condições:

• O ângulo máximo atingido pelo balanço em relação  
à vertical é igual a 90°;

• Os filhos utilizarão o balanço até que tenham uma  
massa de 24 kg.

Além disso, ele aproxima o movimento do balanço para o movimento circular uniforme, considera que a aceleração da gravidade é igual a 10  m/s² se despreza forças dissipativas.

Qual é a tensão de ruptura da corda escolhida?', 'D', NULL, NULL, NULL, 'Parâmetros não estimados na calibração: item desconsiderado pelo INEP no cálculo da nota', 'palavras-chave'),
  -- Questão 113 · CN · Química · Oxirredução, eletroquímica e termoquímica · H19
  (2022, 113, 2, NULL, 'CN', 'Química', 'Oxirredução, eletroquímica e termoquímica', 19, 141605, 'A nanotecnologia é responsável pelo aprimoramento de diversos materiais, incluindo os que são impactados com a presença de poluentes e da umidade na atmosfera, causadores de corrosão. O processo de corrosão é espontâneo e provoca a deterioração de metais como o ferro, que, em presença de oxigênio e água, sofre oxidação, conforme ilustra a equação química:

![](/midia/enem/2022/q113/0e055873-ce28-47e0-a1d2-5b5f817a3363.webp)

Uma forma de garantir a durabilidade da estrutura metálica e a sua resistência à umidade consiste na deposição de filmes finos nanocerâmicos à base de zircônia (ZrO2) e alumina (Al2O3) sobre a superfície do objeto que se deseja proteger.

CLEMENTE, G. A. B. F. et al. O uso de materiais híbridos ou nanocompósitos como revestimentos anticorrosivos do aço. **Química Nova**, n. 9, 2021 (adaptado)

Essa nanotecnologia aplicada na proteção contra a corrosão se baseia no(a)', 'D', NULL, NULL, NULL, 'Parâmetros não convergiram na calibração: item desconsiderado pelo INEP no cálculo da nota', 'palavras-chave'),
  -- Questão 114 · CN · Biologia · Citologia e bioquímica · H15
  (2022, 114, 2, NULL, 'CN', 'Biologia', 'Citologia e bioquímica', 15, 117854, 'As células da epiderme da folha da _Tradescantia pallida purpurea_, uma herbácea popularmente conhecida como trapoeraba-roxa, contém um vacúolo onde se encontra um pigmento que dá a coloração arroxeada a esse tecido. Em um experimento, um corte da epiderme de uma folha da trapoeraba-roxa foi imerso em ambiente hipotônico e, logo em seguida, foi colocado em uma lâmina e observado em microscópio óptico.

Durante a observação desse corte, foi possível identificar o(a)', 'C', 3.55169, 1.49398, 0.20257, NULL, 'palavras-chave'),
  -- Questão 115 · CN · Física · Calor e termodinâmica · H12
  (2022, 115, 2, NULL, 'CN', 'Física', 'Calor e termodinâmica', 12, 141545, 'A variação da incidência de radiação solar sobre a superfície da Terra resulta em uma variação de temperatura ao longo de um dia denominada amplitude térmica. Edificações e pavimentações realizadas nas áreas urbanas contribuem para alterar as amplitudes térmicas dessas regiões, em comparação com regiões que mantêm suas características naturais, com presença de vegetação e água, já que o calor específico do concreto é inferior ao da água. Assim, parte da avaliação do impacto ambiental que a presença de concreto proporciona às áreas urbanas consiste em considerar a substituição da área concretada por um mesmo volume de água e comparar as variações de temperatura devido à absorção da radiação solar nas duas situações (concretada e alagada). Desprezando os efeitos da evaporação e considerando que toda a radiação é absorvida, essa avaliação pode ser realizada com os seguintes dados

![](/midia/enem/2022/q115/f65d0159-593c-4da2-84b5-1a0f297f96f9.webp)

ROMERO, M. A. B. et al. **Mudanças climáticas e ilhas de calor urbanas**. Brasília: UnB; ETB, 2019 (adaptado)

A razão entre as variações de temperatura nas áreas concretada e alagada é mais próxima de', 'B', 2.33494, 1.44802, 0.20932, NULL, 'palavras-chave'),
  -- Questão 116 · CN · Física · Eletricidade e magnetismo · H6
  (2022, 116, 2, NULL, 'CN', 'Física', 'Eletricidade e magnetismo', 6, 78377, 'O manual de uma ducha elétrica informa que seus três níveis de aquecimento (morno, quente e superquente) apresentam as seguintes variações de temperatura da água em função de sua vazão:

![](/midia/enem/2022/q116/f941cbba-7b0c-4b5d-98db-2616e2001f8c.webp)

Utiliza-se um disjuntor para proteger o circuito dessa ducha contra sobrecargas elétricas em qualquer nível de aquecimento. Por padrão, o disjuntor é especificado pela corrente nominal igual ao múltiplo de 5 A imediatamente superior à corrente máxima do circuito. Considere que a ducha deve ser ligada em 220 V e que toda a energia é dissipada através da resistência do chuveiro e convertida em energia térmica transferida para a água, que apresenta calor específico de 4,2 e J/gº C densidade de 1 000 g/L

O disjuntor adequado para a proteção dessa ducha é especificado por:', 'B', 0.60239, 2.40137, 0.12017, NULL, 'palavras-chave'),
  -- Questão 117 · CN · Química · Transformações e reações químicas · H17
  (2022, 117, 2, NULL, 'CN', 'Química', 'Transformações e reações químicas', 17, 97761, 'Um grupo de alunos realizou um experimento para observar algumas propriedades dos ácidos, adicionando um pedaço de mármore (CaCO3 ) a uma solução aquosa de ácido clorídrico (HCl), observando a liberação de um gás e o aumento da temperatura.

![](/midia/enem/2022/q117/d1b41872-c2bd-4e00-8425-9dc4e5436395.webp)

O gás obtido no experimento é o:', 'C', 0.8924, 1.01697, 0.29789, NULL, 'revisão manual'),
  -- Questão 118 · CN · Biologia · Fisiologia humana e animal · H14
  (2022, 118, 2, NULL, 'CN', 'Biologia', 'Fisiologia humana e animal', 14, 78716, 'Em 2002, foi publicado um artigo científico que  
relacionava alterações na produção de hormônios sexuais  
de sapos machos expostos à atrazina, um herbicida, com  
o desenvolvimento anômalo de seus caracteres sexuais  
primários e secundários. Entre os animais sujeitos à  
contaminação, observaram-se casos de hermafroditismo  
e desmasculinização da laringe. O estudo em questão  
comparou a concentração de um hormônio específico  
no sangue de machos expostos ao agrotóxico com a de  
outros machos e fêmeas que não o foram (controles).  
Os resultados podem ser vistos na figura.

![](/midia/enem/2022/q118/e51b0279-7825-425e-86cf-f1e144cd023e.webp)

HAYES, T. B. et al. Hermaphroditic, Demasculinized Frogs After Exposure to  
the Herbicide Atrazine at Low Ecologically Relevant Doses. **Proceedings of**  
**the National Academy of Sciences**, n. 8, 2002 (adaptado).

Com base nas informações do texto, qual é o hormônio
cujas concentrações estão representadas na figura?', 'C', 2.02681, 0.56741, 0.2452, NULL, 'palavras-chave'),
  -- Questão 119 · CN · Física · Eletricidade e magnetismo · H5
  (2022, 119, 2, NULL, 'CN', 'Física', 'Eletricidade e magnetismo', 5, 64203, 'Uma lanterna funciona com três pilhas de resistência interna igual a 0,5 Ω cada, ligadas em série. Quando posicionadas corretamente, devem acender a lâmpada incandescente de especificações 4,5 W e 4,5 V. Cada pilha na posição correta gera uma f.e.m. (força eletromotriz) de 1,5 V. Uma pessoa, ao trocar as pilhas da lanterna, comete o equívoco de inverter a posição de uma das pilhas. Considere que as pilhas mantêm contato independentemente da posição.

Com esse equívoco, qual é a intensidade de corrente que passa pela lâmpada ao se ligar a lanterna?', 'A', NULL, NULL, NULL, 'Correlação bisserial negativa: item desconsiderado pelo INEP no cálculo da nota', 'palavras-chave'),
  -- Questão 120 · CN · Biologia · Citologia e bioquímica · H15
  (2022, 120, 2, NULL, 'CN', 'Biologia', 'Citologia e bioquímica', 15, 96244, 'Em uma aula prática de bioquímica, para medir a atividade catalítica da enzima catalase, foram realizados seis ensaios independentes, nas mesmas condições, variando-se apenas a temperatura. A catalase decompõe o peróxido de hidrogênio (H2O2), produzindo água e oxigênio. Os resultados dos ensaios estão apresentados no quadro.

![](/midia/enem/2022/q120/b54f40a5-6770-42c7-8756-63acaa5dcbd1.webp)

Os diferentes resultados dos ensaios justificam-se pelo(a)', 'E', 5.67249, 1.52791, 0.14273, NULL, 'palavras-chave'),
  -- Questão 121 · CN · Biologia · Saúde e doenças · H14
  (2022, 121, 2, NULL, 'CN', 'Biologia', 'Saúde e doenças', 14, 37769, 'Antimicrobianos são substâncias naturais ou sintéticas que têm capacidade de matar ou inibir o crescimento de microrganismos. A tabela apresenta uma lista de antimicrobianos hipotéticos, bem como suas ações e efeitos sobre o metabolismo microbiano.

![](/midia/enem/2022/q121/e95c1ba6-6673-4d72-b19e-9f022900d737.webp)

Qual dos antimicrobianos deve ser utilizado para curar uma infecção causada por um fungo sem afetar as bactérias da microbiota normal do organismo?', 'B', 1.78429, 2.50062, 0.27071, NULL, 'palavras-chave'),
  -- Questão 122 · CN · Biologia · Fisiologia humana e animal · H11
  (2022, 122, 2, NULL, 'CN', 'Biologia', 'Fisiologia humana e animal', 11, 141726, 'O veneno da cascavel pode causar hemorragia com risco de morte a quem é picado pela serpente. No entanto, pesquisadores do Brasil e da Bélgica desenvolveram uma molécula de interesse farmacêutico, a PEG-collineína-1,  
a partir de uma proteína encontrada no veneno dessa cobra, capaz de modular a coagulação sanguínea. Embora a técnica não seja nova, foi a primeira vez que o método foi usado a partir de uma toxina animal na sua forma recombinante, ou seja, produzida em laboratório por um fungo geneticamente modificado.

JULIÃO, A. **Técnica modifica proteína do veneno de cascavel e permite**  
**criar fármaco que modula a coagulação sanguínea**. Disponível em:  
https://agencia.fapesp.br. Acesso em: 22 nov. 2021 (adaptado).

Esse novo medicamento apresenta potencial aplicação para', 'A', 1.68577, 1.10708, 0.12014, NULL, 'palavras-chave'),
  -- Questão 123 · CN · Física · Gravitação e astronomia · H3
  (2022, 123, 2, NULL, 'CN', 'Física', 'Gravitação e astronomia', 3, 87998, 'Um Buraco Negro é um corpo celeste que possui uma grande quantidade de matéria concentrada em uma pequena região do espaço, de modo que sua força gravitacional é tão grande que qualquer partícula fica aprisionada em sua superfície, inclusive a luz. O raio dessa região caracteriza uma superfície-limite, chamada de horizonte de eventos, da qual nada consegue escapar. Considere que o Sol foi instantaneamente substituído por um Buraco Negro com a mesma massa solar, de modo que o seu horizonte de eventos seja de aproximadamente 3,0 km.

SCHWARZSCHILD, K. **On the Gravitational Field of a Mass Point According to** **Einstein’s Theory**. Disponível em: arxiv.org. Acesso em: 26 maio 2022 (adaptado).

Após a substituição descrita, o que aconteceria aos planetas do Sistema Solar?', 'E', 2.14355, 1.77912, 0.08867, NULL, 'palavras-chave'),
  -- Questão 124 · CN · Química · Oxirredução, eletroquímica e termoquímica · H10
  (2022, 124, 2, NULL, 'CN', 'Química', 'Oxirredução, eletroquímica e termoquímica', 10, 141547, 'Durante o ano de 2020, impulsionado pela necessidade de respostas rápidas e eficientes para desinfectar ambientes de possíveis contaminações com o SARS-CoV-2, causador da covid-19, diversas alternativas foram buscadas para  
os procedimentos de descontaminação de materiais e ambientes. Entre elas, o uso de ozônio em meio aquoso como agente sanitizante para pulverização em humanos e equipamentos de proteção em câmaras ou túneis, higienização de automóveis e de ambientes fechados e descontaminação de trajes. No entanto, pouca atenção foi dada à toxicidade do ozônio, à formação de subprodutos, ao  
nível de concentração segura e às precauções necessárias.

LIMA, M. J. A.; FELIX, E. P.; CARDOSO, A. A. Aplicações e implicações do ozônio na indústria, ambiente e saúde. Química Nova, n. 9, 2021 (adaptado).

O grande risco envolvido no emprego indiscriminado dessa substância deve-se à sua ação química como', 'B', 1.90673, 1.4644, 0.34041, NULL, 'revisão manual'),
  -- Questão 125 · CN · Biologia · Genética e biotecnologia · H13
  (2022, 125, 2, NULL, 'CN', 'Biologia', 'Genética e biotecnologia', 13, 98106, 'Na figura está representado o mosaicismo em função da inativação aleatória de um dos cromossomos X, que ocorre em todas as mulheres sem alterações  patológicas.

![](/midia/enem/2022/q125/310a2901-c53f-4fd3-86bd-17c5a2aa0b83.webp)

Entre mulheres heterozigotas para doenças determinadas por genes recessivos ligados ao sexo, essa inativação tem como consequência a ocorrência de', 'E', 2.46518, 1.46748, 0.06515, NULL, 'palavras-chave'),
  -- Questão 126 · CN · Química · Materiais, ligações e propriedades · H8
  (2022, 126, 2, NULL, 'CN', 'Química', 'Materiais, ligações e propriedades', 8, 83901, 'A água bruta coletada de mananciais apresenta alto índice de sólidos suspensos, o que a deixa com um aspecto turvo. Para se obter uma água límpida e potável, ela deve passar por um processo de purificação numa estação de tratamento de água. Nesse processo, as principais etapas são, nesta ordem: coagulação, decantação, filtração, desinfecção e fluoretação.

Qual é a etapa de retirada de grande parte desses sólidos?', 'B', 0.40583, 2.51676, 0.00918, NULL, 'palavras-chave'),
  -- Questão 127 · CN · Biologia · Citologia e bioquímica · H9
  (2022, 127, 2, NULL, 'CN', 'Biologia', 'Citologia e bioquímica', 9, 111431, 'Os ursos, por não apresentarem uma hibernação verdadeira, acordam por causa da presença de termogenina, uma proteína mitocondrial que impede a chegada dos prótons até a ATP sintetase, gerando calor. Esse calor é importante para aquecer o organismo, permitindo seu despertar.

SADAVA, D. et al. Vida: a ciência da biologia. Porto Alegre: Artmed, 2009 (adaptado).

Em qual etapa do metabolismo energético celular a termogenina interfere?', 'E', 3.48192, 1.70426, 0.15448, NULL, 'palavras-chave'),
  -- Questão 128 · CN · Física · Eletricidade e magnetismo · H2
  (2022, 128, 2, NULL, 'CN', 'Física', 'Eletricidade e magnetismo', 2, 111613, 'A fim de classificar as melhores rotas em um aplicativo de trânsito, um pesquisador propõe um modelo com base em circuitos elétricos. Nesse modelo, a corrente representa o número de carros que passam por um ponto da pista no intervalo de 1 s. A diferença de potencial (d.d.p.) corresponde à quantidade de energia por carro necessária para o deslocamento de 1 m. De forma análoga à lei de Ohm, cada via é classificada pela sua resistência, sendo a de maior resistência a mais congestionada. O aplicativo mostra as rotas em ordem crescente, ou seja, da rota de menor para a de maior resistência.  
Como teste para o sistema, são utilizadas três possíveis vias para uma viagem de A até B, com os valores de d.d.p. e corrente conforme a tabela.

![](/midia/enem/2022/q128/3e38e718-2857-4d65-849c-ddc36f19f455.webp)

Nesse teste, a ordenação das rotas indicadas pelo aplicativo será:', 'A', 3.25053, 1.20513, 0.08404, NULL, 'palavras-chave'),
  -- Questão 129 · CN · Química · Soluções, ácidos, bases e sais · H9
  (2022, 129, 2, NULL, 'CN', 'Química', 'Soluções, ácidos, bases e sais', 9, 28632, 'O esquema representa o ciclo do nitrogênio:

![](/midia/enem/2022/q129/dceda47e-3511-452d-b376-b192e2b975f6.webp)

A chuva ácida interfere no ciclo do nitrogênio, principalmente, por proporcionar uma diminuição do pH do solo e da atmosfera, alterando a concentração dos compostos presentes nesse ciclo.

Disponível em: http://scienceprojectideasforkids.com. Acesso em: 6 ago. 2012 (adaptado).

Em um solo de menor pH, será favorecida a formação de:', 'C', 1.99451, 1.78678, 0.12762, NULL, 'palavras-chave'),
  -- Questão 130 · CN · Física · Ondas, óptica e radiação · H22
  (2022, 130, 2, NULL, 'CN', 'Física', 'Ondas, óptica e radiação', 22, 126560, 'No processo de captação da luz pelo olho para a formação de imagens estão envolvidas duas estruturas celulares: os cones e os bastonetes. Os cones são sensíveis à energia dos fótons, e os bastonetes, à quantidade de fótons incidentes. A energia dos fótons que compõem os raios luminosos está associada à sua frequência, e a intensidade, ao número de fótons incidentes.

Um animal que tem bastonetes mais sensíveis irá', 'C', 2.41581, 0.78824, 0.19317, NULL, 'palavras-chave'),
  -- Questão 131 · CN · Química · Química orgânica · H3
  (2022, 131, 2, NULL, 'CN', 'Química', 'Química orgânica', 3, 141503, 'De modo geral, a palavra “aromático” invoca associações agradáveis, como cheiro de café fresco ou de um pão doce de canela.Associações similares ocorriam no passadoda história da químicaorgânica, quando os compostosditos “aromáticos” apresentavam um odor agradável e foram isolados de óleos naturais. À medida que as estruturas desses compostos eram elucidadas, foi se descobrindo que vários deles continham uma unidade estrutural específica. Os compostos aromáticos que continham essa unidade estrutural tornaram-se parte de uma grande família, muito mais com base em suas estruturas eletrônicas do que nos seus cheiros, como as substâncias a seguir, encontradas em óleos vegetais.

![](/midia/enem/2022/q131/ffcbcff6-5bd4-4fa3-a11b-17bd34a48ade.webp)

SOLOMONS, T. W. G.; FRYHLE, C. B. Química orgânica. Rio de Janeiro: LTC, 2009 (adaptado).

A característica estrutural dessa família de compostos é a presença de', 'C', 2.86161, 0.4948, 0.1606, NULL, 'palavras-chave'),
  -- Questão 132 · CN · Biologia · Saúde e doenças · H4
  (2022, 132, 2, NULL, 'CN', 'Biologia', 'Saúde e doenças', 4, 88655, 'Os resultados de um ensaio clínico randomizado na Indonésia apontaram uma redução de 77% dos casos de dengue nas áreas que receberam o mosquito _Aedes aegypti_ infectado com a bactéria _Wolbachia_. Trata-se da mesma técnica utilizada no Brasil pelo Método _Wolbachia_, iniciativa conduzida pela Fundação Oswaldo Cruz — Fiocruz. Essa bactéria induz a redução da carga viral no mosquito e, consequentemente, o número de casos de dengue na área, sendo repassada por meio do cruzamento entre os insetos. Como essa bactéria é um organismo intracelular e o vírus também precisa entrar nas células para se reproduzir, ambos necessitarão de recursos comuns.

COSTA, G. Agência Fiocruz de Notícias. Estudo confirma eficácia do Método Wolbachia para dengue. Disponível em: https://portal.fiocruz.br. Acesso em: 3 jun. 2022 (adaptado).

Essa tecnologia utilizada no combate à dengue consiste na', 'D', 3.82953, 0.85524, 0.11511, NULL, 'palavras-chave'),
  -- Questão 133 · CN · Biologia · Fisiologia humana e animal · H2
  (2022, 133, 2, NULL, 'CN', 'Biologia', 'Fisiologia humana e animal', 2, 31313, 'O protozoário Trypanosoma cruzi, causador da doença de Chagas, pode ser a nova arma da medicina contra o câncer. Pesquisadores brasileiros conseguiram criar uma vacina contra a doença usando uma variação do protozoário incapaz de desencadear a patologia (não patogênico). Para isso, realizaram uma modificação genética criando um T. cruzi capaz de produzir também moléculas fabricadas pelas células tumorais. Quando o organismo inicia o combate ao protozoário, entra em contato também com a molécula tumoral, que passa a ser  
vista também pelo sistema imune como um indicador de células do protozoário. Depois de induzidas as defesas, estas passam a destruir todas as células com a molécula tumoral, como se lutassem apenas contra o protozoário.

Disponível em: www.estadao.com.br. Acesso em: 1 mar. 2012 (adaptado).

Qual o mecanismo utilizado no experimento para enganar as células de defesa, fazendo com que ataquem o tumor?', 'D', 1.71131, 1.42364, 0.1615, NULL, 'revisão manual'),
  -- Questão 134 · CN · Física · Ondas, óptica e radiação · H1
  (2022, 134, 2, NULL, 'CN', 'Física', 'Ondas, óptica e radiação', 1, 75845, 'O sinal sonoro oriundo da queda de um grande bloco de gelo de uma geleira é detectado por dois dispositivos situados em um barco, sendo que o detector A está imerso em água e o B, na proa da embarcação. Sabe-se que a velocidade do som na água é de 1 540 m/s e no ar é de 340 m/s.

![](/midia/enem/2022/q134/6f7c3bcf-80c1-4d07-b043-70cbb639bb8f.webp)

Os gráficos indicam, em tempo real, o sinal sonoro detectado pelos dois dispositivos, os quais foram ligados simultaneamente em um instante anterior à queda do bloco de gelo. Ao comparar pontos correspondentes desse sinal em cada dispositivo, é possível obter informações sobre a onda sonora.

![](/midia/enem/2022/q134/01e05752-c516-4e12-a9f8-bcbe4b1e0296.webp)

A distância L, em metro, entre o barco e a geleira é mais próxima de', 'D', NULL, NULL, NULL, 'Parâmetros não estimados na calibração: item desconsiderado pelo INEP no cálculo da nota', 'revisão manual'),
  -- Questão 135 · CN · Física · Ondas, óptica e radiação · H1
  (2022, 135, 2, NULL, 'CN', 'Física', 'Ondas, óptica e radiação', 1, 82765, 'Em 2002, um mecânico da cidade mineira de Uberaba (MG) teve uma ideia para economizar o consumo de energia elétrica e iluminar a própria casa num dia de sol. Para isso, ele utilizou garrafas plásticas PET com água e cloro, conforme ilustram as figuras. Cada garrafa foi fixada ao telhado de sua casa em um buraco com diâmetro igual ao da garrafa, muito maior que o comprimento de onda da luz. Nos últimos dois anos, sua ideia já alcançou diversas partes do mundo e deve atingir a marca de 1 milhão de casas utilizando a “luz engarrafada”.

![](/midia/enem/2022/q135/c20e9e98-446f-4342-bf88-a8069abe0fb9.webp)

ZOBEL, G. Brasileiro inventor de “Iuz engarrafada” tem ideia espalhada pelo mundo.  
Disponível em: www.bbc.com. Acesso em 23 jun. 2022 (adaptado)

Que fenômeno óptico explica o funcionamento da “luz engarrafada”?', 'E', 0.98394, 1.03388, 0.00428, NULL, 'palavras-chave'),
  -- Questão 136 · MT · Matemática · Leitura de gráficos e tabelas · H25
  (2022, 136, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 25, 97590, 'Uma máquina em operação tem sua temperatura T monitorada por meio de um registro gráfico, ao longo do tempo t. Essa máquina possui um pistão cuja velocidade V varia com a temperatura T da máquina, de acordo com a expressão V=T²−4. Após a máquina funcionar durante o intervalo de tempo de 10 horas, o seu operador analisa o registro gráfico, apresentado na figura, para avaliar a necessidade de eventuais ajustes, sabendo que a máquina apresenta falhas de funcionamento quando a velocidade do pistão se anula.

![](/midia/enem/2022/q136/44fff3b7-9ad8-4f02-8262-5b4c015a8228.webp)

Quantas vezes a velocidade do pistão se anulou durante as 10 horas de funcionamento?', 'E', 2.33252, 2.40899, 0.14217, NULL, 'habilidade'),
  -- Questão 137 · MT · Matemática · Probabilidade · H28
  (2022, 137, 2, NULL, 'MT', 'Matemática', 'Probabilidade', 28, 86840, 'A World Series é a decisão do campeonato norte-americano de beisebol. Os dois times que chegam  
a essa fase jogam, entre si, até sete partidas. O primeiro desses times que completar quatro vitórias é declarado campeão.

Considere que, em todas as partidas, a probabilidade de qualquer um dos dois times vencer é sempre ![](/midia/enem/2022/q137/091aafba-f2dd-4f19-9655-73e6bd1599b6.webp)

Qual é a probabilidade de o time campeão ser aquele que venceu a primeira partida da World Series?', 'C', 0.24441, 4.65334, 0.03228, NULL, 'palavras-chave'),
  -- Questão 138 · MT · Matemática · Estatística · H27
  (2022, 138, 2, NULL, 'MT', 'Matemática', 'Estatística', 27, 30493, 'O gráfico apresenta os totais de receitas e despesas de uma empresa, expressos em milhão de reais, no  
decorrer dos meses de um determinado ano. A empresa obtém lucro quando a diferença entre receita e despesa é positiva e tem prejuízo quando essa diferença é negativa.

![](/midia/enem/2022/q138/d738a15a-a083-4720-af91-80d2b3259c9f.webp)

Qual é a mediana, em milhão de reais, dos valores dos lucros apurados pela empresa nesse ano?', 'D', 0.80375, 2.27556, 0.12859, NULL, 'habilidade'),
  -- Questão 139 · MT · Matemática · Grandezas, medidas e escalas · H11
  (2022, 139, 2, NULL, 'MT', 'Matemática', 'Grandezas, medidas e escalas', 11, 117973, 'Um casal está reformando a cozinha de casa e decidiu comprar um refrigerador novo. Observando a planta da nova cozinha, desenhada na escala de 1: 50, notaram que o espaço destinado ao refrigerador tinha 3,8 cm de altura e 1,6 cm de largura. Eles sabem que os fabricantes de refrigeradores indicam que, para um bom funcionamento e fácil manejo na limpeza, esses eletrodomésticos devem ser colocados em espaços que permitam uma distância de, pelo menos, 10 cm de outros móveis ou paredes, tanto na parte superior quanto nas laterais. O casal comprou um refrigerador que caberia no local a ele destinado na nova cozinha, seguindo as instruções do fabricante.

Esse refrigerador tem altura e largura máximas, em metro, respectivamente, iguais a', 'A', 1.87291, 2.86025, 0.18347, NULL, 'habilidade'),
  -- Questão 140 · MT · Matemática · Aritmética e conjuntos numéricos · H3
  (2022, 140, 2, NULL, 'MT', 'Matemática', 'Aritmética e conjuntos numéricos', 3, 10500, 'Foram convidadas 32 equipes para um torneio de futebol, que foram divididas em 8 grupos com 4 equipes, sendo que, dentro de um grupo, cada equipe disputa uma única partida contra cada uma das demais equipes de seu grupo. A primeira e a segunda colocadas de cada grupo seguem para realizar as 8 partidas da próxima fase do torneio, chamada oitavas de final. Os vencedores das partidas das oitavas de final seguem para jogar as 4 partidas das quartas de final. Os vencedores das quartas de final disputam as 2 partidas das semifinais, e os vencedores avançam para a grande final, que define a campeã do torneio.

Pelas regras do torneio, cada equipe deve ter um período de descanso de, no mínimo, 3 dias entre dois jogos por ela disputados, ou seja, se um time disputar uma partida, por exemplo, num domingo, só poderá disputar a partida seguinte a partir da quinta-feira da mesma semana.

O número mínimo de dias necessários para a realização desse torneio é', 'B', 1.57712, 3.30111, 0.16855, NULL, 'habilidade'),
  -- Questão 141 · MT · Matemática · Probabilidade · H28
  (2022, 141, 2, NULL, 'MT', 'Matemática', 'Probabilidade', 28, 89637, 'Em um jogo de bingo, as cartelas contêm 16 quadrículas dispostas em linhas e colunas. Cada quadrícula tem impresso um número, dentre os inteiros de 1 a 50, sem repetição de número. Na primeira rodada, um número é sorteado, aleatoriamente, dentre os 50 possíveis. Em todas as rodadas, o número sorteado é descartado e não participa dos sorteios das rodadas seguintes. Caso o jogador tenha em sua cartela o número sorteado, ele o assinala na cartela. Ganha o jogador que primeiro conseguir preencher quatro quadrículas que formam uma linha, uma coluna ou uma diagonal, conforme os tipos de situações ilustradas na Figura 1.

![](/midia/enem/2022/q141/e8e788ea-4e28-4ceb-b928-494d2ca68033.webp)

O jogo inicia e, nas quatro primeiras rodadas, foram sorteados os seguintes números: 03, 27, 07 e 48. Ao final da quarta rodada, somente Pedro possuía uma cartela que continha esses quatro números sorteados, sendo que todos os demais jogadores conseguiram assinalar, no máximo, um desses números em suas cartelas. Observe na Figura 2 o cartão de Pedro após as quatro primeiras rodadas.

![](/midia/enem/2022/q141/1e77b1bf-38e6-4145-b78b-91be4088bc11.webp)

A probabilidade de Pedro ganhar o jogo em uma das duas próximas rodadas é', 'E', NULL, NULL, NULL, 'Parâmetros não convergiram na calibração: item desconsiderado pelo INEP no cálculo da nota', 'palavras-chave'),
  -- Questão 142 · MT · Matemática · Análise combinatória · H5
  (2022, 142, 2, NULL, 'MT', 'Matemática', 'Análise combinatória', 5, 86499, 'Uma montadora de automóveis divulgou que oferta a seus clientes mais de 1 000 configurações diferentes de carro, variando o modelo, a motorização, os opcionais e a cor do veículo. Atualmente, ela oferece 7 modelos de carros com 2 tipos de motores: 1.0 e 1.6. Já em relação aos opcionais, existem 3 escolhas possíveis: central multimídia, rodas de liga leve e bancos de couro, podendo o cliente optar por incluir um, dois, três ou nenhum dos opcionais disponíveis.

Para ser fiel à divulgação feita, a quantidade mínima de cores que a montadora deverá disponibilizar a seus clientes é', 'B', 2.93676, 3.33565, 0.21207, NULL, 'revisão manual'),
  -- Questão 143 · MT · Matemática · Geometria espacial · H7
  (2022, 143, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 7, 5961, 'Dentre as diversas planificações possíveis para o cubo, uma delas é a que se encontra apresentada na Figura 1.

![](/midia/enem/2022/q143/4da64c40-da53-4205-b673-aa5b6274e3e2.webp)

Em um cubo, foram pintados, em três de suas faces, quadrados de cor cinza escura, que ocupam um quarto dessas faces, tendo esses três quadrados um vértice em comum, conforme ilustrado na Figura 2.

![](/midia/enem/2022/q143/a05cd294-5321-4c85-a081-a86ed7aa3e39.webp)

A planificação do cubo da Figura 2, conforme o tipo de planificação apresentada na Figura 1, é', 'D', 0.9032, 2.45135, 0.1617, NULL, 'palavras-chave'),
  -- Questão 144 · MT · Matemática · Aritmética e conjuntos numéricos · H1
  (2022, 144, 2, NULL, 'MT', 'Matemática', 'Aritmética e conjuntos numéricos', 1, 75829, 'Cada número que identifica uma agência bancária tem quatro dígitos: ![](/midia/enem/2022/q144/2c8c344f-3729-4f6b-bbb9-24097d77f58a.webp),![](/midia/enem/2022/q144/6af5740b-feed-4fd4-bde9-486ad2f96240.webp),![](/midia/enem/2022/q144/4af33750-a0d5-4acc-abe1-c004f5d8451e.webp),![](/midia/enem/2022/q144/ea762333-b644-495d-bd01-3c0bf752599a.webp) mais um dígito verificador ![](/midia/enem/2022/q144/f4712f57-56ec-4a65-9e2e-f7c34f4b775f.webp).

![](/midia/enem/2022/q144/f88bc2d5-7b64-49cf-bd9d-28ddde048358.webp)

Todos esses dígitos são números naturais pertencentes ao conjunto {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}. Para a determinação de N5, primeiramente multiplica-se  
ordenadamente os quatro primeiros dígitos do número da agência por 5, 4, 3 e 2, respectivamente, somam-se os resultados e obtém-se S = 5 ![](/midia/enem/2022/q144/981157e8-d269-4be5-8aba-f496109d3f31.webp)\+ 4 ![](/midia/enem/2022/q144/89772d85-6273-49c5-95e4-569b4014ca22.webp)\+ 3 ![](/midia/enem/2022/q144/164c2b6f-8be5-4ca3-88f7-12fe5a5e872c.webp)\+ 2 ![](/midia/enem/2022/q144/ad29c509-a515-4ae6-9d86-451780d68e14.webp). Posteriormente, encontra-se o resto da divisão de S por 11, denotando por R esse resto. Dessa forma, N5 é a diferença 11 − R.  
Considere o número de uma agência bancária cujos quatro primeiros dígitos são 0100.

Qual é o dígito verificador N5 dessa agência bancária?', 'C', 1.18017, 1.92189, 0.16856, NULL, 'habilidade'),
  -- Questão 145 · MT · Matemática · Razão, proporção e regra de três · H18
  (2022, 145, 2, NULL, 'MT', 'Matemática', 'Razão, proporção e regra de três', 18, 117651, 'O pacote básico de um jogo para smartphone, que é vendido a R$ 50,00, contém 2 000 gemas e 100 000 moedas de ouro, que são itens utilizáveis nesse jogo.  
A empresa que comercializa esse jogo decidiu criar um pacote especial que será vendido a R$ 100,00 e que se diferenciará do pacote básico por apresentar maiores quantidades de gemas e moedas de ouro. Para estimular as vendas desse novo pacote, a empresa decidiu inserir nele 6 000 gemas a mais, em relação ao que o cliente teria caso optasse por comprar, com a mesma quantia, dois pacotes básicos.

A quantidade de moedas de ouro que a empresa deverá inserir ao pacote especial, para que seja mantida a mesma proporção existente entre as quantidades de gemas e de moedas de ouro contidas no pacote básico, é', 'E', 0.51115, 2.58401, 0.0088, NULL, 'habilidade'),
  -- Questão 146 · MT · Matemática · Equações e inequações · H21
  (2022, 146, 2, NULL, 'MT', 'Matemática', 'Equações e inequações', 21, 95509, 'Um parque tem dois circuitos de tamanhos diferentes para corridas. Um corredor treina nesse parque e, no primeiro dia, inicia seu treino percorrendo  
3 voltas em torno do circuito maior e 2 voltas em torno do menor, perfazendo um total de 1 800 m. Em seguida, dando continuidade a seu treino, corre mais 2 voltas em torno do circuito maior e 1 volta em torno do menor,  
percorrendo mais 1 100 m.

No segundo dia, ele pretende percorrer 5 000 m nos circuitos do parque, fazendo um número inteiro de voltas em torno deles e de modo que o número de voltas seja o maior possível.

A soma do número de voltas em torno dos dois circuitos, no segundo dia, será', 'E', 2.27997, 2.41531, 0.11329, NULL, 'revisão manual'),
  -- Questão 147 · MT · Matemática · Razão, proporção e regra de três · H17
  (2022, 147, 2, NULL, 'MT', 'Matemática', 'Razão, proporção e regra de três', 17, 117820, 'Uma equipe de marketing digital foi contratada para aumentar as vendas de um produto ofertado em um site de comércio eletrônico. Para isso, elaborou um anúncio que, quando o cliente clica sobre ele, é direcionado  
para a página de vendas do produto. Esse anúncio foi divulgado em duas redes sociais, A e B, e foram obtidos os seguintes resultados:

• rede social A: o anúncio foi visualizado por 3 000 pessoas; 10% delas clicaram sobre o anúncio e foram redirecionadas para o site; 3% das que clicaram sobre o anúncio compraram o produto. O investimento feito para a publicação do anúncio nessa rede foi de R$ 100,00;

• rede social B: o anúncio foi visualizado por 1 000 pessoas; 30% delas clicaram sobre o anúncio e foram redirecionadas para o site; 2% das que  
clicaram sobre o anúncio compraram o produto. O investimento feito para a publicação do anúncio nessa rede foi de R$ 200,00.

Por experiência, o pessoal da equipe de marketing considera que a quantidade de novas pessoas que verão o anúncio é diretamente proporcional ao investimento realizado, e que a quantidade de pessoas que comprarão o produto também se manterá proporcional à quantidade de pessoas que clicarão sobre o anúncio.  
O responsável pelo produto decidiu, então, investir mais R$ 300,00 em cada uma das duas redes sociais para a divulgação desse anúncio e obteve, de fato, o aumento proporcional esperado na quantidade de clientes que compraram esse produto. Para classificar o aumento obtido na quantidade (Q) de compradores desse produto, em consequência dessa segunda divulgação, em relação aos resultados observados na primeira divulgação, o  
responsável pelo produto adotou o seguinte critério:

• Q ≤ 60%: não satisfatório;  
• 60% < Q ≤ 100%: regular;  
• 100% < Q ≤ 150%: bom;  
• 150% < Q ≤ 190%: muito bom;  
• 190% < Q ≤ 200%: excelente

O aumento na quantidade de compradores, em consequência dessa segunda divulgação, em relação
ao que foi registrado com a primeira divulgação, foi classificado como', 'C', 0.48694, 4.48651, 0.14739, NULL, 'habilidade'),
  -- Questão 148 · MT · Matemática · Razão, proporção e regra de três · H15
  (2022, 148, 2, NULL, 'MT', 'Matemática', 'Razão, proporção e regra de três', 15, 61248, 'A luminosidade _L_ de uma estrela está relacionada com o raio _R_ e com a temperatura _T_ dessa estrela segundo a Lei de Stefan-Boltzmann: ![](/midia/enem/2022/q148/00e98ef8-6901-4d38-91f1-1fa1afda8b14.webp) em que c é uma constante igual para todas as estrelas.

Disponível em: http://ciencia.hsw.uol.com.br. Acesso em: 22 nov. 2013 (adaptado)

Considere duas estrelas _E_ e _F_, sendo que a estrela _E_ tem metade do raio da estrela _F_ e o dobro da temperatura de _F_.

Indique por LE  e LF suas respectivas luminosidades.
A relação entre as luminosidades dessas duas estrelas é dada por', 'D', 2.61757, 2.2515, 0.1851, NULL, 'habilidade'),
  -- Questão 149 · MT · Matemática · Estatística · H27
  (2022, 149, 2, NULL, 'MT', 'Matemática', 'Estatística', 27, 111738, 'Uma das informações que pode auxiliar no dimensionamento do número de pediatras que devem atender em uma Unidade Básica de Saúde (UBS) é o número que representa a mediana da quantidade de crianças por família existente na região sob sua responsabilidade. O quadro mostra a distribuição das frequências do número de crianças por família na região de responsabilidade de uma UBS.

![](/midia/enem/2022/q149/d92eba46-c91d-43d9-accf-ec06c4506ac1.webp)

O número que representa a mediana da quantidade de crianças por família nessa região é', 'B', 2.64614, 2.2135, 0.24887, NULL, 'habilidade'),
  -- Questão 150 · MT · Matemática · Funções · H22
  (2022, 150, 2, NULL, 'MT', 'Matemática', 'Funções', 22, 85343, 'Em jogos de voleibol, um saque é invalidado se a bola atingir o teto do ginásio onde ocorre o jogo. Um jogador de uma equipe tem um saque que atinge uma grande altura. Seu recorde foi quando a batida do saque se iniciou a uma altura de 1,5 m do piso da quadra, e a trajetória da bola foi descrita pela parábola ![](/midia/enem/2022/q150/764fcc6a-f737-404f-867b-7caacf69134e.webp) , em que y representa a altura da bola em relação ao eixo x (das abscissas) que está localizado a 1,5 m do piso da quadra, como representado na figura. Suponha que em todas as partidas algum saque desse jogador atinja a mesma altura do seu recorde.

![](/midia/enem/2022/q150/0964fd1c-cef0-4132-981d-c148bd70f0aa.webp)

A equipe desse jogador participou de um torneio de voleibol no qual jogou cinco partidas, cada uma delas  
em um ginásio diferente. As alturas dos tetos desses ginásios, em relação aos pisos das quadras, são:  
• ginásio I: 17 m;  
• ginásio II: 18 m;  
• ginásio III: 19 m;  
• ginásio IV: 21 m;  
• ginásio V: 40 m.

O saque desse atleta foi invalidado', 'D', 2.13479, 3.22198, 0.12748, NULL, 'revisão manual'),
  -- Questão 151 · MT · Matemática · Razão, proporção e regra de três · H17
  (2022, 151, 2, NULL, 'MT', 'Matemática', 'Razão, proporção e regra de três', 17, 30053, 'Um médico faz o acompanhamento clínico de um grupo de pessoas que realizam atividades físicas diariamente. Ele observou que a perda média de massa dessas pessoas para cada hora de atividade física era de 1,5 kg. Sabendo que a massa de 1 L de água é de 1 kg, ele recomendou que ingerissem, ao longo das 3 horas seguintes ao final da atividade, uma quantidade total de água correspondente a 40% a mais do que a massa perdida na atividade física, para evitar desidratação.

Seguindo a recomendação médica, uma dessas pessoas ingeriu, certo dia, um total de 1,7 L de água após  
terminar seus exercícios físicos.

Para que a recomendação médica tenha efetivamente sido respeitada, a atividade física dessa pessoa, nesse dia, durou', 'C', 1.73381, 2.02109, 0.14967, NULL, 'habilidade'),
  -- Questão 152 · MT · Matemática · Razão, proporção e regra de três · H18
  (2022, 152, 2, NULL, 'MT', 'Matemática', 'Razão, proporção e regra de três', 18, 85228, 'Em uma sala de cinema, para garantir que os espectadores vejam toda a imagem projetada na tela, a disposição das poltronas deve obedecer à norma técnica da Associação Brasileira de Normas Técnicas (ABNT), que faz as seguintes indicações:  
• Distância mínima (Dmín) entre a tela de projeção e o encosto da poltrona da primeira fileira deve ser de, pelo menos, 60% da largura (L) da tela.  
• Distância máxima (Dmáx) entre a tela de projeção e o encosto da poltrona da última fileira deve ser o dobro da largura (L) da tela, sendo aceitável uma distância de até 2,9 vezes a largura (L) da tela.  
Para o espaçamento entre as fileiras de poltronas, é considerada a distância de 1 metro entre os encostos de poltronas em duas fileiras consecutivas.

Disponível em: www.ctav.gov.br. Acesso em: 14 nov. 2013.

Disponível em: www.ctav.gov.br. Acesso em: 14 nov. 2013.

![](/midia/enem/2022/q152/f182fb95-a05f-4d8d-bd7d-bbf7adf3d95b.webp)

Pretende-se ampliar essa sala, mantendo-se na mesma posição a tela e todas as poltronas já instaladas,  
ampliando-se ao máximo a sala para os fundos (área de instalação de novas poltronas), respeitando-se o limite aceitável da norma da ABNT. A intenção é aumentar, ao máximo, a quantidade de poltronas da sala, instalando-se novas unidades, iguais às já instaladas.

Quantas fileiras de poltronas a sala comportará após essa ampliação?', 'C', 2.1343, 3.73781, 0.24053, NULL, 'habilidade'),
  -- Questão 153 · MT · Matemática · Geometria espacial · H14
  (2022, 153, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 14, 86466, '![](/midia/enem/2022/q153/f85bbaf3-e20e-48e7-8a5f-143804fa1743.webp)

Uma empresa produz e vende um tipo de chocolate, maciço, em formato de cone circular reto com as medidas do diâmetro da base e da altura iguais a 8 cm e 10 cm, respectivamente, como apresenta a figura.

Devido a um aumento de preço dos ingredientes utilizados na produção desse chocolate, a empresa  
decide produzir esse mesmo tipo de chocolate com um volume 19% menor, no mesmo formato de cone circular reto com altura de 10 cm.

Para isso, a empresa produzirá esses novos chocolates com medida do raio da base, em centímetro, igual a', 'C', 2.96283, 2.44795, 0.21497, NULL, 'revisão manual'),
  -- Questão 154 · MT · Matemática · Porcentagem e matemática financeira · H3
  (2022, 154, 2, NULL, 'MT', 'Matemática', 'Porcentagem e matemática financeira', 3, 43182, 'Em janeiro de 2013, foram declaradas 1 794 272 admissões e 1 765 372 desligamentos no Brasil, ou seja,  
foram criadas 28 900 vagas de emprego, segundo dados do Cadastro Geral de Empregados e Desempregados (Caged), divulgados pelo Ministério do Trabalho e Emprego (MTE). Segundo o Caged, o número de vagas criadas em janeiro de 2013 sofreu uma queda de 75%, quando comparado com o mesmo período de 2012.

Disponível em: http://portal.mte.gov.br. Acesso em: 23 fev. 2013 (adaptado).

De acordo com as informações dadas, o número de vagas criadas em janeiro de 2012 foi', 'C', 2.19381, 1.56693, 0.1302, NULL, 'revisão manual'),
  -- Questão 155 · MT · Matemática · Análise combinatória · H2
  (2022, 155, 2, NULL, 'MT', 'Matemática', 'Análise combinatória', 2, 47309, 'Um prédio, com 9 andares e 8 apartamentos de 2 quartos por andar, está com todos os seus apartamentos à venda. Os apartamentos são identificados por números formados por dois algarismos, sendo que a dezena indica o andar onde se encontra o apartamento, e a unidade, um algarismo de 1 a 8, que diferencia os apartamentos de um mesmo andar. Quanto à incidência de sol nos quartos desses apartamentos, constatam-se as seguintes características, em função de seus números de identificação:  
• naqueles que finalizam em 1 ou 2, ambos os quartos recebem sol apenas na parte da manhã;  
• naqueles que finalizam em 3, 4, 5 ou 6, apenas um dos quartos recebe sol na parte da manhã;  
• naqueles que finalizam em 7 ou 8, ambos os quartos recebem sol apenas na parte da tarde.

Uma pessoa pretende comprar 2 desses apartamentos em um mesmo andar, mas quer que, em ambos, pelo menos um dos quartos receba sol na parte da manhã.

De quantas maneiras diferentes essa pessoa poderá escolher 2 desses apartamentos para compra nas condições desejadas?', 'B', 0.92146, 2.16924, 0.15718, NULL, 'revisão manual'),
  -- Questão 156 · MT · Matemática · Geometria plana · H7
  (2022, 156, 2, NULL, 'MT', 'Matemática', 'Geometria plana', 7, 63646, 'O professor de artes orientou seus estudantes a realizarem a seguinte sequência de atividades:  
• Dobrar uma folha de papel em formato quadrado duas vezes, em sequência, ao longo das linhas tracejadas, conforme ilustrado nas figuras 1 e 2, para obter o papel dobrado, conforme Figura 3.

![](/midia/enem/2022/q156/2b1f4d30-ed72-40af-824d-6d394c9d948d.webp)

• Em seguida, no papel dobrado da Figura 3, considerar o ponto _R_, sobre o segmento _OM_, sendo  o ponto médio do lado do quadrado original, de modo que ![](/midia/enem/2022/q156/2a89a0e4-1a8b-4b3f-a678-97fa60066bcc.webp), traçar um arco de circunferência de raio medindo ![](/midia/enem/2022/q156/1665e780-8437-449e-b389-8d9729b2980c.webp) com centro no ponto _R_, obtendo a Figura 4. Por último, recortar o papel ao longo do arco de circunferência e excluir a parte que contém o setor circular, obtendo o papel dobrado, conforme Figura 5.

![](/midia/enem/2022/q156/bf9a172b-bd1e-4e83-9d95-6bc3fd29eadc.webp)

Após desdobrado o papel que restou na Figura 5, a figura plana que os estudantes obterão será', 'C', 0.79395, 2.40685, 0.1129, NULL, 'habilidade'),
  -- Questão 157 · MT · Matemática · Funções · H19
  (2022, 157, 2, NULL, 'MT', 'Matemática', 'Funções', 19, 39443, 'O funcionário de uma loja tem seu salário mensal formado por uma parcela fixa de 675 reais mais uma comissão que depende da quantidade de peças vendidas por ele no mês. O cálculo do valor dessa comissão é feito de acordo com estes critérios:  
• até a quinquagésima peça vendida, paga-se 5 reais por peça;  
• a partir da quinquagésima primeira peça vendida, o valor pago é de 7 reais por peça.  
Represente por q a quantidade de peças vendidas no mês por esse funcionário, e por S(q) o seu salário mensal, em real, nesse mês.

A expressão algébrica que descreve S(q) em função de q é', NULL, NULL, NULL, NULL, 'Item anulado pedagogicamente pelo INEP', 'habilidade'),
  -- Questão 158 · MT · Matemática · Funções · H23
  (2022, 158, 2, NULL, 'MT', 'Matemática', 'Funções', 23, 53461, 'Ao analisar os dados de uma epidemia em uma cidade, peritos obtiveram um modelo que avalia a quantidade de pessoas infectadas a cada mês, ao longo de um ano. O modelo é dado por ![](/midia/enem/2022/q158/94d1c253-bab8-44b6-aa7a-7bd9552dc398.webp), sendo t um número natural, variando de 1 a 12, que representa os meses do ano, e p(t) a quantidade de pessoas infectadas no mês t do ano. Para tentar diminuir o número de infectados no próximo ano, a Secretaria Municipal de Saúde decidiu intensificar a propaganda oficial sobre os cuidados com a epidemia. Foram apresentadas cinco propostas (I, II, III, IV e V), com diferentes períodos de intensificação das propagandas:

![](/midia/enem/2022/q158/e0b502d3-500e-42da-8e2b-431e83be58ff.webp)

A sugestäo dos peritos é que seja escolhida a proposta cujo período de intensificação da propaganda englobe o mês em que, sequndo o modelo, há a maior quantidade de infectados. A sugestão foi aceita.

A proposta escolhida foi a', 'C', 2.67778, 2.3731, 0.20523, NULL, 'habilidade'),
  -- Questão 159 · MT · Matemática · Sequências e progressões · H2
  (2022, 159, 2, NULL, 'MT', 'Matemática', 'Sequências e progressões', 2, 85013, 'Um atleta iniciou seu treinamento visando as competições de fim de ano. Seu treinamento consiste em cinco tipos diferentes de treinos: treino ![](/midia/enem/2022/q159/1de0b45e-d38b-4536-8661-c1c388ecd03d.webp),  treino ![](/midia/enem/2022/q159/0ab1a35f-7889-478e-a862-0edb86d335e6.webp), treino  ![](/midia/enem/2022/q159/8b00bc00-9af3-465a-89f2-3345b604b54b.webp), treino ![](/midia/enem/2022/q159/14be4d1d-8e19-41a5-bb02-cec32e90d007.webp) e treino ![](/midia/enem/2022/q159/136e1c72-59e2-41e7-95d7-b55e4ae92da3.webp). A sequência dos treinamentos deve seguir esta ordem:

![](/midia/enem/2022/q159/1c8945f7-b377-4bf6-9eb8-2a44c3c69e2a.webp)

A letra R significa repouso. Após completar a sequência de treinamentos, o atleta começa novamente a sequência a partir do treino ![](/midia/enem/2022/q159/660fa349-2c52-41aa-adae-bcd4adaad92e.webp), e segue a ordem descrita. Após 24 semanas completas de treinamento, se dará o inicio das competições.

Please select text to grab.

Copyfish

estöes20112Fonteestões2011

OCR successful

##### OCR Result(Auto-Detect)

N/A

Redo OCR Recapture Re-Translate Copy to clipboard

A sequência de treinamentos que o atleta realizará na 24ª semana de treinos é', 'B', 2.17147, 2.5423, 0.1841, NULL, 'palavras-chave'),
  -- Questão 160 · MT · Matemática · Geometria espacial · H6
  (2022, 160, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 6, 8364, 'Um robô, que tem um ímã em sua base, se desloca sobre a superfície externa de um cubo metálico, ao longo de segmentos de reta cujas extremidades são pontos médios de arestas e centros de faces. Ele inicia seu deslocamento no ponto **P**, centro da face superior do cubo, segue para o centro da próxima face, converte à esquerda e segue para o centro da face seguinte, converte à direita e continua sua movimentação, sempre alternando entre conversões à esquerda e à direita quando alcança o centro de uma face. O robô só termina sua movimentação quando retorna ao ponto **P**. A figura apresenta os deslocamentos iniciais desse robô.

![](/midia/enem/2022/q160/c9e8168c-5f91-45a5-82a3-c5a2948bf0a9.webp)

A projeção ortogonal do trajeto descrito por esse robô sobre o plano da base, após terminada sua movimentação, visualizada da posição em que se está enxergando esse cubo, é', 'A', 0.89111, 2.43206, 0.25086, NULL, 'palavras-chave'),
  -- Questão 161 · MT · Matemática · Grandezas, medidas e escalas · H11
  (2022, 161, 2, NULL, 'MT', 'Matemática', 'Grandezas, medidas e escalas', 11, 28683, 'Uma empresa de engenharia projetou uma casa com a forma de um retângulo para um de seus clientes. Esse cliente solicitou a inclusão de uma varanda em forma de L. A figura apresenta a planta baixa desenhada pela empresa, já com a varanda incluída, cujas medidas, indicadas em centímetro, representam os valores das dimensões da varanda na escala de 1 : 50.

![](/midia/enem/2022/q161/e1e86e81-76dc-4763-a118-273941076831.webp)

A medida real da área da varanda, em metro quadrado, é', 'A', 3.13149, 2.33341, 0.21903, NULL, 'habilidade'),
  -- Questão 162 · MT · Matemática · Leitura de gráficos e tabelas · H24
  (2022, 162, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 24, 111516, 'Uma loja de roupas fixou uma meta de vendas de 77 000 reais para um determinado mês de 30 dias. O gráfico mostra o volume de vendas dessa loja, em real, nos dez primeiros dias do mês e entre o dia dez e o dia vinte desse mês, nos seus dois únicos setores (infantil e adulto). Suponha que a variação no volume de vendas, para o período registrado, tenha se dado de forma linear, como mostrado no gráfico, e que essa tendência se mantenha a mesma para os próximos dez dias.

![](/midia/enem/2022/q162/0942383a-b8ee-4c44-a9ad-ae50d4204c0c.webp)

Ao final do trigésimo dia, quanto faltará no volume de vendas, em real, para que a meta fixada para o mês seja alcançada?', 'C', 1.82335, 1.38103, 0.13879, NULL, 'habilidade'),
  -- Questão 163 · MT · Matemática · Estatística · H30
  (2022, 163, 2, NULL, 'MT', 'Matemática', 'Estatística', 30, 32369, 'Em uma universidade, atuam professores que estão enquadrados funcionalmente pela sua maior titulação: mestre ou doutor. Nela há, atualmente, 60 mestres e 40 doutores. Os salários mensais dos professores mestres e dos doutores são, respectivamente, R$ 8 000,00 e  
R$ 12 000,00.  
A diretoria da instituição pretende proporcionar um aumento salarial diferenciado para o ano seguinte, de tal forma que o salário médio mensal dos professores dessa instituição não ultrapasse R$ 12 240,00. A universidade já estabeleceu que o aumento salarial será de 25% para os mestres e precisa ainda definir o percentual de reajuste para os doutores.

Mantido o número atual de professores com suas atuais titulações, o aumento salarial, em porcentagem, a ser concedido aos doutores deverá ser de, no máximo,', 'D', 3.12341, 2.40384, 0.16659, NULL, 'habilidade'),
  -- Questão 164 · MT · Matemática · Grandezas, medidas e escalas · H12
  (2022, 164, 2, NULL, 'MT', 'Matemática', 'Grandezas, medidas e escalas', 12, 117877, 'Um borrifador de atuação automática libera, a cada acionamento, uma mesma quantidade de inseticida. O recipiente desse produto, quando cheio, contém 360 mL de inseticida, que duram 60 dias se o borrifador permanecer ligado ininterruptamente e for acionado a cada 48 minutos.

A quantidade de inseticida que é liberada a cada acionamento do borrifador, em mililitro, é', 'B', 2.65709, 1.6446, 0.20086, NULL, 'habilidade'),
  -- Questão 165 · MT · Matemática · Grandezas, medidas e escalas · H10
  (2022, 165, 2, NULL, 'MT', 'Matemática', 'Grandezas, medidas e escalas', 10, 82581, 'Definem-se o dia e o ano de um planeta de um sistema solar como sendo, respectivamente, o tempo que o planeta leva para dar 1 volta completa em torno de seu próprio eixo de rotação e o tempo para dar 1 volta completa em torno de seu Sol.  
Suponha que exista um planeta Z, em algum sistema solar, onde um dia corresponda a 73 dias terrestres e que 2 de seus anos correspondam a 1 ano terrestre. Considere que 1 ano terrestre tem 365 de seus dias.

No planeta Z, seu ano corresponderia a quantos de seus dias?', 'A', 1.90672, 2.301, 0.10655, NULL, 'habilidade'),
  -- Questão 166 · MT · Matemática · Funções · H20
  (2022, 166, 2, NULL, 'MT', 'Matemática', 'Funções', 20, 31516, 'Em uma competição de velocidade, diz-se que há uma ultrapassagem quando um veículo que está atrás de outro passa à sua frente, com ambos se deslocando no mesmo sentido. Considere uma competição automobilística entre cinco carros em uma pista com 100 m de comprimento, onde todos largam no mesmo instante e da mesma linha.  
O gráfico mostra a variação da distância percorrida por cada  
veículo, em função do tempo, durante toda a competição.

![](/midia/enem/2022/q166/efa5ccf4-a844-4c87-b110-7a675585a779.webp)

Qual o número de ultrapassagens, após o início da competição, efetuadas pelo veículo que chegou em
último lugar?', 'A', 1.50662, 1.77699, 0.15235, NULL, 'habilidade'),
  -- Questão 167 · MT · Matemática · Porcentagem e matemática financeira · H4
  (2022, 167, 2, NULL, 'MT', 'Matemática', 'Porcentagem e matemática financeira', 4, 68369, 'Em uma loja, o preço promocional de uma geladeira é de R$ 1 000,00 para pagamento somente em dinheiro. Seu preço normal, fora da promoção, é 10% maior. Para pagamento feito com o cartão de crédito da loja, é dado um desconto de 2% sobre o preço normal.  
Uma cliente decidiu comprar essa geladeira, optando pelo pagamento com o cartão de crédito da loja. Ela calculou que o valor a ser pago seria o preço promocional acrescido de 8%. Ao ser informada pela loja do valor a  
pagar, segundo sua opção, percebeu uma diferença entre seu cálculo e o valor que lhe foi apresentado

O valor apresentado pela loja, comparado ao valor calculado pela cliente, foi', 'A', 2.57245, 1.58603, 0.10176, NULL, 'palavras-chave'),
  -- Questão 168 · MT · Matemática · Geometria plana · H6
  (2022, 168, 2, NULL, 'MT', 'Matemática', 'Geometria plana', 6, 10322, 'Uma pessoa precisa se deslocar de automóvel do ponto P para o ponto Q, indicados na figura, na qual as linhas verticais e horizontais simbolizam ruas

![](/midia/enem/2022/q168/5c7c6e9a-c900-4910-a9d0-af84f8f5b8c4.webp)

Por causa do sentido de tráfego nessas ruas, o caminho poligonal destacado é a possibilidade mais curta de efetuar esse deslocamento. Para descrevê-lo, deve-se especificar qual o sentido a ser tomado em cada cruzamento de ruas, em relação à direção de deslocamento do automóvel, que se movimentará continuamente. Para isso, empregam-se as letras E, F e D para indicar  
“vire à esquerda”, “siga em frente” e “vire à direita”, respectivamente.

A sequência de letras que descreve o caminho poligonal destacado é', 'C', 1.53551, 0.94716, 0.1917, NULL, 'habilidade'),
  -- Questão 169 · MT · Matemática · Geometria espacial · H9
  (2022, 169, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 9, 63204, 'Uma loja comercializa cinco modelos de caixas-d’água (I, II, III, IV e V), todos em formato de cilindro reto de base circular. Os modelos II, III, IV e V têm as especificações de suas dimensões dadas em relação às dimensões do modelo I, cuja profundidade é P e área da base é Ab, como segue:

• modelo II: o dobro da profundidade e a metade da  
área da base do modelo I;  
• modelo III: o dobro da profundidade e a metade do  
raio da base do modelo I;  
• modelo IV: a metade da profundidade e o dobro da  
área da base do modelo I;  
• modelo V: a metade da profundidade e o dobro do  
raio da base do modelo I.

Uma pessoa pretende comprar nessa loja o modelo  
de caixa-d’água que ofereça a maior capacidade  
volumétrica

O modelo escolhido deve ser o', 'E', 3.78296, 1.88956, 0.14444, NULL, 'revisão manual'),
  -- Questão 170 · MT · Matemática · Leitura de gráficos e tabelas · H26
  (2022, 170, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 26, 68123, 'No período de 2005 a 2013, o valor de venda dos imóveis em uma cidade apresentou alta, o que resultou no aumento dos aluguéis. Os gráficos apresentam a evolução desses valores, para um mesmo imóvel, no  
mercado imobiliário dessa cidade.

![](/midia/enem/2022/q170/be397d74-899b-444a-b587-931e9c3505ca.webp)

A rentabilidade do aluguel de um imóvel é calculada pela razão entre o valor mensal de aluguel e o valor de mercado desse imóvel.

Com base nos dados fornecidos, em que ano a rentabilidade do aluguel foi maior?', 'B', 2.18973, 1.32978, 0.04601, NULL, 'habilidade'),
  -- Questão 171 · MT · Matemática · Estatística · H29
  (2022, 171, 2, NULL, 'MT', 'Matemática', 'Estatística', 29, 96315, 'Nos cinco jogos finais da última temporada, com uma média de 18 pontos por jogo, um jogador foi eleito o melhor do campeonato de basquete. Na atual temporada, cinco jogadores têm a chance de igualar ou melhorar essa média. No quadro estão registradas as pontuações desses cinco jogadores nos quatro primeiros jogos das finais deste ano.

![](/midia/enem/2022/q171/45b098d3-26d2-49c5-a129-40e85febb05b.webp)

O quinto e último jogo será realizado para decidir a equipe campeã e qual o melhor jogador da temporada.

O jogador que precisa fazer a menor quantidade de pontos no quinto jogo, para igualar a média de pontos do melhor jogador da temporada passada, é o', 'A', 1.69166, 0.87454, 0.20606, NULL, 'habilidade'),
  -- Questão 172 · MT · Matemática · Geometria espacial · H13
  (2022, 172, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 13, 117742, 'Um casal planeja construir em sua chácara uma piscina com o formato de um paralelepípedo reto retângulo com capacidade para 90 000 L de água. O casal contratou uma empresa de construções que apresentou cinco projetos com diferentes combinações nas dimensões internas de profundidade, largura e comprimento. A piscina a ser construída terá revestimento interno em suas paredes e fundo com uma mesma cerâmica, e o casal irá escolher o projeto que exija a menor área de revestimento.

As dimensões internas de profundidade, largura e comprimento, respectivamente, para cada um dos projetos, são:

• projeto I: 1,8 m, 2,0 m e 25,0 m;  
• projeto II: 2,0 m, 5,0 m e 9,0 m;  
• projeto III: 1,0 m, 6,0 m e 15,0 m;  
• projeto IV: 1,5 m, 15,0 m e 4,0 m;  
• projeto V: 2,5 m, 3,0 m e 12,0 m.

O projeto que o casal deverá escolher será o', 'B', 0.65574, 2.58862, 0.1651, NULL, 'revisão manual'),
  -- Questão 173 · MT · Matemática · Leitura de gráficos e tabelas · H25
  (2022, 173, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 25, 30327, 'Uma instituição de ensino superior ofereceu vagas em um processo seletivo de acesso a seus cursos. Finalizadas as inscrições, foi divulgada a relação do número de candidatos por vaga em cada um dos cursos oferecidos. Esses dados são apresentados no quadro.

![](/midia/enem/2022/q173/0e6a9a19-bb58-4f93-bcb9-b7f26f5df5e7.webp)

Qual foi o número total de candidatos inscritos nesse processo seletivo?', 'D', 2.81078, 0.63977, 0.16335, NULL, 'habilidade'),
  -- Questão 174 · MT · Matemática · Geometria espacial · H8
  (2022, 174, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 8, 14797, 'Peças metálicas de aeronaves abandonadas em aeroportos serão recicladas. Uma dessas peças é maciça e tem o formato cilíndrico, com a medida do raio da base igual a 4 cm e a da altura igual a 50 cm. Ela será derretida, e o volume de metal resultante será utilizado para a fabricação de esferas maciças com diâmetro de 1 cm, a serem usadas para confeccionar rolamentos. Para estimar a quantidade de esferas que poderão ser produzidas a partir de cada uma das peças cilíndricas, admite-se que não ocorre perda de material durante o processo de derretimento.

Quantas dessas esferas poderão ser obtidas a partir de cada peça cilíndrica?', 'D', 2.93886, 2.57768, 0.12028, NULL, 'palavras-chave'),
  -- Questão 175 · MT · Matemática · Aritmética e conjuntos numéricos · H1
  (2022, 175, 2, NULL, 'MT', 'Matemática', 'Aritmética e conjuntos numéricos', 1, 60441, 'Ao escutar a notícia de que um filme recém-lançado arrecadou, no primeiro mês de lançamento, R$ 1,35 bilhão em bilheteria, um estudante escreveu corretamente o número que representa essa quantia, com todos os seus  
algarismos.

O número escrito pelo estudante foi', 'E', 1.42701, -0.02398, 0.11013, NULL, 'habilidade'),
  -- Questão 176 · MT · Matemática · Geometria plana · H9
  (2022, 176, 2, NULL, 'MT', 'Matemática', 'Geometria plana', 9, 117886, '![](/midia/enem/2022/q176/eebeabf5-0dec-4070-abd5-f803bb370dd9.webp)

Pretende-se que a distância percorrida entre as duas cidades, pelas Rodovias 001 e 002, passando pelo ponto de conexão, seja a menor possível.
Dadas as exigências do projeto, qual das localizações sugeridas deve ser a escolhida para o ponto de conexão?', 'D', 0.4443, 6.27505, 0.1251, NULL, 'habilidade'),
  -- Questão 177 · MT · Matemática · Leitura de gráficos e tabelas · H26
  (2022, 177, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 26, 95676, 'Uma pessoa precisa contratar um operário para fazer um serviço em sua casa. Para isso, ela postou um anúncio em uma rede social.  
Cinco pessoas responderam informando preços por hora trabalhada, gasto diário com transporte e tempo necessário para conclusão do serviço, conforme valores apresentados no quadro.

![](/midia/enem/2022/q177/fb1d11e4-76d3-4657-b78f-84e7bcd81f6c.webp)

Se a pessoa pretende gastar o mínimo possível com essa contratação, irá contratar o operário', 'A', 1.32325, 0.64802, 0.18728, NULL, 'habilidade'),
  -- Questão 178 · MT · Matemática · Geometria espacial · H12
  (2022, 178, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 12, 19807, 'Uma cozinheira produz docinhos especiais por encomenda. Usando uma receita-base de massa, ela prepara uma porção, com a qual produz 50 docinhos maciços de formato esférico, com 2 cm de diâmetro. Um cliente encomenda 150 desses docinhos, mas pede que cada um tenha formato esférico com 4 cm de diâmetro.  
A cozinheira pretende preparar o número exato de porções da receita-base de massa necessário para produzir os docinhos dessa encomenda

Quantas porções da receita-base de massa ela deve preparar para atender esse cliente?', 'E', 4.1583, 2.56697, 0.06542, NULL, 'revisão manual'),
  -- Questão 179 · MT · Matemática · Leitura de gráficos e tabelas · H24
  (2022, 179, 2, NULL, 'MT', 'Matemática', 'Leitura de gráficos e tabelas', 24, 85588, 'A esperança de vida ao nascer é o número médio de anos que um indivíduo tende a viver a partir de seu nascimento, considerando dados da população. No Brasil, esse número vem aumentando consideravelmente, como mostra o gráfico.

![](/midia/enem/2022/q179/08b6ac03-1a1c-4a0d-b246-dc37098794ad.webp)

Disponível em: http://cod.ibge.gov.br. Acesso em: 6 mar. 2014 (adaptado).

Pode-se observar que a esperança de vida ao nascer em 2012 foi exatamente a média das registradas nos anos de 2011 e 2013. Suponha que esse fato também ocorreu com a esperança de vida ao nascer em 2013, em relação às esperanças de vida de 2012 e de 2014.

Caso a suposição feita tenha sido confirmada, a esperança de vida ao nascer no Brasil no ano de 2014 terá sido, em ano, igual a', 'B', 2.30031, 0.46698, 0.25799, NULL, 'habilidade'),
  -- Questão 180 · MT · Matemática · Geometria espacial · H6
  (2022, 180, 2, NULL, 'MT', 'Matemática', 'Geometria espacial', 6, 10409, 'Na figura estão destacadas duas trajetórias sobre a superfície do globo terrestre, descritas ao se percorrer parte dos meridianos 1, 2 e da Linha do Equador, sendo que os meridianos 1 e 2 estão contidos em planos perpendiculares entre si. O plano α é paralelo ao que contém a Linha do Equador.

![](/midia/enem/2022/q180/f3e0feaa-a265-4d9f-894f-63135acff616.webp)

A vista superior da projeção ortogonal sobre o plano α dessas duas trajetórias é', 'E', 1.66982, 2.03629, 0.24595, NULL, 'palavras-chave')
) AS v(ano, numero, dia, lingua, area, disciplina, conteudo, habilidade,
       codigo_item, enunciado, gabarito, tri_a, tri_b, tri_c, motivo, metodo)
JOIN area a ON a.sigla = v.area
JOIN disciplina d ON d.area_id = a.id AND d.nome = v.disciplina
JOIN conteudo c ON c.disciplina_id = d.id AND c.nome = v.conteudo
JOIN habilidade h ON h.area_id = a.id AND h.codigo = v.habilidade
ON CONFLICT DO NOTHING;

-- Alternativas (925)
INSERT INTO alternativa (questao_id, letra, texto)
SELECT q.id, v.letra, v.texto
FROM (VALUES
  (2022, 1, 'espanhol', 'A', 'Difundir a arte iconográfica indígena mexicana.'),
  (2022, 1, 'espanhol', 'B', 'Resgatar a literatura popular produzida em língua zapoteca.'),
  (2022, 1, 'espanhol', 'C', 'Questionar o conhecimento do povo mexicano sobre as línguas ameríndias'),
  (2022, 1, 'espanhol', 'D', 'Destacar o papel dos órgãos governamentais na conservação das línguas no México.'),
  (2022, 1, 'espanhol', 'E', 'Defender a preservação das línguas originárias garantindo a diversidade linguística mexicana.'),
  (2022, 1, 'ingles', 'A', 'qualidade da educação formal em Miami.'),
  (2022, 1, 'ingles', 'B', 'prestígio da cultura cubana nos Estados Unidos.'),
  (2022, 1, 'ingles', 'C', 'oportunidade de qualificação profissional em Miami.'),
  (2022, 1, 'ingles', 'D', 'cenário da integração de cubanos nos Estados Unidos.'),
  (2022, 1, 'ingles', 'E', 'fortalecimento do elo familiar em comunidades estadunidenses.'),
  (2022, 2, 'espanhol', 'A', 'Conhecimento das pessoas sobre as tecnologias.'),
  (2022, 2, 'espanhol', 'B', 'Uso do celular alheio por pessoas desautorizadas.'),
  (2022, 2, 'espanhol', 'C', 'Funcionamento de recursos tecnológicos obsoletos.'),
  (2022, 2, 'espanhol', 'D', 'Ingerência do celular sobre as escolhas dos usuários'),
  (2022, 2, 'espanhol', 'E', 'Falta de informação sobre a configuração de alertas no celular'),
  (2022, 2, 'ingles', 'A', 'problematizar o papel de gênero em casamentos modernos.'),
  (2022, 2, 'ingles', 'B', 'apontar a relevância da educação formal na escolha de parceiros.'),
  (2022, 2, 'ingles', 'C', 'comparar a expectativa de parceiros amorosos em épocas distintas.'),
  (2022, 2, 'ingles', 'D', 'discutir o uso de aplicativos para proporcionar encontros românticos.'),
  (2022, 2, 'ingles', 'E', 'valorizar a importância da aparência física na seleção de pretendentes.'),
  (2022, 3, 'espanhol', 'A', 'Das peculiaridades dos subúrbios hispano-americanos.'),
  (2022, 3, 'espanhol', 'B', 'Da força da conexão espiritual entre os amigos.'),
  (2022, 3, 'espanhol', 'C', 'Do papel da amizade em diferentes contextos.'),
  (2022, 3, 'espanhol', 'D', 'Do hábito de reunir amigos em torno da mesa'),
  (2022, 3, 'espanhol', 'E', 'Dos graus de intimidade entre os amigos'),
  (2022, 3, 'ingles', 'A', 'revolta com a falta de sorte.'),
  (2022, 3, 'ingles', 'B', 'gosto pela prática da leitura.'),
  (2022, 3, 'ingles', 'C', 'receio pelo futuro do casamento.'),
  (2022, 3, 'ingles', 'D', 'entusiasmo com os livros de terror.'),
  (2022, 3, 'ingles', 'E', 'rejeição ao novo tipo de residência.'),
  (2022, 4, 'espanhol', 'A', 'Descaso diante da problemática de crianças em situação de rua.'),
  (2022, 4, 'espanhol', 'B', 'Violência característica do cotidiano das grandes metrópoles.'),
  (2022, 4, 'espanhol', 'C', 'Estímulo à mendicância nos centros urbanos'),
  (2022, 4, 'espanhol', 'D', 'Tendência de informalização do trabalho'),
  (2022, 4, 'espanhol', 'E', 'Falta de serviços de saúde adequados'),
  (2022, 4, 'ingles', 'A', 'oferecer recursos de fotografia.'),
  (2022, 4, 'ingles', 'B', 'divulgar problemas dos usuários.'),
  (2022, 4, 'ingles', 'C', 'estimular aceitação dos seguidores.'),
  (2022, 4, 'ingles', 'D', 'provocar ansiedade nos adolescentes.'),
  (2022, 4, 'ingles', 'E', 'aproximar pessoas ao redor do mundo.'),
  (2022, 5, 'espanhol', 'A', 'Evidenciar a importância de uma rede de apoio para as mães na criação de seus filhos.'),
  (2022, 5, 'espanhol', 'B', 'Denunciar a disparidade entre o trabalho das mães de diferentes classes sociais.'),
  (2022, 5, 'espanhol', 'C', 'Ressaltar o fechamento de escolas e creches durante o período pandêmico'),
  (2022, 5, 'espanhol', 'D', 'Ratificar a romantização da dedicação das mães na educação das crianças.'),
  (2022, 5, 'espanhol', 'E', 'Enfatizar a proteção aos filhos em razão do isolamento social das famílias'),
  (2022, 5, 'ingles', 'A', 'contentamento com a interação virtual.'),
  (2022, 5, 'ingles', 'B', 'zelo com o envio de mensagens.'),
  (2022, 5, 'ingles', 'C', 'preocupação com a composição de textos.'),
  (2022, 5, 'ingles', 'D', 'mágoa com o comportamento de alguém.'),
  (2022, 5, 'ingles', 'E', 'insatisfação com uma forma de comunicação.'),
  (2022, 6, NULL, 'A', 'Impessoalização ao longo do texto, como em: “se não há mais tempo”.'),
  (2022, 6, NULL, 'B', 'Construção de uma atmosfera de urgência, em palavras como: “pressa”.'),
  (2022, 6, NULL, 'C', 'Repetição de uma determinada estrutura sintática, como em: “Se tudo é para ontem”.'),
  (2022, 6, NULL, 'D', 'Ênfase no emprego da hipérbole, como em: “uma refeição que pode durar uma vida”.'),
  (2022, 6, NULL, 'E', 'Emprego de metáforas, como em: “a vida engata uma primeira e sai em disparada”.'),
  (2022, 7, NULL, 'A', 'Problematiza a necessidade de adoção de animais sem lar.'),
  (2022, 7, NULL, 'B', 'Valida a troca afetiva entre os pets adotados e seus donos.'),
  (2022, 7, NULL, 'C', 'Reforça a importância da campanha de adoção de animais.'),
  (2022, 7, NULL, 'D', 'Exalta a natureza amigável de cães e de gatos.'),
  (2022, 7, NULL, 'E', 'Promove a campanha de adoção de animais.'),
  (2022, 8, NULL, 'A', 'Contribuir para a formação cidadã dos jogadores.'),
  (2022, 8, NULL, 'B', 'Refutar modelos estereotipados de beleza e elegância.'),
  (2022, 8, NULL, 'C', 'Estimular a competitividade entre potenciais compradores.'),
  (2022, 8, NULL, 'D', 'Exemplificar estratégias de arrecadação financeira pela internet.'),
  (2022, 8, NULL, 'E', 'Desenvolver conhecimentos lúdicos específicos dos tempos atuais.'),
  (2022, 9, NULL, 'A', 'Sentimento de culpa provocado no condutor causador de acidentes.'),
  (2022, 9, NULL, 'B', 'Dano psicológico causado nas vítimas da violência nas estradas.'),
  (2022, 9, NULL, 'C', 'Importância do monitoramento do trânsito pelas autoridades competentes.'),
  (2022, 9, NULL, 'D', 'Necessidade de punição a motoristas alcoolizados envolvidos em acidentes.'),
  (2022, 9, NULL, 'E', 'Sofrimento decorrente da perda de entes queridos em acidentes automobilísticos.'),
  (2022, 10, NULL, 'A', 'Sucesso dos artistas.'),
  (2022, 10, NULL, 'B', 'Valorização dos suportes.'),
  (2022, 10, NULL, 'C', 'Proteção da produção estética.'),
  (2022, 10, NULL, 'D', 'Modo de distribuição de obras.'),
  (2022, 10, NULL, 'E', 'Compartilhamento das obras artísticas.'),
  (2022, 11, NULL, 'A', 'Dificuldade na apropriação da nova linguagem.'),
  (2022, 11, NULL, 'B', 'Valorização da utilização da nova tecnologia.'),
  (2022, 11, NULL, 'C', 'Recorrência das mudanças tecnológicas.'),
  (2022, 11, NULL, 'D', 'Suplantação imediata dos conhecimentos prévios.'),
  (2022, 11, NULL, 'E', 'Rapidez no aprendizado do manuseio das novas invenções.'),
  (2022, 12, NULL, 'A', 'Falta de compreensão causada pelo choque entre gerações.'),
  (2022, 12, NULL, 'B', 'Contexto de comunicação em que a conversa se dá.'),
  (2022, 12, NULL, 'C', 'Grau de polidez distinto entre os interlocutores.'),
  (2022, 12, NULL, 'D', 'Diferença de escolaridade entre os falantes.'),
  (2022, 12, NULL, 'E', 'Nível social dos participantes da situação.'),
  (2022, 13, NULL, 'A', 'Apontam o desenvolvimento econômico como solução para ampliar o uso da rede.'),
  (2022, 13, NULL, 'B', 'Questionam a crença de que o acesso à informação é igualitário e democrático.'),
  (2022, 13, NULL, 'C', 'Afirmam que o uso comercial da rede é a causa da exclusão de minorias.'),
  (2022, 13, NULL, 'D', 'Refutam o vinculo entre níveis de escolaridade e dificuldade de acesso.'),
  (2022, 13, NULL, 'E', 'Condicionam a expansão da rede à elaboração de politicas inclusivas.'),
  (2022, 14, NULL, 'A', 'Expediente próprio do sistema linguístico que nos apresenta diferentes possibilidades para traduzir estados de coisas.'),
  (2022, 14, NULL, 'B', 'Ato inventivo de nomear novas realidades que surgem diante de uma comunidade de falantes de uma língua.'),
  (2022, 14, NULL, 'C', 'Mecanismo de apropriação de formas linguísticas que estão no acervo da formação do idioma nacional.'),
  (2022, 14, NULL, 'D', 'Processo de incorporação de preconceitos que são recorrentes na história de uma sociedade.'),
  (2022, 14, NULL, 'E', 'Recurso de expressão marcado pela objetividade que se requer na comunicação diária.'),
  (2022, 15, NULL, 'A', 'Promover o uso adequado de campanhas publicitárias do governo.'),
  (2022, 15, NULL, 'B', 'Divulgar o projeto sobre transparência da administração pública.'),
  (2022, 15, NULL, 'C', 'Responsabilizar o cidadão pelo controle dos gastos públicos.'),
  (2022, 15, NULL, 'D', 'Delegar a gestão de projetos de lei ao contribuinte.'),
  (2022, 15, NULL, 'E', 'Assegurar a fiscalização dos gastos públicos.'),
  (2022, 16, NULL, 'A', 'Narrar, por meio de imagem e poesia, cenas da vida das irmãs Petra e Elena.'),
  (2022, 16, NULL, 'B', 'Descrever, por meio das memórias de Petra, a separação de duas irmãs.'),
  (2022, 16, NULL, 'C', 'Sintetizar, por meio das principais cenas do filme, a história de Elena.'),
  (2022, 16, NULL, 'D', 'Lançar, por meio da história de vida do autor, um filme autobiográfico.'),
  (2022, 16, NULL, 'E', 'Avaliar, por meio de análise crítica, o filme em referência.'),
  (2022, 17, NULL, 'A', 'Tematiza o fazer poético, como em "Os poetas classificam as palavras pela alma".'),
  (2022, 17, NULL, 'B', 'Utiliza o recurso expressivo da metáfora, como em "As palavras têm corpo e alma".'),
  (2022, 17, NULL, 'C', 'Valoriza a gramática da língua, como em "substantivo, adjetivo, verbo, advérbio, conjunção".'),
  (2022, 17, NULL, 'D', 'Estabelece comparações, como em "As palavras têm corpo e alma, mas são diferentes das pessoas".'),
  (2022, 17, NULL, 'E', 'Apresenta informações pertinentes acerca do conceito de "palavra", como em "As gramáticas classificam as palavras".'),
  (2022, 18, NULL, 'A', 'Justaposição de sequências verbais e nominais.'),
  (2022, 18, NULL, 'B', 'Mudança de eventos resultante do jogo temporal.'),
  (2022, 18, NULL, 'C', 'Uso de adjetivos qualificativos na descrição do cenário.'),
  (2022, 18, NULL, 'D', 'Encadeamento semântico pelo uso de substantivos sinônimos.'),
  (2022, 18, NULL, 'E', 'Inter-relação entre orações por elementos linguisticos lógicos.'),
  (2022, 19, NULL, 'A', 'Problema social localizado numa região do país.'),
  (2022, 19, NULL, 'B', 'Desafio para as torcidas organizadas dos clubes.'),
  (2022, 19, NULL, 'C', 'Reflexo da precariedade da organização social no país.'),
  (2022, 19, NULL, 'D', 'Inadequação de espaço nos estádios para receber o público.'),
  (2022, 19, NULL, 'E', 'Consequência da insatisfação dos clubes com a organização dos jogos.'),
  (2022, 20, NULL, 'A', 'Promovam a melhoria da aptidão física da população, dedicando-se mais tempo aos esportes.'),
  (2022, 20, NULL, 'B', 'Combatam o sedentarismo presente em parcela significativa da população no território nacional.'),
  (2022, 20, NULL, 'C', 'Facilitem a adoção da prática de exercícios, com ações relacionadas à educação e à distribuição de renda.'),
  (2022, 20, NULL, 'D', 'Auxiliem na construção de mais instalações esportivas e espaços adequados para a prática de atividades físicas e esportes.'),
  (2022, 20, NULL, 'E', 'Estimulem o incentivo fiscal para a iniciativa privada destinar verbas aos programas nacionais de promoção da saúde pelo esporte.'),
  (2022, 21, NULL, 'A', 'Revelar a imposição de crenças religiosas a pessoas escravizadas.'),
  (2022, 21, NULL, 'B', 'Apontar a hipocrisia do discurso conservador na defesa da escravidão.'),
  (2022, 21, NULL, 'C', 'Sugerir práticas de violência física e moral em nome do progresso material.'),
  (2022, 21, NULL, 'D', 'Relacionar o declínio da produção agrícola e comercial a questões raciais.'),
  (2022, 21, NULL, 'E', 'Ironizar o comportamento dos proprietários de terra na exploração do trabalho.'),
  (2022, 22, NULL, 'A', 'Garantem a igualdade entre as pessoas.'),
  (2022, 22, NULL, 'B', 'Foram criados por uma pesquisadora surda.'),
  (2022, 22, NULL, 'C', 'Tiveram origem em um curso de pós-graduação.'),
  (2022, 22, NULL, 'D', 'Estão circunscritos ao espaço institucional da escola.'),
  (2022, 22, NULL, 'E', 'Têm como objetivo a disseminação do conhecimento.'),
  (2022, 23, NULL, 'A', 'Caracterização da personagem como mestiça.'),
  (2022, 23, NULL, 'B', 'Construção do enredo de conquistas da família.'),
  (2022, 23, NULL, 'C', 'Relação conflituosa das mulheres e seus maridos.'),
  (2022, 23, NULL, 'D', 'Nostalgia do desejo de viver como os antepassados.'),
  (2022, 23, NULL, 'E', 'Marca de antigos sofrimentos no fluxo de consciência.'),
  (2022, 24, NULL, 'A', 'Se ter um notável saber jurídico.'),
  (2022, 24, NULL, 'B', 'Valorização da inteligência do falante.'),
  (2022, 24, NULL, 'C', 'Falar difícil para demonstrar inteligência.'),
  (2022, 24, NULL, 'D', 'Coesão e da coerência em documentos jurídicos.'),
  (2022, 24, NULL, 'E', 'Adequação da linguagem à situação de comunicação.'),
  (2022, 25, NULL, 'A', 'Conciliação do jornalismo com a prática do skate.'),
  (2022, 25, NULL, 'B', 'Inserção das mulheres na modalidade skate street.'),
  (2022, 25, NULL, 'C', 'Desconstrução da noção do skate como modalidade masculina.'),
  (2022, 25, NULL, 'D', 'Vanguarda de ser a atleta mais jovem a subir no pódio olímpico'),
  (2022, 25, NULL, 'E', 'Conquista de medalha nos Jogos Olímpicos de Tóquio.'),
  (2022, 26, NULL, 'A', '“Zanza pra acolá”.'),
  (2022, 26, NULL, 'B', '“Fim de feira, periferia afora”.'),
  (2022, 26, NULL, 'C', '“A cidade não mora mais em mim”.'),
  (2022, 26, NULL, 'D', '"Onde só vento se semeava outrora”.'),
  (2022, 26, NULL, 'E', '“Ó Manuel, Miguilim”.'),
  (2022, 27, NULL, 'A', 'Identificação de distinções entre mulheres e homens.'),
  (2022, 27, NULL, 'B', 'Revisão de representações estereotipadas de gênero.'),
  (2022, 27, NULL, 'C', 'Adoção de medidas preventivas de combate ao sexismo.'),
  (2022, 27, NULL, 'D', 'Ratificação de comportamentos femininos e masculinos.'),
  (2022, 27, NULL, 'E', 'Retomada de opiniões a respeito da diversidade dos papéis sociais.'),
  (2022, 28, NULL, 'A', 'Denuncia o processo de perseguição histórica sofrida pelos povos indígenas.'),
  (2022, 28, NULL, 'B', 'Conjuga o ato de resistência étnica à preservação da memória cultural.'),
  (2022, 28, NULL, 'C', 'Associa a preservação linguística ao campo da pesquisa acadêmica.'),
  (2022, 28, NULL, 'D', 'Estimula o retorno de povos indígenas a suas terras de origem.'),
  (2022, 28, NULL, 'E', 'Aumenta o número de línguas indígenas faladas no Brasil.'),
  (2022, 29, NULL, 'A', 'Modo de vestir dos moradores do morro carioca.'),
  (2022, 29, NULL, 'B', 'Senso prático em relação às oportunidades de renda.'),
  (2022, 29, NULL, 'C', 'Mistério que cerca as clientes de práticas de vidência.'),
  (2022, 29, NULL, 'D', 'Misto de singeleza e astúcia dos gestos da personagem.'),
  (2022, 29, NULL, 'E', 'Interesse do narrador pelas figuras femininas ambíguas.'),
  (2022, 30, NULL, 'A', 'Capitalista, marcado pela distribuição funcional do trabalho.'),
  (2022, 30, NULL, 'B', 'Liberal, buscando a igualdade entre pessoas escravizadas e livres.'),
  (2022, 30, NULL, 'C', 'Científico, considerando o ser humano como um fenômeno biológico.'),
  (2022, 30, NULL, 'D', 'Religioso, fundamentado na fé e na aceitação dos dogmas do cristianismo'),
  (2022, 30, NULL, 'E', 'Afetivo, manifesto na determinação de acolher familiares e no respeito mútuo'),
  (2022, 31, NULL, 'A', 'Desenho cru da realidade dramática dos retirantes.'),
  (2022, 31, NULL, 'B', 'Indefinição dos espaços para efeito de generalização.'),
  (2022, 31, NULL, 'C', 'Análise psicológica da reação dos personagens à seca.'),
  (2022, 31, NULL, 'D', 'Engajamento político do narrador ante as desigualdades.'),
  (2022, 31, NULL, 'E', 'Contemplação lírica da paisagem transformada em alegoria.'),
  (2022, 32, NULL, 'A', 'Propor ações específicas para cada etapa da infância.'),
  (2022, 32, NULL, 'B', 'Estabelecer regras que devem ser seguidas à risca.'),
  (2022, 32, NULL, 'C', 'Explicar os efeitos do acesso precoce à internet.'),
  (2022, 32, NULL, 'D', 'Determinar a incorporação de rituais à educação dos filhos.'),
  (2022, 32, NULL, 'E', 'Educar com base em um conjunto de estratégias formativas.'),
  (2022, 33, NULL, 'A', 'Enumeração de objetos e fatos'),
  (2022, 33, NULL, 'B', 'Predominância de linguagem objetiva'),
  (2022, 33, NULL, 'C', 'Ocorrência de período longo no trecho'),
  (2022, 33, NULL, 'D', 'Combinação de verbos no presente e no pretérito'),
  (2022, 33, NULL, 'E', 'Presença de léxico do campo semântico de funerais'),
  (2022, 34, NULL, 'A', 'Competitividade entre seus praticantes.'),
  (2022, 34, NULL, 'B', 'Atividade com padrões técnicos definidos.'),
  (2022, 34, NULL, 'C', 'Modalidade com regras predeterminadas.'),
  (2022, 34, NULL, 'D', 'Criatividade para adaptações a novos espaços.'),
  (2022, 34, NULL, 'E', 'Necessidade de espaços definidos para a sua realização.'),
  (2022, 35, NULL, 'A', 'Relação distanciada entre os interlocutores.'),
  (2022, 35, NULL, 'B', 'Articulação de vários núcleos narrativos.'),
  (2022, 35, NULL, 'C', 'Brevidade no tratamento da temática'),
  (2022, 35, NULL, 'D', 'Descrição minuciosa dos personagens'),
  (2022, 35, NULL, 'E', 'Público leitor exclusivo.'),
  (2022, 36, NULL, 'A', 'Fiscalizar as ações de saúde e saneamento da cidade.'),
  (2022, 36, NULL, 'B', 'Defender os serviços gratuitos de atendimento à população.'),
  (2022, 36, NULL, 'C', 'Conscientizar a população sobre grave problema de saúde pública.'),
  (2022, 36, NULL, 'D', 'Propor campanhas para a ampliação de acesso aos serviços públicos.'),
  (2022, 36, NULL, 'E', 'Responsabilizar os agentes públicos pela demora na tomada de decisões.'),
  (2022, 37, NULL, 'A', 'Representações estereotipadas e superficiais de felicidade.'),
  (2022, 37, NULL, 'B', 'Ressignificações contemporâneas do conceito de alegria.'),
  (2022, 37, NULL, 'C', 'Estilos de vida inacessíveis para a sociedade brasileira.'),
  (2022, 37, NULL, 'D', 'Atitudes contraditórias de influenciadores digitais.'),
  (2022, 37, NULL, 'E', 'Padrões idealizados e nocivos de beleza física.'),
  (2022, 38, NULL, 'A', 'Representação da nudez masculina.'),
  (2022, 38, NULL, 'B', 'Distorção ao representar a figura humana.'),
  (2022, 38, NULL, 'C', 'Evocação de um fato da cultura clássica grega.'),
  (2022, 38, NULL, 'D', 'Presença do tema da morte como punição da família.'),
  (2022, 38, NULL, 'E', 'Utilização da perspectiva para integrar os diferentes planos.'),
  (2022, 39, NULL, 'A', 'Representação da simplicidade pelo artista.'),
  (2022, 39, NULL, 'B', 'Exploração da técnica da escultura cubista.'),
  (2022, 39, NULL, 'C', 'Valorização do cotidiano por meio da geometria.'),
  (2022, 39, NULL, 'D', 'Utilização da complexidade dos elementos formais.'),
  (2022, 39, NULL, 'E', 'Combinação de formas sintéticas no espaço utilizado.'),
  (2022, 40, NULL, 'A', 'Plasticidade da imagem do rebanho reunido.'),
  (2022, 40, NULL, 'B', 'Sugestão da firmeza do sertanejo ao arrear o cavalo.'),
  (2022, 40, NULL, 'C', 'Situação de pobreza encontrada nos sertões brasileiros.'),
  (2022, 40, NULL, 'D', 'Afetividade demonstrada ao noticiar a morte do cantador.'),
  (2022, 40, NULL, 'E', 'Preocupação do vaqueiro em demonstrar sua virilidade.'),
  (2022, 41, NULL, 'A', 'Consagração da alegria do povo.'),
  (2022, 41, NULL, 'B', 'Atração e asco perante atitudes libertinas.'),
  (2022, 41, NULL, 'C', 'Espanto com a quantidade de foliões nas ruas.'),
  (2022, 41, NULL, 'D', 'Intenção de confraternizar com desconhecidos.'),
  (2022, 41, NULL, 'E', 'Reconhecimento da festa como manifestação cultural.'),
  (2022, 42, NULL, 'A', 'Lição de vida comunicada pelo tenente.'),
  (2022, 42, NULL, 'B', 'Predisposição materna para se emocionar.'),
  (2022, 42, NULL, 'C', 'Atividade política marcante da comunidade.'),
  (2022, 42, NULL, 'D', 'Resposta irônica ante o discurso da autoridade.'),
  (2022, 42, NULL, 'E', 'Necessidade de revelar seus anseios mais íntimos.'),
  (2022, 43, NULL, 'A', 'Citação a referências literárias tradicionais.'),
  (2022, 43, NULL, 'B', 'Alusão à inocência das crianças da época.'),
  (2022, 43, NULL, 'C', 'Estratégia de questionar a bondade humana.'),
  (2022, 43, NULL, 'D', 'Descrição detalhada das pessoas do interior.'),
  (2022, 43, NULL, 'E', 'Representação anedótica de atos de violência.'),
  (2022, 44, NULL, 'A', 'As formas de criticar obras do passado se repetem.'),
  (2022, 44, NULL, 'B', 'A recorrência de temas marca a arte do final do século XX.'),
  (2022, 44, NULL, 'C', 'As criações desmistificam os valores estéticos estabelecidos.'),
  (2022, 44, NULL, 'D', 'O distanciamento temporal permite a transformação dos referenciais estéticos.'),
  (2022, 44, NULL, 'E', 'O objeto ausente sugere a degradação da forma superando o modelo artístico.'),
  (2022, 45, NULL, 'A', 'Utilização de aparelhos musicais eletrônicos em lugar dos instrumentos tradicionais.'),
  (2022, 45, NULL, 'B', 'Ocupação de espaços da natureza local para a produção de eventos musicais memoráveis.'),
  (2022, 45, NULL, 'C', 'Substituição de antigas práticas musicais, como o frevo, por melodias e harmonias inovadoras.'),
  (2022, 45, NULL, 'D', 'Recuperação de composições tradicionais folclóricas e sua apresentação em grandes festivais.'),
  (2022, 45, NULL, 'E', 'Integração de referenciais culturais de diferentes origens, criando uma nova combinação estética.'),
  (2022, 46, NULL, 'A', 'Afeito à devoção ao aceitar destinos sacralizados.'),
  (2022, 46, NULL, 'B', 'Acostumado à pobreza ao admitir acasos naturais.'),
  (2022, 46, NULL, 'C', 'Habituado ao solo ao conhecer terrenos cultiváveis.'),
  (2022, 46, NULL, 'D', 'Íntimo à Caatinga ao interpretar condições ambientais.'),
  (2022, 46, NULL, 'E', 'Próximo à vegetação ao identificar espécies arbustivas.'),
  (2022, 47, NULL, 'A', 'Entendimento da cultura.'),
  (2022, 47, NULL, 'B', 'Aumento da criatividade.'),
  (2022, 47, NULL, 'C', 'Percepção da individualidade.'),
  (2022, 47, NULL, 'D', 'Melhoria da técnica.'),
  (2022, 47, NULL, 'E', 'Construção da sociabilidade.'),
  (2022, 48, NULL, 'A', 'Racismo estrutural.'),
  (2022, 48, NULL, 'B', 'Desemprego latente.'),
  (2022, 48, NULL, 'C', 'Concentração de renda.'),
  (2022, 48, NULL, 'D', 'Exclusão informacional.'),
  (2022, 48, NULL, 'E', 'Precariedade da educação.'),
  (2022, 49, NULL, 'A', 'Nível altimétrico.'),
  (2022, 49, NULL, 'B', 'Ciclo hidrológico.'),
  (2022, 49, NULL, 'C', 'Padrão climático.'),
  (2022, 49, NULL, 'D', 'Tectônica de placas.'),
  (2022, 49, NULL, 'E', 'Estrutura das rochas.'),
  (2022, 50, NULL, 'A', 'Discrepância entre engenharia ambiental e equilíbrio da fauna'),
  (2022, 50, NULL, 'B', 'Incoerência entre maquinaria estrangeira e controle da floresta'),
  (2022, 50, NULL, 'C', 'Incompatibilidade entre investimento estatal e proteção aos nativos'),
  (2022, 50, NULL, 'D', 'Competição entre farmacologia internacional e produtos da fitoterapia.'),
  (2022, 50, NULL, 'E', 'Contradição entre desenvolvimento nacional e respeito aos trabalhadores'),
  (2022, 51, NULL, 'A', 'Fabricação em série.'),
  (2022, 51, NULL, 'B', 'Ampliação de estoques.'),
  (2022, 51, NULL, 'C', 'Fragilização dos cartéis.'),
  (2022, 51, NULL, 'D', 'Padronização de mercadorias.'),
  (2022, 51, NULL, 'E', 'Desterritorialização da produção.'),
  (2022, 52, NULL, 'A', 'Fornecer a mão de obra qualificada.'),
  (2022, 52, NULL, 'B', 'Incorporar a inovação tecnológica.'),
  (2022, 52, NULL, 'C', 'Preservar a diversidade biológica.'),
  (2022, 52, NULL, 'D', 'Promover a produção alimentar.'),
  (2022, 52, NULL, 'E', 'Garantir a moradia básica.'),
  (2022, 53, NULL, 'A', 'Surgimento de novas práticas culturais.'),
  (2022, 53, NULL, 'B', 'Contestação de antigos hábitos masculinos.'),
  (2022, 53, NULL, 'C', 'Valorização de recentes publicações juvenis.'),
  (2022, 53, NULL, 'D', 'Circulação de variados manuais pedagógicos.'),
  (2022, 53, NULL, 'E', 'Aparecimento de diversas editoras comerciais.'),
  (2022, 54, NULL, 'A', 'Manutenção das regras patronais.'),
  (2022, 54, NULL, 'B', 'Desprendimento das ideias liberais.'),
  (2022, 54, NULL, 'C', 'Fortalecimento dos contratos laborais.'),
  (2022, 54, NULL, 'D', 'Consolidação das estruturas sindicais.'),
  (2022, 54, NULL, 'E', 'Contestação dos princípios monárquicos.'),
  (2022, 55, NULL, 'A', 'Realizar florestamentos de pinus, desrespeitando a prática do pousio.'),
  (2022, 55, NULL, 'B', 'Utilizar sistemas de irrigação, desprezando uma drenagem adequada.'),
  (2022, 55, NULL, 'C', 'Instalar açudes nos grotões, retardando a velocidade da vazão fluvial.'),
  (2022, 55, NULL, 'D', 'Desmatar áreas de preservação permanente, causando assoreamento.'),
  (2022, 55, NULL, 'E', 'Aplicar fertilizantes de origem orgânica, modificando a química da terra.'),
  (2022, 56, NULL, 'A', 'Exclusão social.'),
  (2022, 56, NULL, 'B', 'Expansão digital.'),
  (2022, 56, NULL, 'C', 'Manifestação cultural.'),
  (2022, 56, NULL, 'D', 'Organização espacial.'),
  (2022, 56, NULL, 'E', 'Valorização intelectual.'),
  (2022, 57, NULL, 'A', 'Formação de sociedade disciplinar.'),
  (2022, 57, NULL, 'B', 'Flexibilização do regramento social.'),
  (2022, 57, NULL, 'C', 'Banimento da autoridade repressora.'),
  (2022, 57, NULL, 'D', 'Condenação da degradação humana.'),
  (2022, 57, NULL, 'E', 'Hierarquização da burocracia estatal.'),
  (2022, 58, NULL, 'A', 'Delimitação de paisagens urbanas e abandono de componentes espiritualistas.'),
  (2022, 58, NULL, 'B', 'Demarcação de patrimônios afetivos e apropriação de elementos judaizantes.'),
  (2022, 58, NULL, 'C', 'Expansão de fronteiras regionais e subjetivação do cristianismo medieval.'),
  (2022, 58, NULL, 'D', 'Circunscrição de bens simbólicos e admissão de cerimônias ecumênicas.'),
  (2022, 58, NULL, 'E', 'Criação de lugares místicos e experiências do catolicismo popular.'),
  (2022, 59, NULL, 'A', 'Inovação tecnológica.'),
  (2022, 59, NULL, 'B', 'Reestruturação fundiária.'),
  (2022, 59, NULL, 'C', 'Comercialização garantida.'),
  (2022, 59, NULL, 'D', 'Eliminação no custo do frete.'),
  (2022, 59, NULL, 'E', 'Negociação na bolsa de valores.'),
  (2022, 60, NULL, 'A', 'Recreativa, promovendo o lazer em redes integradas.'),
  (2022, 60, NULL, 'B', 'Social, estimulando a reciprocidade por meios digitais.'),
  (2022, 60, NULL, 'C', 'Laboral, convertendo o desenvolvedor em usuário final.'),
  (2022, 60, NULL, 'D', 'Comercial, direcionando a escolha por produtos industrializados.'),
  (2022, 60, NULL, 'E', 'Cognitiva, favorecendo a aprendizagem pelas ferramentas virtuais.'),
  (2022, 61, NULL, 'A', 'Proteção da economia nacional.'),
  (2022, 61, NULL, 'B', 'Valorização da cultura tradicional.'),
  (2022, 61, NULL, 'C', 'Diminuição da formação acadêmica.'),
  (2022, 61, NULL, 'D', 'Estagnação da manifestação artística.'),
  (2022, 61, NULL, 'E', 'Ampliação do desemprego estrutural.'),
  (2022, 62, NULL, 'A', 'Limitação da circulação financeira.'),
  (2022, 62, NULL, 'B', 'Padronização da política monetária.'),
  (2022, 62, NULL, 'C', 'Funcionamento da união aduaneira.'),
  (2022, 62, NULL, 'D', 'Dependência da exportação agrícola.'),
  (2022, 62, NULL, 'E', 'Equivalência da legislação trabalhista.'),
  (2022, 63, NULL, 'A', 'Da nobreza, proveniente da obrigação de proteção ao campesinato livre.'),
  (2022, 63, NULL, 'B', 'Da realeza, decorrente do conceito de governo subjacente à monarquia cristã.'),
  (2022, 63, NULL, 'C', 'Dos mosteiros, resultante do caráter fraternal afirmado nas regras monásticas.'),
  (2022, 63, NULL, 'D', 'Dos bispados, consequente da participação dos clérigos nos assuntos comunitários.'),
  (2022, 63, NULL, 'E', 'Das corporações, procedente do padrão assistencialista previsto nas normas estatutárias.'),
  (2022, 64, NULL, 'A', 'Solos vulcânicos.'),
  (2022, 64, NULL, 'B', 'Dorsais oceânicas.'),
  (2022, 64, NULL, 'C', 'Relevos escarpados.'),
  (2022, 64, NULL, 'D', 'Superfícies lateríticas.'),
  (2022, 64, NULL, 'E', 'Dobramentos modernos.'),
  (2022, 65, NULL, 'A', 'Cultura do cancelamento.'),
  (2022, 65, NULL, 'B', 'Prática do feminicídio.'),
  (2022, 65, NULL, 'C', 'Postura negacionista.'),
  (2022, 65, NULL, 'D', 'Ação involuntária.'),
  (2022, 65, NULL, 'E', 'Defesa da honra.'),
  (2022, 66, NULL, 'A', 'Liberdade de gênero e controle social.'),
  (2022, 66, NULL, 'B', 'Equidade de escolha e imposição cultural.'),
  (2022, 66, NULL, 'C', 'Dominação de corpos e igualdade humana.'),
  (2022, 66, NULL, 'D', 'Geração de oportunidade e restrição profissional.'),
  (2022, 66, NULL, 'E', 'Exclusão de competências e participação política.'),
  (2022, 67, NULL, 'A', 'Fragilizar o poder público.'),
  (2022, 67, NULL, 'B', 'Fomentar a economia solidária.'),
  (2022, 67, NULL, 'C', 'Controlar a propriedade estatal.'),
  (2022, 67, NULL, 'D', 'Garantir o preceito constitucional.'),
  (2022, 67, NULL, 'E', 'Incentivar a especulação imobiliária.'),
  (2022, 68, NULL, 'A', 'Compartilhamento de inovações tecnológicas.'),
  (2022, 68, NULL, 'B', 'Promoção de independência financeira.'),
  (2022, 68, NULL, 'C', 'Incremento de intercâmbios culturais.'),
  (2022, 68, NULL, 'D', 'Ampliação de influência econômica.'),
  (2022, 68, NULL, 'E', 'Preservação de recursos naturais.'),
  (2022, 69, NULL, 'A', 'As populações com idioma comum devem estar submetidas à mesma autoridade estatal.'),
  (2022, 69, NULL, 'B', 'O imperialismo soviético havia se acomodado às pretensões das potências vizinhas.'),
  (2022, 69, NULL, 'C', 'Os organismos transnacionais são incapazes de solucionar disputas territoriais.'),
  (2022, 69, NULL, 'D', 'A integração regional supõe a livre circulação de pessoas e mercadorias.'),
  (2022, 69, NULL, 'E', 'A expulsão das forças navais ocidentais garantiria a soberania nacional.'),
  (2022, 70, NULL, 'A', 'Raça e gênero.'),
  (2022, 70, NULL, 'B', 'Etnia e habitação.'),
  (2022, 70, NULL, 'C', 'Idade e nupcialidade.'),
  (2022, 70, NULL, 'D', 'Profissão e sexualidade.'),
  (2022, 70, NULL, 'E', 'Escolaridade e fecundidade.'),
  (2022, 71, NULL, 'A', 'Supressão de eleições de representantes políticos.'),
  (2022, 71, NULL, 'B', 'Intervenção em áreas de vulnerabilidade pela Igreja.'),
  (2022, 71, NULL, 'C', 'Disseminação de projetos sociais em universidades.'),
  (2022, 71, NULL, 'D', 'Ampliação dos processos de concentração de renda.'),
  (2022, 71, NULL, 'E', 'Regulamentação das relações de trabalho pelo Legislativo.'),
  (2022, 72, NULL, 'A', 'Fluxo de retorno.'),
  (2022, 72, NULL, 'B', 'Migração interna.'),
  (2022, 72, NULL, 'C', 'Mudança sazonal.'),
  (2022, 72, NULL, 'D', 'Movimento pendular.'),
  (2022, 72, NULL, 'E', 'Deslocamento forçado.'),
  (2022, 73, NULL, 'A', 'Valorizar um sentimento burguês.'),
  (2022, 73, NULL, 'B', 'Afirmar uma identidade coletiva.'),
  (2022, 73, NULL, 'C', 'Edificar uma memória nacional.'),
  (2022, 73, NULL, 'D', 'Criar uma comunidade cívica.'),
  (2022, 73, NULL, 'E', 'Definir uma tradição popular.'),
  (2022, 74, NULL, 'A', 'Declividade do relevo.'),
  (2022, 74, NULL, 'B', 'Extensão longitudinal.'),
  (2022, 74, NULL, 'C', 'Nebulosidade atmosférica.'),
  (2022, 74, NULL, 'D', 'Irregularidade pluviométrica.'),
  (2022, 74, NULL, 'E', 'Influência da continentalidade.'),
  (2022, 75, NULL, 'A', 'Objeto tombado e museográfico.'),
  (2022, 75, NULL, 'B', 'Herança religiosa e sacralizada.'),
  (2022, 75, NULL, 'C', 'Cenário bucólico e paisagístico'),
  (2022, 75, NULL, 'D', 'Riqueza individual e efêmera'),
  (2022, 75, NULL, 'E', 'Patrimônio cultural e afetivo.'),
  (2022, 76, NULL, 'A', 'Engenheiros na execução de canais fluviais.'),
  (2022, 76, NULL, 'B', 'Coronéis na ampliação de antigas fazendas.'),
  (2022, 76, NULL, 'C', 'Operários na distribuição dos recursos hídricos.'),
  (2022, 76, NULL, 'D', 'Trabalhadores na formação de novos espaços.'),
  (2022, 76, NULL, 'E', 'Negociantes na organização de redes comerciais.'),
  (2022, 77, NULL, 'A', 'Econômicos das elites.'),
  (2022, 77, NULL, 'B', 'Naturalistas dos viajantes.'),
  (2022, 77, NULL, 'C', 'Abolicionistas dos letrados.'),
  (2022, 77, NULL, 'D', 'Tradicionalistas dos nativos.'),
  (2022, 77, NULL, 'E', 'Emancipadores das metrópoles.'),
  (2022, 78, NULL, 'A', '1 : 12 500.'),
  (2022, 78, NULL, 'B', '1 : 125 000.'),
  (2022, 78, NULL, 'C', '1 : 1 250 000.'),
  (2022, 78, NULL, 'D', '1 : 12 500 000.'),
  (2022, 78, NULL, 'E', '1 : 125 000 000.'),
  (2022, 79, NULL, 'A', 'Habilidades artísticas e culturais dos sujeitos.'),
  (2022, 79, NULL, 'B', 'Vocações religiosas e pedagógicas dos mestres.'),
  (2022, 79, NULL, 'C', 'Naturezas antropológica e etnográfica dos expositores.'),
  (2022, 79, NULL, 'D', 'Preservações arquitetônica e visual dos conservatórios.'),
  (2022, 79, NULL, 'E', 'Competências econômica e financeira dos comerciantes.'),
  (2022, 80, NULL, 'A', 'Os epicuristas, envolvidos com o ideal de vida feliz.'),
  (2022, 80, NULL, 'B', 'Os estoicos, dedicados à superação dos infortúnios.'),
  (2022, 80, NULL, 'C', 'Os sofistas, comprometidos com o ensino da retórica.'),
  (2022, 80, NULL, 'D', 'Os peripatéticos, empenhados na dinâmica do ensino.'),
  (2022, 80, NULL, 'E', 'Os poetas rapsodos, responsáveis pela narrativa do mito.'),
  (2022, 81, NULL, 'A', 'Diversificação da opinião pública.'),
  (2022, 81, NULL, 'B', 'Mercantilização da cultura popular.'),
  (2022, 81, NULL, 'C', 'Controle das organizações sindicais.'),
  (2022, 81, NULL, 'D', 'Cerceamento da liberdade de expressão.'),
  (2022, 81, NULL, 'E', 'Privatização dos meios de comunicação'),
  (2022, 82, NULL, 'A', 'Abalos sísmicos periódicos.'),
  (2022, 82, NULL, 'B', 'Jazidas de minerais metálicos.'),
  (2022, 82, NULL, 'C', 'Reservas de combustíveis fósseis.'),
  (2022, 82, NULL, 'D', 'Aquíferos sedimentares profundos.'),
  (2022, 82, NULL, 'E', 'Estruturas geológicas metamórficas.'),
  (2022, 83, NULL, 'A', 'Exiladas.'),
  (2022, 83, NULL, 'B', 'Apátridas.'),
  (2022, 83, NULL, 'C', 'Foragidas.'),
  (2022, 83, NULL, 'D', 'Refugiadas.'),
  (2022, 83, NULL, 'E', 'Clandestinas.'),
  (2022, 84, NULL, 'A', 'Admitindo o belo como fenômeno transcendental.'),
  (2022, 84, NULL, 'B', 'Reafirmando a vivência estética como juízo de gosto.'),
  (2022, 84, NULL, 'C', 'Considerando o olhar como experiência de conhecimento.'),
  (2022, 84, NULL, 'D', 'Apontando as formas de expressão como auxiliares da razão.'),
  (2022, 84, NULL, 'E', 'Estabelecendo a inteligência como implicação das representações.'),
  (2022, 85, NULL, 'A', 'Abrandar cerimônias de punição.'),
  (2022, 85, NULL, 'B', 'Favorecer anseios de violência.'),
  (2022, 85, NULL, 'C', 'Criticar políticas de disciplina.'),
  (2022, 85, NULL, 'D', 'Produzir padrões de conduta.'),
  (2022, 85, NULL, 'E', 'Ordenar cultos de heresia.'),
  (2022, 86, NULL, 'A', 'Exalta a investigação filosófica.'),
  (2022, 86, NULL, 'B', 'Transcende ao mundo sensível.'),
  (2022, 86, NULL, 'C', 'Evoca a discussão cosmogônica.'),
  (2022, 86, NULL, 'D', 'Fundamenta as paixões humanas.'),
  (2022, 86, NULL, 'E', 'Corresponde à explicação mitológica.'),
  (2022, 87, NULL, 'A', 'Limitação da Área ocupada'),
  (2022, 87, NULL, 'B', 'Êxodo da população do campo'),
  (2022, 87, NULL, 'C', 'Ampliação do risco habitacional'),
  (2022, 87, NULL, 'D', 'Deficiência do transporte alternativo'),
  (2022, 87, NULL, 'E', 'Crescimento da taxa de fecundidade'),
  (2022, 88, NULL, 'A', 'Valorização de disputas dialógicas'),
  (2022, 88, NULL, 'B', 'Rejeição das convenções sociais'),
  (2022, 88, NULL, 'C', 'Inspiração de natureza religiosa'),
  (2022, 88, NULL, 'D', 'Exaltação do sofrimento'),
  (2022, 88, NULL, 'E', 'Moderação das paixões'),
  (2022, 89, NULL, 'A', 'Bens religiosos inspirados na matriz cristã.'),
  (2022, 89, NULL, 'B', 'Materiais bélicos pilhados em batalhas coloniais.'),
  (2022, 89, NULL, 'C', 'Heranças culturais constituídas em saberes próprios.'),
  (2022, 89, NULL, 'D', 'Costumes laborais moldados em estilos estrangeiros.'),
  (2022, 89, NULL, 'E', 'Práticas medicinais alicerçadas no conhecimento científico.'),
  (2022, 90, NULL, 'A', 'Manutenção dos modos de vida.'),
  (2022, 90, NULL, 'B', 'Conservação dos plantios da roça.'),
  (2022, 90, NULL, 'C', 'Atualização do modelo de gestão.'),
  (2022, 90, NULL, 'D', 'Participação na sociedade de consumo.'),
  (2022, 90, NULL, 'E', 'Especialização nas etapas de produção.'),
  (2022, 91, NULL, 'A', 'Oxirredução'),
  (2022, 91, NULL, 'B', 'Substituição'),
  (2022, 91, NULL, 'C', 'Precipitação'),
  (2022, 91, NULL, 'D', 'Desidratação'),
  (2022, 91, NULL, 'E', 'Neutralização'),
  (2022, 92, NULL, 'A', 'Incineração do lixo orgânico.'),
  (2022, 92, NULL, 'B', 'Construção de rede de esgoto.'),
  (2022, 92, NULL, 'C', 'Uso de vermífugo pela população.'),
  (2022, 92, NULL, 'D', 'Controle das populações dos vetores.'),
  (2022, 92, NULL, 'E', 'Consumo de carnes vermelhas bem cozidas.'),
  (2022, 93, NULL, 'A', '1 000 000 m²'),
  (2022, 93, NULL, 'B', '500 000 m²'),
  (2022, 93, NULL, 'C', '250 000 m²'),
  (2022, 93, NULL, 'D', '100 000 m²'),
  (2022, 93, NULL, 'E', '20 000 m²'),
  (2022, 94, NULL, 'A', 'Liberação de gás tóxico e reação oxidativa forte.'),
  (2022, 94, NULL, 'B', 'Reação oxidativa forte e liberação de gás tóxico.'),
  (2022, 94, NULL, 'C', 'Formação de sais tóxicos e reação oxidativa forte.'),
  (2022, 94, NULL, 'D', 'Liberação de gás tóxico e liberação de gás oxidante.'),
  (2022, 94, NULL, 'E', 'Formação de sais tóxicos e liberação de gás oxidante.'),
  (2022, 95, NULL, 'A', '![Alternativa A](/midia/enem/2022/q095/87d9018f-a151-480a-a9a8-e44a43463b22.webp)'),
  (2022, 95, NULL, 'B', '![Alternativa B](/midia/enem/2022/q095/362dd438-8835-4020-bd5a-b1e16a3ce584.webp)'),
  (2022, 95, NULL, 'C', '![Alternativa C](/midia/enem/2022/q095/2b418706-4910-471f-a904-dee54086d259.webp)'),
  (2022, 95, NULL, 'D', '![Alternativa D](/midia/enem/2022/q095/7560896d-771b-43b3-9347-d3a593ccd199.webp)'),
  (2022, 95, NULL, 'E', '![Alternativa E](/midia/enem/2022/q095/6e7b0269-ad16-4031-b9df-fecb1c4a2acb.webp)'),
  (2022, 96, NULL, 'A', '![Alternativa A](/midia/enem/2022/q096/430f5ad8-c181-4e82-8b90-364514a5e80d.webp)'),
  (2022, 96, NULL, 'B', '![Alternativa B](/midia/enem/2022/q096/9ccc03d3-49a3-45fa-bd85-aabe825984a6.webp)'),
  (2022, 96, NULL, 'C', '![Alternativa C](/midia/enem/2022/q096/32b31925-79f3-4809-bdb7-93b2e00c87d4.webp)'),
  (2022, 96, NULL, 'D', '![Alternativa D](/midia/enem/2022/q096/5ba7ae4b-c03e-457f-8a35-47bf0db1cef1.webp)'),
  (2022, 96, NULL, 'E', '![Alternativa E](/midia/enem/2022/q096/ff6f131d-afb1-4c4b-a8d4-f1f201170062.webp)'),
  (2022, 97, NULL, 'A', 'Peneiração.'),
  (2022, 97, NULL, 'B', 'Centrifugação.'),
  (2022, 97, NULL, 'C', 'Extração por solvente.'),
  (2022, 97, NULL, 'D', 'Destilação fracionada.'),
  (2022, 97, NULL, 'E', 'Separação magnética.'),
  (2022, 98, NULL, 'A', 'Correção do código genético para a tradução da proteína.'),
  (2022, 98, NULL, 'B', 'Alteração do RNA ribossômico ligado à síntese da proteína.'),
  (2022, 98, NULL, 'C', 'Produção de mutações benéficas para a correção do problema.'),
  (2022, 98, NULL, 'D', 'Liberação imediata da proteína normal na região ocular humana.'),
  (2022, 98, NULL, 'E', 'Expressão do gene responsável pela produção da enzima normal.'),
  (2022, 99, NULL, 'A', 'Ocupam áreas de vegetação nativa e substituem parcialmente a flora original.'),
  (2022, 99, NULL, 'B', 'Estimulam a competição por seus frutos entre animais típicos da região e eliminam as espécies perdedoras.'),
  (2022, 99, NULL, 'C', 'Alteram os nichos e aumentam o número de possibilidades de relações entre os seres vivos daquele ambiente.'),
  (2022, 99, NULL, 'D', 'Apresentam alta taxa de reprodução e se mantêm com um número de indivíduos superior à capacidade suporte do ambiente.'),
  (2022, 99, NULL, 'E', 'Diminuem a relação de competição entre os polinizadores e facilitam a ação de dispersores de sementes de espécies nativas.'),
  (2022, 100, NULL, 'A', '1,50 m.'),
  (2022, 100, NULL, 'B', '2,25 m.'),
  (2022, 100, NULL, 'C', '4,00 m.'),
  (2022, 100, NULL, 'D', '4,50 m.'),
  (2022, 100, NULL, 'E', '5,00 m.'),
  (2022, 101, NULL, 'A', 'RB72'),
  (2022, 101, NULL, 'B', 'RB84'),
  (2022, 101, NULL, 'C', 'RB92'),
  (2022, 101, NULL, 'D', 'SP79'),
  (2022, 101, NULL, 'E', 'SP80'),
  (2022, 102, NULL, 'A', 'Concentrar o RNA viral para otimizar a técnica.'),
  (2022, 102, NULL, 'B', 'Identificar nas amostras anticorpos anti-SARS-CoV-2.'),
  (2022, 102, NULL, 'C', 'Proliferar o vírus em culturas, aumentando a carga viral.'),
  (2022, 102, NULL, 'D', 'Purificar ácidos nucleicos virais, facilitando a ação da enzima.'),
  (2022, 102, NULL, 'E', 'Obter moléculas de cDNAviral por meio da transcrição reversa.'),
  (2022, 103, NULL, 'A', '![Alternativa A](/midia/enem/2022/q103/fd96af11-5014-46d5-a810-7f61cecce1ee.webp)'),
  (2022, 103, NULL, 'B', '![Alternativa B](/midia/enem/2022/q103/35328d99-51d3-48e1-b68f-77e985df73c4.webp)'),
  (2022, 103, NULL, 'C', '![Alternativa C](/midia/enem/2022/q103/09db4a77-899d-485e-b0a1-8cbfba70022a.webp)'),
  (2022, 103, NULL, 'D', '![Alternativa D](/midia/enem/2022/q103/87896c19-ad0d-4a19-a31e-c48d5e4e06fc.webp)'),
  (2022, 103, NULL, 'E', '![Alternativa E](/midia/enem/2022/q103/a530523b-e354-44f7-b52b-4424587daa4e.webp)'),
  (2022, 104, NULL, 'A', 'Frequência cardíaca.'),
  (2022, 104, NULL, 'B', 'Capacidade pulmonar.'),
  (2022, 104, NULL, 'C', 'Massa muscular do indivíduo.'),
  (2022, 104, NULL, 'D', 'Atividade anaeróbica da musculatura.'),
  (2022, 104, NULL, 'E', 'Taxa de transporte de oxigênio pelo sangue.'),
  (2022, 105, NULL, 'A', 'A força é maior na colisão com a barreira de pneus, e a energia dissipada é maior na colisão com a barreira de blocos.'),
  (2022, 105, NULL, 'B', 'A força é maior na colisão com a barreira de blocos, e a energia dissipada é maior na colisão com a barreira de pneus.'),
  (2022, 105, NULL, 'C', 'A força é maior na colisão com a barreira de blocos, e a energia dissipada é a mesma nas duas situações.'),
  (2022, 105, NULL, 'D', 'A força é maior na colisão com a barreira de pneus, e a energia dissipada é maior na colisão com a barreira de pneus.'),
  (2022, 105, NULL, 'E', 'A força é maior na colisão com a barreira de blocos, e a energia dissipada é maior na colisão com a barreira de blocos.'),
  (2022, 106, NULL, 'A', '![Alternativa A](/midia/enem/2022/q106/c80fb324-03eb-4796-a763-07123406dddc.webp)'),
  (2022, 106, NULL, 'B', '![Alternativa B](/midia/enem/2022/q106/c42c9c08-62b1-4fc3-b0f7-eb1a04bd69a0.webp)'),
  (2022, 106, NULL, 'C', '![Alternativa C](/midia/enem/2022/q106/57b30c7d-c1d7-496e-883a-1a838b3b5db8.webp)'),
  (2022, 106, NULL, 'D', '![Alternativa D](/midia/enem/2022/q106/b1e5f5bf-e8a9-4400-8029-e3aa6e3ef619.webp)'),
  (2022, 106, NULL, 'E', '![Alternativa E](/midia/enem/2022/q106/b5c54736-315b-449d-8903-3122dba1753c.webp)'),
  (2022, 107, NULL, 'A', 'Dissolver os reagentes.'),
  (2022, 107, NULL, 'B', 'Deslocar o equilíbrio químico.'),
  (2022, 107, NULL, 'C', 'Aumentar a velocidade da reação.'),
  (2022, 107, NULL, 'D', 'Mudar a constante de equilíbrio da reação.'),
  (2022, 107, NULL, 'E', 'Formar ligações de hidrogênio com o polissacarídeo.'),
  (2022, 108, NULL, 'A', '![Alternativa A](/midia/enem/2022/q108/52f3ad0e-41af-44d2-b45f-3abf1b73e2fe.webp)'),
  (2022, 108, NULL, 'B', '![Alternativa B](/midia/enem/2022/q108/d64d962d-0146-42a3-91d3-eb11e0697082.webp)'),
  (2022, 108, NULL, 'C', '![Alternativa C](/midia/enem/2022/q108/2515979b-9340-4b13-9ada-4b6c5c4c89ab.webp)'),
  (2022, 108, NULL, 'D', '![Alternativa D](/midia/enem/2022/q108/afe3dd22-3c6e-4668-ad0a-b7f8e9c321f9.webp)'),
  (2022, 108, NULL, 'E', '![Alternativa E](/midia/enem/2022/q108/ffa2205c-7c58-4f75-99bc-b90835a6fb9e.webp)'),
  (2022, 109, NULL, 'A', '2,4 µg.'),
  (2022, 109, NULL, 'B', '1,5 µg.'),
  (2022, 109, NULL, 'C', '0,8 µg.'),
  (2022, 109, NULL, 'D', '0,4 µg.'),
  (2022, 109, NULL, 'E', '0,2 µg.'),
  (2022, 110, NULL, 'A', 'As fêmeas influenciam o comportamento dos machos.'),
  (2022, 110, NULL, 'B', 'O cuidado parental é necessário para o desenvolvimento'),
  (2022, 110, NULL, 'C', 'O grau de evolução determina o comportamento reprodutivo.'),
  (2022, 110, NULL, 'D', 'O sucesso reprodutivo pode ser garantido por estratégias diferentes.'),
  (2022, 110, NULL, 'E', 'O ambiente induz modificação na produção do número de gametas femininos.'),
  (2022, 111, NULL, 'A', 'Trópico de Capricórnio.'),
  (2022, 111, NULL, 'B', 'Trópico de Câncer.'),
  (2022, 111, NULL, 'C', 'Polo Norte.'),
  (2022, 111, NULL, 'D', 'Polo Sul.'),
  (2022, 111, NULL, 'E', 'Equador'),
  (2022, 112, NULL, 'A', '120 N'),
  (2022, 112, NULL, 'B', '300 N'),
  (2022, 112, NULL, 'C', '360 N'),
  (2022, 112, NULL, 'D', '450 N'),
  (2022, 112, NULL, 'E', '900 N'),
  (2022, 113, NULL, 'A', 'Proteção catódica, que utiliza um metal fortemente redutor.'),
  (2022, 113, NULL, 'B', 'Uso de metais de sacrifício, que se oxidam no lugar do ferro.'),
  (2022, 113, NULL, 'C', 'Passivação do ferro, que fica revestido pelo seu próprio óxido.'),
  (2022, 113, NULL, 'D', 'Efeito de barreira, que impede o contato com o agente oxidante.'),
  (2022, 113, NULL, 'E', 'Galvanização, que usa outros metais de menor potencial de redução.'),
  (2022, 114, NULL, 'A', 'Acúmulo do solvente com fragmentação da organela.'),
  (2022, 114, NULL, 'B', 'Rompimento da membrana celular com liberação do citosol.'),
  (2022, 114, NULL, 'C', 'Aumento do vacúolo com diluição do pigmento no seu interior.'),
  (2022, 114, NULL, 'D', 'Quebra da parede celular com extravasamento do pigmento.'),
  (2022, 114, NULL, 'E', 'Murchamento da célula com expulsão do pigmento do vacúolo.'),
  (2022, 115, NULL, 'A', '1,0.'),
  (2022, 115, NULL, 'B', '2,1.'),
  (2022, 115, NULL, 'C', '2,5.'),
  (2022, 115, NULL, 'D', '5,3.'),
  (2022, 115, NULL, 'E', '13,1.'),
  (2022, 116, NULL, 'A', '60 A'),
  (2022, 116, NULL, 'B', '30 A'),
  (2022, 116, NULL, 'C', '20 A'),
  (2022, 116, NULL, 'D', '10 A'),
  (2022, 116, NULL, 'E', '5 A'),
  (2022, 117, NULL, 'A', 'H2'),
  (2022, 117, NULL, 'B', 'O2'),
  (2022, 117, NULL, 'C', 'CO2'),
  (2022, 117, NULL, 'D', 'CO'),
  (2022, 117, NULL, 'E', 'Cl2'),
  (2022, 118, NULL, 'A', 'Estrogênio'),
  (2022, 118, NULL, 'B', 'Feromônio'),
  (2022, 118, NULL, 'C', 'Testosterona.'),
  (2022, 118, NULL, 'D', 'Somatotrofina'),
  (2022, 118, NULL, 'E', 'Hormônio folículo estimulante.'),
  (2022, 119, NULL, 'A', '0,25 A'),
  (2022, 119, NULL, 'B', '0,33 A'),
  (2022, 119, NULL, 'C', '0,75 A'),
  (2022, 119, NULL, 'D', '1,00 A'),
  (2022, 119, NULL, 'E', '1,33 A'),
  (2022, 120, NULL, 'A', 'Variação do pH do meio.'),
  (2022, 120, NULL, 'B', 'Aumento da energia de ativação.'),
  (2022, 120, NULL, 'C', 'Consumo da enzima durante o ensaio.'),
  (2022, 120, NULL, 'D', 'Diminuição da concentração do substrato.'),
  (2022, 120, NULL, 'E', 'Modificação da estrutura tridimensional da enzima.'),
  (2022, 121, NULL, 'A', '1'),
  (2022, 121, NULL, 'B', '2'),
  (2022, 121, NULL, 'C', '3'),
  (2022, 121, NULL, 'D', '4'),
  (2022, 121, NULL, 'E', '5'),
  (2022, 122, NULL, 'A', 'Impedir a formação de trombos, típicos em alguns casos de acidente vascular cerebral.'),
  (2022, 122, NULL, 'B', 'Tratar consequências da anemia profunda, em razão da perda de grande volume de sangue.'),
  (2022, 122, NULL, 'C', 'Evitar a manifestação de urticárias, comumente relacionadas a processos alérgicos.'),
  (2022, 122, NULL, 'D', 'Reduzir o inchaço dos linfonodos, parte da resposta imunitária de diferentes infecções.'),
  (2022, 122, NULL, 'E', 'Regular a oscilação da pressão arterial, característica dos quadros de hipertensão.'),
  (2022, 123, NULL, 'A', 'Eles se moveriam em órbitas espirais, aproximando-se sucessivamente do Buraco Negro.'),
  (2022, 123, NULL, 'B', 'Eles oscilariam aleatoriamente em torno de suas órbitas elípticas originais.'),
  (2022, 123, NULL, 'C', 'Eles se moveriam em direção ao centro do Buraco Negro.'),
  (2022, 123, NULL, 'D', 'Eles passariam a precessionar mais rapidamente.'),
  (2022, 123, NULL, 'E', 'Eles manteriam suas órbitas inalteradas.'),
  (2022, 124, NULL, 'A', 'Catalisador.'),
  (2022, 124, NULL, 'B', 'Oxidante.'),
  (2022, 124, NULL, 'C', 'Redutor.'),
  (2022, 124, NULL, 'D', 'Ácido.'),
  (2022, 124, NULL, 'E', 'Base.'),
  (2022, 125, NULL, 'A', 'Pleiotropia.'),
  (2022, 125, NULL, 'B', 'Mutação gênica.'),
  (2022, 125, NULL, 'C', 'Interação gênica.'),
  (2022, 125, NULL, 'D', 'Penetrância incompleta.'),
  (2022, 125, NULL, 'E', 'Expressividade variável.'),
  (2022, 126, NULL, 'A', 'Coagulação.'),
  (2022, 126, NULL, 'B', 'Decantação.'),
  (2022, 126, NULL, 'C', 'Filtração.'),
  (2022, 126, NULL, 'D', 'Desinfecção.'),
  (2022, 126, NULL, 'E', 'Fluoretação.'),
  (2022, 127, NULL, 'A', 'Glicólise.'),
  (2022, 127, NULL, 'B', 'Fermentação lática.'),
  (2022, 127, NULL, 'C', 'Ciclo do ácido cítrico.'),
  (2022, 127, NULL, 'D', 'Oxidação do piruvato.'),
  (2022, 127, NULL, 'E', 'Fosforilação oxidativa.'),
  (2022, 128, NULL, 'A', '1, 2, 3.'),
  (2022, 128, NULL, 'B', '1, 3, 2.'),
  (2022, 128, NULL, 'C', '2, 1, 3.'),
  (2022, 128, NULL, 'D', '3, 1, 2.'),
  (2022, 128, NULL, 'E', '3, 2, 1.'),
  (2022, 129, NULL, 'A', 'N2'),
  (2022, 129, NULL, 'B', 'NH3'),
  (2022, 129, NULL, 'C', 'NH4 +'),
  (2022, 129, NULL, 'D', 'NO2 −'),
  (2022, 129, NULL, 'E', 'NO3'),
  (2022, 130, NULL, 'A', 'Apresentar daltonismo.'),
  (2022, 130, NULL, 'B', 'Perceber cores fora do espectro do visível.'),
  (2022, 130, NULL, 'C', 'Enxergar bem em ambientes mal iluminados.'),
  (2022, 130, NULL, 'D', 'Necessitar de mais luminosidade para enxergar.'),
  (2022, 130, NULL, 'E', 'Fazer uma pequena distinção de cores em ambientes iluminados.'),
  (2022, 131, NULL, 'A', 'Ramificações.'),
  (2022, 131, NULL, 'B', 'Insaturações.'),
  (2022, 131, NULL, 'C', 'Anel benzênico.'),
  (2022, 131, NULL, 'D', 'Átomos de oxigênio.'),
  (2022, 131, NULL, 'E', 'Carbonos assimétricos.'),
  (2022, 132, NULL, 'A', 'Predação do vírus pela bactéria.'),
  (2022, 132, NULL, 'B', 'Esterilização de mosquitos infectados.'),
  (2022, 132, NULL, 'C', 'Alteração no genótipo do mosquito pela bactéria.'),
  (2022, 132, NULL, 'D', 'Competição do vírus e da bactéria no hospedeiro.'),
  (2022, 132, NULL, 'E', 'Inserção de material genético do vírus na bactéria'),
  (2022, 133, NULL, 'A', 'Autoimunidade.'),
  (2022, 133, NULL, 'B', 'Hipersensibilidade.'),
  (2022, 133, NULL, 'C', 'Ativação da resposta inata.'),
  (2022, 133, NULL, 'D', 'Apresentação de antígeno específico.'),
  (2022, 133, NULL, 'E', 'Desencadeamento de processo anti-inflamatório.'),
  (2022, 134, NULL, 'A', '339 000.'),
  (2022, 134, NULL, 'B', '78 900.'),
  (2022, 134, NULL, 'C', '14 400.'),
  (2022, 134, NULL, 'D', '5 240.'),
  (2022, 134, NULL, 'E', '100.'),
  (2022, 135, NULL, 'A', 'Difração.'),
  (2022, 135, NULL, 'B', 'Absorção.'),
  (2022, 135, NULL, 'C', 'Polarização.'),
  (2022, 135, NULL, 'D', 'Reflexão.'),
  (2022, 135, NULL, 'E', 'Refração.'),
  (2022, 136, NULL, 'A', '1'),
  (2022, 136, NULL, 'B', '2'),
  (2022, 136, NULL, 'C', '3'),
  (2022, 136, NULL, 'D', '4'),
  (2022, 136, NULL, 'E', '5'),
  (2022, 137, NULL, 'A', '![Alternativa A](/midia/enem/2022/q137/a62b92ab-65a1-4608-a3ac-3a1e08008845.webp)'),
  (2022, 137, NULL, 'B', '![Alternativa B](/midia/enem/2022/q137/bcc4e92c-3d8c-40e8-8651-b1829f138eb3.webp)'),
  (2022, 137, NULL, 'C', '![Alternativa C](/midia/enem/2022/q137/b783250d-3cdc-48c4-b60a-44d5b2ccc932.webp)'),
  (2022, 137, NULL, 'D', '![Alternativa D](/midia/enem/2022/q137/ccd84f4e-31eb-4dfe-85be-202683fe5af7.webp)'),
  (2022, 137, NULL, 'E', '![Alternativa E](/midia/enem/2022/q137/1cb4062d-0ed1-45ac-a1f7-ce783f591515.webp)'),
  (2022, 138, NULL, 'A', '1,5'),
  (2022, 138, NULL, 'B', '2,0'),
  (2022, 138, NULL, 'C', '2,9'),
  (2022, 138, NULL, 'D', '3,0'),
  (2022, 138, NULL, 'E', '5,5'),
  (2022, 139, NULL, 'A', '1,80 e 0,60.'),
  (2022, 139, NULL, 'B', '1,80 e 0,70.'),
  (2022, 139, NULL, 'C', '1,90 e 0,80.'),
  (2022, 139, NULL, 'D', '2,00 e 0,90.'),
  (2022, 139, NULL, 'E', '2,00 e 1,00.'),
  (2022, 140, NULL, 'A', '22.'),
  (2022, 140, NULL, 'B', '25.'),
  (2022, 140, NULL, 'C', '28.'),
  (2022, 140, NULL, 'D', '48.'),
  (2022, 140, NULL, 'E', '64.'),
  (2022, 141, NULL, 'A', '![Alternativa A](/midia/enem/2022/q141/cd5a2722-63ec-4baf-bb68-20df7b0342b6.webp)'),
  (2022, 141, NULL, 'B', '![Alternativa B](/midia/enem/2022/q141/3098c816-0b2d-4a41-bd93-48a7103007d3.webp)'),
  (2022, 141, NULL, 'C', '![Alternativa C](/midia/enem/2022/q141/f1b1ddb0-011b-422f-ad9c-be16c2322ab9.webp)'),
  (2022, 141, NULL, 'D', '![Alternativa D](/midia/enem/2022/q141/182be64f-689b-4ab6-b35b-f0dfae3b5a54.webp)'),
  (2022, 141, NULL, 'E', '![Alternativa E](/midia/enem/2022/q141/3d293613-50b5-494a-b8f3-52e16ae9f866.webp)'),
  (2022, 142, NULL, 'A', '8.'),
  (2022, 142, NULL, 'B', '9.'),
  (2022, 142, NULL, 'C', '11.'),
  (2022, 142, NULL, 'D', '18.'),
  (2022, 142, NULL, 'E', '24.'),
  (2022, 143, NULL, 'A', '![Alternativa A](/midia/enem/2022/q143/37b0d8a0-5992-4fac-8f58-93924c6877e2.webp)'),
  (2022, 143, NULL, 'B', '![Alternativa B](/midia/enem/2022/q143/c2a2bae5-e20a-4bdb-af9e-b6d37b0cdc81.webp)'),
  (2022, 143, NULL, 'C', '![Alternativa C](/midia/enem/2022/q143/bfd0a9ed-5ff2-444f-b297-e2f37eba789b.webp)'),
  (2022, 143, NULL, 'D', '![Alternativa D](/midia/enem/2022/q143/b76f04c7-e485-4c93-8e57-60d5ce9f5623.webp)'),
  (2022, 143, NULL, 'E', '![Alternativa E](/midia/enem/2022/q143/2e478466-a3b6-4a44-8c04-a6187dc164df.webp)'),
  (2022, 144, NULL, 'A', '0'),
  (2022, 144, NULL, 'B', '6'),
  (2022, 144, NULL, 'C', '7'),
  (2022, 144, NULL, 'D', '8'),
  (2022, 144, NULL, 'E', '9'),
  (2022, 145, NULL, 'A', '50 000.'),
  (2022, 145, NULL, 'B', '100 000.'),
  (2022, 145, NULL, 'C', '200 000.'),
  (2022, 145, NULL, 'D', '300 000.'),
  (2022, 145, NULL, 'E', '400 000.'),
  (2022, 146, NULL, 'A', '10.'),
  (2022, 146, NULL, 'B', '13.'),
  (2022, 146, NULL, 'C', '14.'),
  (2022, 146, NULL, 'D', '15.'),
  (2022, 146, NULL, 'E', '16'),
  (2022, 147, NULL, 'A', 'Não satisfatório.'),
  (2022, 147, NULL, 'B', 'Regular.'),
  (2022, 147, NULL, 'C', 'Bom.'),
  (2022, 147, NULL, 'D', 'Muito bom.'),
  (2022, 147, NULL, 'E', 'Excelente.'),
  (2022, 148, NULL, 'A', '![Alternativa A](/midia/enem/2022/q148/623219f3-b839-4f65-b990-99e2416e78ac.webp)'),
  (2022, 148, NULL, 'B', '![Alternativa B](/midia/enem/2022/q148/ac0ff64f-89bb-4e7c-a004-f3a22719d728.webp)'),
  (2022, 148, NULL, 'C', '![Alternativa C](/midia/enem/2022/q148/282300db-f32c-4e24-b4ec-da66e734e9c4.webp)'),
  (2022, 148, NULL, 'D', '![Alternativa D](/midia/enem/2022/q148/2e2fa9f3-4c51-4920-8048-790d9f42ed80.webp)'),
  (2022, 148, NULL, 'E', '![Alternativa E](/midia/enem/2022/q148/c37d4dda-0f9a-4756-a282-99e7ddd27c64.webp)'),
  (2022, 149, NULL, 'A', '1,0.'),
  (2022, 149, NULL, 'B', '1,5.'),
  (2022, 149, NULL, 'C', '1,9.'),
  (2022, 149, NULL, 'D', '2,1.'),
  (2022, 149, NULL, 'E', '2,5.'),
  (2022, 150, NULL, 'A', 'Apenas no ginásio I.'),
  (2022, 150, NULL, 'B', 'Apenas nos ginásios I e II.'),
  (2022, 150, NULL, 'C', 'Apenas nos ginásios I, II e III.'),
  (2022, 150, NULL, 'D', 'Apenas nos ginásios I, II, III e IV.'),
  (2022, 150, NULL, 'E', 'Em todos os ginásios.'),
  (2022, 151, NULL, 'A', '30 minutos ou menos.'),
  (2022, 151, NULL, 'B', 'Mais de 35 e menos de 45 minutos.'),
  (2022, 151, NULL, 'C', 'Mais de 45 e menos de 55 minutos.'),
  (2022, 151, NULL, 'D', 'Mais de 60 e menos de 70 minutos.'),
  (2022, 151, NULL, 'E', '70 minutos ou mais.'),
  (2022, 152, NULL, 'A', '26'),
  (2022, 152, NULL, 'B', '27'),
  (2022, 152, NULL, 'C', '28'),
  (2022, 152, NULL, 'D', '29'),
  (2022, 152, NULL, 'E', '35'),
  (2022, 153, NULL, 'A', '1,52.'),
  (2022, 153, NULL, 'B', '3,24.'),
  (2022, 153, NULL, 'C', '3,60.'),
  (2022, 153, NULL, 'D', '6,48.'),
  (2022, 153, NULL, 'E', '7,20.'),
  (2022, 154, NULL, 'A', '16 514.'),
  (2022, 154, NULL, 'B', '86 700.'),
  (2022, 154, NULL, 'C', '115 600.'),
  (2022, 154, NULL, 'D', '441 343.'),
  (2022, 154, NULL, 'E', '448 568.'),
  (2022, 155, NULL, 'A', '![Alternativa A](/midia/enem/2022/q155/4e4d5692-b3ea-4434-aaef-74309d2d3b2a.webp)'),
  (2022, 155, NULL, 'B', '![Alternativa B](/midia/enem/2022/q155/2b0fcee8-c3b1-4c03-ac2a-342792f7ab28.webp)'),
  (2022, 155, NULL, 'C', '![Alternativa C](/midia/enem/2022/q155/e2dfe176-9a1a-49e7-aee5-62794ac8242b.webp)'),
  (2022, 155, NULL, 'D', '![Alternativa D](/midia/enem/2022/q155/0681d716-28d4-4521-801f-5a20871829e5.webp)'),
  (2022, 155, NULL, 'E', '![Alternativa E](/midia/enem/2022/q155/027b58bd-d5b6-4ab1-afb6-a17dd85e31c8.webp)'),
  (2022, 156, NULL, 'A', '![Alternativa A](/midia/enem/2022/q156/538392d5-583a-4aa5-a47c-61ee0bc6b98d.webp)'),
  (2022, 156, NULL, 'B', '![Alternativa B](/midia/enem/2022/q156/78436952-5965-4c7f-80c3-ca2eee79bb4e.webp)'),
  (2022, 156, NULL, 'C', '![Alternativa C](/midia/enem/2022/q156/ddf97279-7187-4bc2-be7b-25bd70510a73.webp)'),
  (2022, 156, NULL, 'D', '![Alternativa D](/midia/enem/2022/q156/b09ad37a-893e-4709-8b48-bded413fc77f.webp)'),
  (2022, 156, NULL, 'E', '![Alternativa E](/midia/enem/2022/q156/c3221442-88b6-455d-bf9f-5097c75188a2.webp)'),
  (2022, 157, NULL, 'A', '![Alternativa A](/midia/enem/2022/q157/fc471085-2399-4726-8cde-a72bae7ac9c5.webp)'),
  (2022, 157, NULL, 'B', '![Alternativa B](/midia/enem/2022/q157/e90bf791-5ee8-4ecf-8c11-34988750ed2b.webp)'),
  (2022, 157, NULL, 'C', '![Alternativa C](/midia/enem/2022/q157/693a22d0-61e8-4f3b-ad77-5b73fc16bc0f.webp)'),
  (2022, 157, NULL, 'D', '![Alternativa D](/midia/enem/2022/q157/62e359c4-eecb-4120-861f-eb5af04c9fec.webp)'),
  (2022, 157, NULL, 'E', '![Alternativa E](/midia/enem/2022/q157/af3c085b-7eb0-4462-a0b1-f79fd1291f67.webp)'),
  (2022, 158, NULL, 'A', 'I.'),
  (2022, 158, NULL, 'B', 'II.'),
  (2022, 158, NULL, 'C', 'III.'),
  (2022, 158, NULL, 'D', 'IV.'),
  (2022, 158, NULL, 'E', 'V.'),
  (2022, 159, NULL, 'A', '![Alternativa A](/midia/enem/2022/q159/63615e39-7138-4ae8-9e1b-5096335cc20f.webp)'),
  (2022, 159, NULL, 'B', '![Alternativa B](/midia/enem/2022/q159/cd6feba8-05d7-401f-87d8-c35ddbc366ef.webp)'),
  (2022, 159, NULL, 'C', '![Alternativa C](/midia/enem/2022/q159/f321765a-d92c-4247-b7eb-941db32d9552.webp)'),
  (2022, 159, NULL, 'D', '![Alternativa D](/midia/enem/2022/q159/0a5dac06-c82a-415a-9ab0-311e0d2138cf.webp)'),
  (2022, 159, NULL, 'E', '![Alternativa E](/midia/enem/2022/q159/a9fa3b63-1dae-4542-9b0f-4338e80df580.webp)'),
  (2022, 160, NULL, 'A', '![Alternativa A](/midia/enem/2022/q160/5d7821fa-37c8-4d86-b71d-4b70a0e1d096.webp)'),
  (2022, 160, NULL, 'B', '![Alternativa B](/midia/enem/2022/q160/6a4daa1c-7f24-439f-b2a3-43eddb2b2400.webp)'),
  (2022, 160, NULL, 'C', '![Alternativa C](/midia/enem/2022/q160/41ab922d-57a6-428b-a207-4dc213ec6481.webp)'),
  (2022, 160, NULL, 'D', '![Alternativa D](/midia/enem/2022/q160/79a7fd8e-7800-4a2f-86d6-33dcbe3aef84.webp)'),
  (2022, 160, NULL, 'E', '![Alternativa E](/midia/enem/2022/q160/2dacf59f-b682-45fb-bd03-29f25ba41487.webp)'),
  (2022, 161, NULL, 'A', '33,40'),
  (2022, 161, NULL, 'B', '66,80'),
  (2022, 161, NULL, 'C', '89,24'),
  (2022, 161, NULL, 'D', '133,60'),
  (2022, 161, NULL, 'E', '534,40'),
  (2022, 162, NULL, 'A', '5 000'),
  (2022, 162, NULL, 'B', '7 000'),
  (2022, 162, NULL, 'C', '11 000'),
  (2022, 162, NULL, 'D', '18 000'),
  (2022, 162, NULL, 'E', '29 000'),
  (2022, 163, NULL, 'A', '14,4.'),
  (2022, 163, NULL, 'B', '20,7.'),
  (2022, 163, NULL, 'C', '22,0.'),
  (2022, 163, NULL, 'D', '30,0.'),
  (2022, 163, NULL, 'E', '37,5'),
  (2022, 164, NULL, 'A', '0,125.'),
  (2022, 164, NULL, 'B', '0,200.'),
  (2022, 164, NULL, 'C', '4,800.'),
  (2022, 164, NULL, 'D', '6,000.'),
  (2022, 164, NULL, 'E', '12,000.'),
  (2022, 165, NULL, 'A', '2,5'),
  (2022, 165, NULL, 'B', '10,0'),
  (2022, 165, NULL, 'C', '730,0'),
  (2022, 165, NULL, 'D', '13 322,5'),
  (2022, 165, NULL, 'E', '53 290,0'),
  (2022, 166, NULL, 'A', '0'),
  (2022, 166, NULL, 'B', '1'),
  (2022, 166, NULL, 'C', '2'),
  (2022, 166, NULL, 'D', '3'),
  (2022, 166, NULL, 'E', '4'),
  (2022, 167, NULL, 'A', 'R$ 2,00 menor.'),
  (2022, 167, NULL, 'B', 'R$ 100,00 menor.'),
  (2022, 167, NULL, 'C', 'R$ 200,00 menor.'),
  (2022, 167, NULL, 'D', 'R$ 42,00 maior.'),
  (2022, 167, NULL, 'E', 'R$ 80,00 maior.'),
  (2022, 168, NULL, 'A', 'DDEFDDEEFFD.'),
  (2022, 168, NULL, 'B', 'DFEFDDDEFFD.'),
  (2022, 168, NULL, 'C', 'DFEFDDEEFFD.'),
  (2022, 168, NULL, 'D', 'EFDFEEDDFFE.'),
  (2022, 168, NULL, 'E', 'EFDFEEEDFFE.'),
  (2022, 169, NULL, 'A', 'I.'),
  (2022, 169, NULL, 'B', 'II.'),
  (2022, 169, NULL, 'C', 'III.'),
  (2022, 169, NULL, 'D', 'IV.'),
  (2022, 169, NULL, 'E', 'V.'),
  (2022, 170, NULL, 'A', '2005'),
  (2022, 170, NULL, 'B', '2007'),
  (2022, 170, NULL, 'C', '2009'),
  (2022, 170, NULL, 'D', '2011'),
  (2022, 170, NULL, 'E', '2013'),
  (2022, 171, NULL, 'A', 'I.'),
  (2022, 171, NULL, 'B', 'II.'),
  (2022, 171, NULL, 'C', 'III.'),
  (2022, 171, NULL, 'D', 'IV.'),
  (2022, 171, NULL, 'E', 'V.'),
  (2022, 172, NULL, 'A', 'I.'),
  (2022, 172, NULL, 'B', 'II.'),
  (2022, 172, NULL, 'C', 'III.'),
  (2022, 172, NULL, 'D', 'IV.'),
  (2022, 172, NULL, 'E', 'V.'),
  (2022, 173, NULL, 'A', '200'),
  (2022, 173, NULL, 'B', '400'),
  (2022, 173, NULL, 'C', '1200'),
  (2022, 173, NULL, 'D', '1235'),
  (2022, 173, NULL, 'E', '7200'),
  (2022, 174, NULL, 'A', '800'),
  (2022, 174, NULL, 'B', '1200'),
  (2022, 174, NULL, 'C', '2400'),
  (2022, 174, NULL, 'D', '4800'),
  (2022, 174, NULL, 'E', '6400'),
  (2022, 175, NULL, 'A', '135 000,00.'),
  (2022, 175, NULL, 'B', '1 350 000,00.'),
  (2022, 175, NULL, 'C', '13 500 000,00.'),
  (2022, 175, NULL, 'D', '135 000 000,00.'),
  (2022, 175, NULL, 'E', '1 350 000 000,00'),
  (2022, 176, NULL, 'A', 'I'),
  (2022, 176, NULL, 'B', 'II'),
  (2022, 176, NULL, 'C', 'III'),
  (2022, 176, NULL, 'D', 'IV'),
  (2022, 176, NULL, 'E', 'V'),
  (2022, 177, NULL, 'A', 'I.'),
  (2022, 177, NULL, 'B', 'II.'),
  (2022, 177, NULL, 'C', 'III.'),
  (2022, 177, NULL, 'D', 'IV.'),
  (2022, 177, NULL, 'E', 'V.'),
  (2022, 178, NULL, 'A', '2'),
  (2022, 178, NULL, 'B', '3'),
  (2022, 178, NULL, 'C', '6'),
  (2022, 178, NULL, 'D', '12'),
  (2022, 178, NULL, 'E', '24'),
  (2022, 179, NULL, 'A', '74,23.'),
  (2022, 179, NULL, 'B', '74,51.'),
  (2022, 179, NULL, 'C', '75,07.'),
  (2022, 179, NULL, 'D', '75,23.'),
  (2022, 179, NULL, 'E', '78,49.'),
  (2022, 180, NULL, 'A', '![Alternativa A](/midia/enem/2022/q180/05cb2bb8-e0d9-4b65-b5cf-8b286af2b395.webp)'),
  (2022, 180, NULL, 'B', '![Alternativa B](/midia/enem/2022/q180/23fc7b65-ca58-4a35-967f-ac9c73b89e03.webp)'),
  (2022, 180, NULL, 'C', '![Alternativa C](/midia/enem/2022/q180/5be81d3b-c2c8-4856-a7b6-9f265a813436.webp)'),
  (2022, 180, NULL, 'D', '![Alternativa D](/midia/enem/2022/q180/c29e4144-4fce-43b2-a402-0ff7de72f3d0.webp)'),
  (2022, 180, NULL, 'E', '![Alternativa E](/midia/enem/2022/q180/5e135009-dbc9-4b08-bdf9-ad95f8f3d14f.webp)')
) AS v(ano, numero, lingua, letra, texto)
JOIN questao q ON q.ano = v.ano AND q.numero = v.numero AND q.lingua_estrangeira IS NOT DISTINCT FROM v.lingua
ON CONFLICT DO NOTHING;

-- Conferência: a migration falha (e é desfeita) se alguma linha não encontrou suas chaves.
DO $$
DECLARE
  total_questoes integer := (SELECT COUNT(*) FROM questao WHERE ano = 2022);
  total_alternativas integer := (SELECT COUNT(*) FROM alternativa al JOIN questao q ON q.id = al.questao_id WHERE q.ano = 2022);
BEGIN
  IF total_questoes <> 185 OR total_alternativas <> 925 THEN
    RAISE EXCEPTION 'Carga do ENEM 2022 incompleta: % questões e % alternativas (esperado: 185 e 925)',
      total_questoes, total_alternativas;
  END IF;
END $$;
