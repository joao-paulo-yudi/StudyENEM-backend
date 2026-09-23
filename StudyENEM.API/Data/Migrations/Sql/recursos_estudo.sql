-- Catálogo de fontes de estudo recomendadas pelo plano (RF06).
--
-- Cada linha é uma FONTE (canal do YouTube, banco de exercícios ou material de apoio), não
-- um vídeo específico: o marcador {consulta} da coluna url_modelo é substituído em tempo de
-- execução pelo nome do conteúdo em que o estudante mais erra. Assim a recomendação
-- acompanha os 58 conteúdos do banco de questões sem depender de links que saem do ar, e
-- novas fontes entram apenas com um INSERT.
--
-- A coluna conteudo_id permite restringir uma fonte a um único conteúdo; a curadoria atual
-- é por disciplina (e geral), e a granularidade por conteúdo fica disponível para extensão.

-- 1) Fontes gerais: valem para qualquer disciplina, exibidas depois das específicas (ordem 90+).
INSERT INTO recurso (disciplina_id, conteudo_id, tipo, titulo, fonte, url_modelo, descricao, ordem)
VALUES
  (NULL, NULL, 'video', 'Todas as videoaulas sobre o conteúdo', 'YouTube',
   'https://www.youtube.com/results?search_query={consulta}+ENEM',
   'Busca aberta no YouTube, caso queira outras explicações do mesmo assunto.', 90),
  (NULL, NULL, 'exercicio', 'Exercícios comentados sobre o conteúdo', 'Brasil Escola',
   'https://exercicios.brasilescola.uol.com.br/busca?q={consulta}',
   'Listas com resolução comentada, separadas por assunto.', 90),
  (NULL, NULL, 'exercicio', 'Provas e gabaritos das edições anteriores', 'INEP',
   'https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/enem/provas-e-gabaritos',
   'Cadernos oficiais do ENEM para treinar com a prova completa.', 92),
  (NULL, NULL, 'material', 'Resumo teórico do conteúdo', 'Mundo Educação',
   'https://mundoeducacao.uol.com.br/busca?q={consulta}',
   'Texto de apoio para revisar a teoria antes de resolver questões.', 90),
  (NULL, NULL, 'material', 'Resumo com esquemas e exemplos', 'Toda Matéria',
   'https://www.todamateria.com.br/?s={consulta}',
   'Resumos curtos, úteis para revisão de véspera.', 91)
ON CONFLICT DO NOTHING;

-- 2) Fontes por disciplina: canais e sites especializados na matéria do conteúdo priorizado.
INSERT INTO recurso (disciplina_id, conteudo_id, tipo, titulo, fonte, url_modelo, descricao, ordem)
SELECT d.id, NULL, v.tipo, v.titulo, v.fonte, v.url_modelo, v.descricao, v.ordem
FROM (VALUES
  -- ── Linguagens, Códigos e suas Tecnologias ────────────────────────────────
  ('LC', 'Língua Portuguesa', 'video', 'Gramática e interpretação para o ENEM', 'Prof. Fábio Alves',
   'https://www.youtube.com/@professorfabioalves/search?query={consulta}', NULL, 1),
  ('LC', 'Língua Portuguesa', 'video', 'Português do zero, com exercícios resolvidos', 'Português Online',
   'https://www.youtube.com/@portuguesonlinealine/search?query={consulta}', NULL, 2),
  ('LC', 'Língua Portuguesa', 'video', 'Aulas de língua portuguesa passo a passo', 'Tiago Buranello',
   'https://www.youtube.com/@tiago_buranello/search?query={consulta}', NULL, 3),

  ('LC', 'Literatura', 'video', 'Escolas literárias e obras cobradas no ENEM', 'Débora Aladim',
   'https://www.youtube.com/@deboraaladim/search?query={consulta}', NULL, 1),
  ('LC', 'Literatura', 'video', 'Literatura para o vestibular', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}', NULL, 2),

  ('LC', 'Inglês', 'video', 'Estratégias de leitura em inglês para o ENEM', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}+ingles', NULL, 1),
  ('LC', 'Inglês', 'video', 'Inglês do básico ao avançado', 'ESL Winner',
   'https://www.youtube.com/@eslwinner/search?query={consulta}', NULL, 2),

  ('LC', 'Espanhol', 'video', 'Espanhol para o ENEM', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}+espanhol', NULL, 1),
  ('LC', 'Espanhol', 'video', 'Aulas de espanhol para o vestibular', 'AulaLivre',
   'https://www.youtube.com/@aulalivre/search?query={consulta}+espanhol', NULL, 2),

  ('LC', 'Artes', 'video', 'Movimentos artísticos e leitura de imagem', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}+artes', NULL, 1),
  ('LC', 'Artes', 'video', 'Arte e cultura na prova de Linguagens', 'ProEnem',
   'https://www.youtube.com/@proenemoficial/search?query={consulta}+artes', NULL, 2),

  ('LC', 'Educação Física', 'video', 'Práticas corporais e saúde no ENEM', 'ProEnem',
   'https://www.youtube.com/@proenemoficial/search?query={consulta}+educacao+fisica', NULL, 1),
  ('LC', 'Educação Física', 'video', 'Educação física para o vestibular', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}+educacao+fisica', NULL, 2),

  ('LC', 'Tecnologias da Informação e Comunicação', 'video', 'Linguagem digital e mídias no ENEM', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}', NULL, 1),
  ('LC', 'Tecnologias da Informação e Comunicação', 'video', 'Gêneros digitais e comunicação', 'AulaLivre',
   'https://www.youtube.com/@aulalivre/search?query={consulta}', NULL, 2),

  -- ── Ciências Humanas e suas Tecnologias ───────────────────────────────────
  ('CH', 'História', 'video', 'História do Brasil e geral em videoaulas', 'Débora Aladim',
   'https://www.youtube.com/@deboraaladim/search?query={consulta}', NULL, 1),
  ('CH', 'História', 'video', 'História e atualidades para o ENEM', 'História Online',
   'https://www.youtube.com/@historia-online/search?query={consulta}', NULL, 2),
  ('CH', 'História', 'video', 'Aulas de humanas com foco na prova', 'Parabólica',
   'https://www.youtube.com/@parabolica/search?query={consulta}', NULL, 3),

  ('CH', 'Geografia', 'video', 'Geografia, geopolítica e atualidades', 'Plano Piloto',
   'https://www.youtube.com/@planopiloto/search?query={consulta}', NULL, 1),
  ('CH', 'Geografia', 'video', 'Geografia para o vestibular', 'Descomplica',
   'https://www.youtube.com/@descomplica/search?query={consulta}+geografia', NULL, 2),
  ('CH', 'Geografia', 'video', 'Atualidades ligadas ao conteúdo', 'Parabólica',
   'https://www.youtube.com/@parabolica/search?query={consulta}', NULL, 3),

  ('CH', 'Filosofia', 'video', 'Filosofia explicada do começo', 'Partiu Universidade',
   'https://www.youtube.com/@partiuuniversidade/search?query={consulta}', NULL, 1),
  ('CH', 'Filosofia', 'video', 'Grandes pensadores e conceitos', 'Casa do Saber',
   'https://www.youtube.com/@casadosaber/search?query={consulta}', NULL, 2),
  ('CH', 'Filosofia', 'video', 'Filosofia aplicada à prova', 'Parabólica',
   'https://www.youtube.com/@parabolica/search?query={consulta}+filosofia', NULL, 3),

  ('CH', 'Sociologia', 'video', 'Teorias sociológicas para o ENEM', 'Partiu Universidade',
   'https://www.youtube.com/@partiuuniversidade/search?query={consulta}', NULL, 1),
  ('CH', 'Sociologia', 'video', 'Sociologia e atualidades', 'Parabólica',
   'https://www.youtube.com/@parabolica/search?query={consulta}+sociologia', NULL, 2),

  -- ── Ciências da Natureza e suas Tecnologias ───────────────────────────────
  ('CN', 'Física', 'video', 'Física do zero, com resolução de questões', 'Chama o Físico',
   'https://www.youtube.com/@chamaofisico/search?query={consulta}', NULL, 1),
  ('CN', 'Física', 'video', 'Física com simulações e experimentos', 'Física Interativa',
   'https://www.youtube.com/@fisicainterativa/search?query={consulta}', NULL, 2),
  ('CN', 'Física', 'video', 'Aulas de física para o ENEM', 'Mestres do ENEM',
   'https://www.youtube.com/@umbertomann/search?query={consulta}', NULL, 3),

  ('CN', 'Química', 'video', 'Química para o ENEM, do básico ao avançado', 'Paulo Valim',
   'https://www.youtube.com/@paulovalim/search?query={consulta}', NULL, 1),
  ('CN', 'Química', 'video', 'Teoria e exercícios de química', 'Prof. Michel Química',
   'https://www.youtube.com/@profmichelquimica/search?query={consulta}', NULL, 2),
  ('CN', 'Química', 'video', 'Química descomplicada em aulas curtas', 'Química do Monstro',
   'https://www.youtube.com/@quimicadomonstro/search?query={consulta}', NULL, 3),

  ('CN', 'Biologia', 'video', 'Biologia completa para o vestibular', 'Biologia Total',
   'https://www.youtube.com/@paulojubilut/search?query={consulta}', NULL, 1),
  ('CN', 'Biologia', 'video', 'Biologia com foco nas questões do ENEM', 'Bio Explica',
   'https://www.youtube.com/@bioexplica/search?query={consulta}', NULL, 2),
  ('CN', 'Biologia', 'video', 'Revisões e resolução de questões de biologia', 'Prof. Andrey Tubarão',
   'https://www.youtube.com/@andreytubarao/search?query={consulta}', NULL, 3),

  -- ── Matemática e suas Tecnologias ─────────────────────────────────────────
  ('MT', 'Matemática', 'video', 'Matemática do ensino médio, aula por aula', 'Professor Ferretto',
   'https://www.youtube.com/@professorferretto/search?query={consulta}', NULL, 1),
  ('MT', 'Matemática', 'video', 'Matemática básica explicada com calma', 'Gis com Giz',
   'https://www.youtube.com/@giscomgiz/search?query={consulta}', NULL, 2),
  ('MT', 'Matemática', 'video', 'Resolução detalhada de exercícios', 'Profa. Angela Matemática',
   'https://www.youtube.com/@professoraangelamatematica/search?query={consulta}', NULL, 3),

  -- ── Exercícios: Khan Academy tem trilhas com correção nas áreas exatas ─────
  ('MT', 'Matemática', 'exercicio', 'Trilha de exercícios com correção automática', 'Khan Academy',
   'https://pt.khanacademy.org/search?page_search_query={consulta}',
   'Exercícios em sequência, do básico ao avançado, com dicas a cada erro.', 1),
  ('CN', 'Física', 'exercicio', 'Trilha de exercícios com correção automática', 'Khan Academy',
   'https://pt.khanacademy.org/search?page_search_query={consulta}',
   'Exercícios em sequência, do básico ao avançado, com dicas a cada erro.', 1),
  ('CN', 'Química', 'exercicio', 'Trilha de exercícios com correção automática', 'Khan Academy',
   'https://pt.khanacademy.org/search?page_search_query={consulta}',
   'Exercícios em sequência, do básico ao avançado, com dicas a cada erro.', 1),
  ('CN', 'Biologia', 'exercicio', 'Trilha de exercícios com correção automática', 'Khan Academy',
   'https://pt.khanacademy.org/search?page_search_query={consulta}',
   'Exercícios em sequência, do básico ao avançado, com dicas a cada erro.', 1)
) AS v(area, disciplina, tipo, titulo, fonte, url_modelo, descricao, ordem)
JOIN area a ON a.sigla = v.area
JOIN disciplina d ON d.area_id = a.id AND d.nome = v.disciplina
ON CONFLICT DO NOTHING;
