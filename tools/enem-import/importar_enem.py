#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Importador da prova do ENEM 2022 (1ª aplicação, caderno AZUL) para o StudyENEM.

Gera:
  - StudyENEM.API/Data/Migrations/Sql/enem_2022.sql   (carga do banco de questões, executada pela
    migration CargaEnem2022: áreas, habilidades, disciplinas, conteúdos, escala TRI, questões e alternativas)
  - StudyENEM.API/wwwroot/midia/enem/2022/...         (imagens das questões, servidas pelo backend em /midia)
  - StudyENEM.Tests/Dados/tri_validacao_2022.json     (padrões de resposta reais de participantes com a nota
    oficial, usados no teste da TRI; os parâmetros dos itens o teste lê de enem_2022.sql)

Requer Python 3.10+ e o Pillow (pip install pillow), usado para otimizar as imagens;
a opção --auditar requer também o pypdf.
Veja README.md nesta pasta.

    python tools/enem-import/importar_enem.py [--cache DIR] [--auditar] [--revisao]
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import math
import re
import ssl
import statistics
import sys
import time
import unicodedata
import urllib.error
import urllib.request
import zipfile
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image

import matriz_referencia as mr

ANO = 2022
URL_ENEMDEV = "https://api.enem.dev/v1/exams/2022/questions?limit=50&offset={offset}"
URL_MARITACA = "https://huggingface.co/datasets/maritaca-ai/enem/resolve/main/2022.jsonl"
URL_INEP_ZIP = "https://download.inep.gov.br/microdados/microdados_enem_2022.zip"
CADERNOS_OFICIAIS = ("ENEM_2022_P1_CAD_01_DIA_1_AZUL.pdf", "ENEM_2022_P1_CAD_07_DIA_2_AZUL.pdf")

LINHAS_MICRODADOS = 150_000   # linhas lidas do início de MICRODADOS_ENEM_2022.csv
N_CALIBRACAO = 3000           # participantes por área usados na calibração da escala
N_VALIDACAO_TESTE = 12        # participantes por área exportados para o teste automatizado
TOTAL_QUESTOES = 185          # 180 questões + 5 da outra língua estrangeira

RAIZ_BACKEND = Path(__file__).resolve().parents[2]
DIR_API = RAIZ_BACKEND / "StudyENEM.API"
ARQ_SQL = DIR_API / "Data" / "Migrations" / "Sql" / "enem_2022.sql"
DIR_MIDIA = DIR_API / "wwwroot" / "midia" / "enem" / "2022"
URL_MIDIA = "/midia/enem/2022"  # o backend serve essa pasta como arquivo estático
QUALIDADE_WEBP = 90             # só para as imagens que vêm em JPEG; as PNG são convertidas sem perdas
ARQ_VALIDACAO = RAIZ_BACKEND / "StudyENEM.Tests" / "Dados" / "tri_validacao_2022.json"

USER_AGENT = "StudyENEM-importador/1.0 (TCC IFSP Salto)"
LINGUA_INEP = {"ingles": "0", "espanhol": "1"}

# O servidor do INEP não envia a cadeia intermediária do certificado TLS; o urllib
# não consegue validá-lo. Os arquivos são públicos, então aceitamos o certificado.
CONTEXTO_INEP = ssl._create_unverified_context()

# Correções feitas na revisão manual da classificação, após a leitura do enunciado completo:
# (número, língua) → (disciplina, conteúdo).
REVISAO_MANUAL: dict[tuple[int, str | None], tuple[str, str]] = {
    # Ciências Humanas
    (52, None): ("Geografia", "Espaço agrário, indústria e economia"),     # espaço rural e cidade
    (53, None): ("História", "Brasil Império"),                             # mulheres e leitura no Segundo Reinado
    (54, None): ("História", "Brasil Império"),                             # trabalhadores na capital do Império
    (56, None): ("Sociologia", "Tecnologia, mídia e sociedade"),            # exclusão digital na pandemia
    (57, None): ("Filosofia", "Filosofia moderna e contemporânea"),         # Foucault, Vigiar e punir
    (58, None): ("História", "Povos indígenas, africanos e diversidade cultural"),
    (60, None): ("Sociologia", "Tecnologia, mídia e sociedade"),            # celulares e relações humanas
    (61, None): ("Sociologia", "Trabalho e sociedade"),                     # tecnologia e dublagem
    (62, None): ("Geografia", "Geopolítica e cartografia"),                 # Mercosul
    (65, None): ("Sociologia", "Cultura, identidade e movimentos sociais"),
    (66, None): ("História", "Brasil Império"),                             # lei educacional de 1827
    (67, None): ("Sociologia", "Cultura, identidade e movimentos sociais"), # movimento por moradia
    (68, None): ("Geografia", "Geopolítica e cartografia"),                 # estratégia dos EUA
    (69, None): ("Geografia", "Geopolítica e cartografia"),                 # anexação da Crimeia
    (72, None): ("Geografia", "Espaço urbano e população"),                 # distância moradia–emprego
    (78, None): ("Geografia", "Geopolítica e cartografia"),                 # escala cartográfica
    (84, None): ("Filosofia", "Filosofia moderna e contemporânea"),         # Deleuze
    (85, None): ("História", "Idade Moderna e Contemporânea"),              # Inquisição, séc. XV–XIX
    (88, None): ("Filosofia", "Filosofia antiga e medieval"),               # Sêneca
    (89, None): ("História", "Povos indígenas, africanos e diversidade cultural"),  # sociedades pré-colombianas
    # Ciências da Natureza
    (91, None): ("Química", "Oxirredução, eletroquímica e termoquímica"),   # persulfato e TCE
    (101, None): ("Química", "Química ambiental e energia"),                # etanol de cana-de-açúcar
    (106, None): ("Química", "Química orgânica"),                           # derivados da penicilamina
    (109, None): ("Química", "Radioatividade"),                             # meia-vida
    (117, None): ("Química", "Transformações e reações químicas"),          # CaCO3 + HCl
    (124, None): ("Química", "Oxirredução, eletroquímica e termoquímica"),  # ozônio como oxidante
    (133, None): ("Biologia", "Fisiologia humana e animal"),                # sistema imune e tumor
    (134, None): ("Física", "Ondas, óptica e radiação"),                    # eco sonoro
    # Matemática
    (142, None): ("Matemática", "Análise combinatória"),
    (146, None): ("Matemática", "Equações e inequações"),
    (150, None): ("Matemática", "Funções"),                                 # trajetória parabólica
    (153, None): ("Matemática", "Geometria espacial"),
    (154, None): ("Matemática", "Porcentagem e matemática financeira"),
    (155, None): ("Matemática", "Análise combinatória"),
    (169, None): ("Matemática", "Geometria espacial"),
    (172, None): ("Matemática", "Geometria espacial"),
    (178, None): ("Matemática", "Geometria espacial"),
}

# Alternativas corrigidas após a conferência com os cadernos oficiais do INEP (CADERNOS_OFICIAIS;
# veja a opção --auditar): erros de transcrição da fonte textual. (número, língua) → {letra: texto}.
CORRECOES_ALTERNATIVAS: dict[tuple[int, str | None], dict[str, str]] = {
    (1, "espanhol"): {"A": "Difundir a arte iconográfica indígena mexicana."},
    (4, "espanhol"): {"A": "Descaso diante da problemática de crianças em situação de rua."},
    (5, "espanhol"): {
        "A": "Evidenciar a importância de uma rede de apoio para as mães na criação de seus filhos.",
        "B": "Denunciar a disparidade entre o trabalho das mães de diferentes classes sociais.",
        "D": "Ratificar a romantização da dedicação das mães na educação das crianças.",
    },
    (13, None): {"A": "Apontam o desenvolvimento econômico como solução para ampliar o uso da rede."},
    (20, None): {"A": "Promovam a melhoria da aptidão física da população, dedicando-se mais tempo aos esportes."},
    (36, None): {"E": "Responsabilizar os agentes públicos pela demora na tomada de decisões."},
    (40, None): {"E": "Preocupação do vaqueiro em demonstrar sua virilidade."},
    (49, None): {"D": "Tectônica de placas."},
    (50, None): {"D": "Competição entre farmacologia internacional e produtos da fitoterapia."},
    (60, None): {"E": "Cognitiva, favorecendo a aprendizagem pelas ferramentas virtuais."},
    (63, None): {"A": "Da nobreza, proveniente da obrigação de proteção ao campesinato livre."},
    (69, None): {"E": "A expulsão das forças navais ocidentais garantiria a soberania nacional."},
    (89, None): {"C": "Heranças culturais constituídas em saberes próprios."},
    (132, None): {"D": "Competição do vírus e da bactéria no hospedeiro."},
    # A fonte omitiu a alternativa A ("0") e deslocou as letras das demais.
    (144, None): {"A": "0", "B": "6", "C": "7", "D": "8", "E": "9"},
    (166, None): {"A": "0", "B": "1", "C": "2", "D": "3", "E": "4"},
}

# Resíduo de ferramenta de OCR presente em alguns enunciados da enem.dev.
RE_RESIDUO_OCR = re.compile(r"^[ \t]*#{0,6}[ \t]*Translated[ \t]*\(English\).*$", re.IGNORECASE | re.MULTILINE)


def limpar_texto(texto: str) -> str:
    return re.sub(r"\n{3,}", "\n\n", RE_RESIDUO_OCR.sub("", texto)).strip()

# Palavras-chave com 5+ letras que devem casar apenas como palavra inteira
# (as de até 4 letras já são tratadas assim automaticamente).
PALAVRA_INTEIRA = {"media", "polar", "lente", "amina", "ester", "folha"}

MOTIVOS_EXCLUSAO = {
    "bisblg": "Correlação bisserial negativa: item desconsiderado pelo INEP no cálculo da nota",
    "converg": "Parâmetros não convergiram na calibração: item desconsiderado pelo INEP no cálculo da nota",
    "blg": "Parâmetros não estimados na calibração: item desconsiderado pelo INEP no cálculo da nota",
    "bilog": "Parâmetros não convergiram na calibração: item desconsiderado pelo INEP no cálculo da nota",
    "pedagog": "Item anulado pedagogicamente pelo INEP",
}


# ── Rede ────────────────────────────────────────────────────────────────────
def http_get(url: str, cabecalhos: dict | None = None, contexto=None, tentativas: int = 8):
    ultimo = None
    for t in range(tentativas):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, **(cabecalhos or {})})
            with urllib.request.urlopen(req, timeout=180, context=contexto) as r:
                return r.read(), r.headers
        except urllib.error.HTTPError as e:
            ultimo = e
            if e.code != 429 and e.code < 500:
                raise
        except (urllib.error.URLError, ConnectionError, TimeoutError) as e:
            ultimo = e
        time.sleep(3 * (t + 1))
    raise RuntimeError(f"Falha ao baixar {url}: {ultimo}")


class ArquivoRemoto(io.RawIOBase):
    """Arquivo somente leitura sobre HTTP Range: permite abrir um .zip remoto e
    extrair só os membros desejados, sem baixar os ~600 MB dos microdados."""

    def __init__(self, url: str):
        self.url, self.pos = url, 0
        _, cab = http_get(url, {"Range": "bytes=0-0"}, CONTEXTO_INEP)
        self.tamanho = int(re.search(r"/(\d+)", cab["Content-Range"]).group(1))

    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.pos

    def seek(self, deslocamento, origem=0):
        base = {0: 0, 1: self.pos, 2: self.tamanho}[origem]
        self.pos = base + deslocamento
        return self.pos

    def readinto(self, buffer):
        if self.pos >= self.tamanho or len(buffer) == 0:
            return 0
        fim = min(self.pos + len(buffer), self.tamanho) - 1
        dados, _ = http_get(self.url, {"Range": f"bytes={self.pos}-{fim}"}, CONTEXTO_INEP)
        buffer[: len(dados)] = dados
        self.pos += len(dados)
        return len(dados)


# ── Coleta das fontes ───────────────────────────────────────────────────────
def baixar_enemdev(cache: Path) -> list[dict]:
    arq = cache / "enemdev_2022.json"
    if arq.exists():
        return json.loads(arq.read_text(encoding="utf-8"))
    questoes: dict[tuple, dict] = {}
    offset = 0
    while True:
        for _ in range(10):
            dados, _ = http_get(URL_ENEMDEV.format(offset=offset))
            pagina = json.loads(dados)
            if "questions" in pagina:
                break
            time.sleep(6)  # limite de requisições da API
        else:
            raise RuntimeError("enem.dev: limite de requisições persistente")
        for q in pagina["questions"]:
            questoes[(q["index"], q["language"] or "")] = q
        if not pagina["metadata"]["hasMore"]:
            break
        offset += 50
        time.sleep(2)
    lista = sorted(questoes.values(), key=lambda q: (q["index"], q["language"] or ""))
    arq.write_text(json.dumps(lista, ensure_ascii=False), encoding="utf-8")
    return lista


def baixar_maritaca(cache: Path) -> list[dict]:
    arq = cache / "maritaca_2022.jsonl"
    if not arq.exists():
        dados, _ = http_get(URL_MARITACA)
        arq.write_bytes(dados)
    return [json.loads(l) for l in arq.read_text(encoding="utf-8").splitlines() if l.strip()]


def baixar_inep(cache: Path) -> tuple[Path, Path]:
    itens, amostra = cache / "ITENS_PROVA_2022.csv", cache / "MICRODADOS_ENEM_2022_amostra.csv"
    if itens.exists() and amostra.exists():
        return itens, amostra
    print("Abrindo o zip de microdados do INEP via HTTP Range...")
    z = zipfile.ZipFile(io.BufferedReader(ArquivoRemoto(URL_INEP_ZIP), buffer_size=4 << 20))
    for info in z.infolist():
        if info.filename.endswith("ITENS_PROVA_2022.csv"):
            itens.write_bytes(z.read(info))
        elif info.filename.endswith("MICRODADOS_ENEM_2022.csv"):
            with z.open(info) as origem, open(amostra, "wb") as destino:
                for n, linha in enumerate(origem):
                    if n > LINHAS_MICRODADOS:
                        break
                    destino.write(linha)
    return itens, amostra


# ── Cadernos e itens ────────────────────────────────────────────────────────
def area_da_posicao(numero: int) -> str:
    for sigla in ("MT", "CN", "CH", "LC"):
        if numero >= mr.AREAS[sigla]["inicio"]:
            return sigla
    raise ValueError(numero)


def ler_itens(arq: Path) -> dict[str, list[dict]]:
    por_caderno: dict[str, list[dict]] = defaultdict(list)
    with open(arq, encoding="latin-1", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            por_caderno[r["CO_PROVA"]].append(r)
    for itens in por_caderno.values():
        itens.sort(key=lambda r: (int(r["CO_POSICAO"]), r["TP_LINGUA"]))
    return por_caderno


def identificar_caderno(por_caderno, area: str, gabaritos: dict[int, str], lingua_1a5: str) -> str:
    """Caderno (CO_PROVA) da área cujo gabarito coincide com o da fonte textual."""
    candidatos = []
    for cp, itens in por_caderno.items():
        if itens[0]["SG_AREA"] != area or itens[0]["IN_ITEM_ADAPTADO"] == "1":
            continue
        acertos = sum(
            1 for r in itens
            if (int(r["CO_POSICAO"]) > 5 or r["TP_LINGUA"] == lingua_1a5)
            and gabaritos.get(int(r["CO_POSICAO"])) == r["TX_GABARITO"]
        )
        candidatos.append((-acertos, int(cp), cp))
    candidatos.sort()
    return candidatos[0][2]


# ── Texto e imagens ─────────────────────────────────────────────────────────
RE_IMG = re.compile(r"!\[([^\]]*)\]\((https?://[^)\s]+)\)")
RE_IMG_QUALQUER = re.compile(r"!\[[^\]]*\]\([^)]*\)")
MOJIBAKE = {"�\xad": "í", "�\x81": "Á", "�\x8d": "Í", "�\x8f": "Ï", "�\x90": "Ð", "�\x9d": "Ý"}


def corrigir_mojibake(texto: str) -> str:
    for errado, certo in MOJIBAKE.items():
        texto = texto.replace(errado, certo)
    return texto


def otimizar_imagem(origem: Path, pasta_destino: Path) -> Path:
    """
    Converte a imagem para WebP: sem perdas nas PNG (figuras e gráficos, onde texto fino não pode borrar) e
    com qualidade 90 nas JPEG, que já vêm compactadas com perdas. Se o WebP ficar maior, mantém o original.
    """
    pasta_destino.mkdir(parents=True, exist_ok=True)
    convertida, mantida = pasta_destino / (origem.stem + ".webp"), pasta_destino / origem.name
    if convertida.exists():
        return convertida
    if mantida.exists():
        return mantida

    with Image.open(origem) as img:
        tem_alfa = img.mode in ("LA", "RGBA") or "transparency" in img.info
        buffer = io.BytesIO()
        opcoes = {"lossless": True} if origem.suffix.lower() == ".png" else {"quality": QUALIDADE_WEBP}
        img.convert("RGBA" if tem_alfa else "RGB").save(buffer, "WEBP", method=6, **opcoes)

    if len(buffer.getvalue()) < origem.stat().st_size:
        convertida.write_bytes(buffer.getvalue())
        return convertida
    mantida.write_bytes(origem.read_bytes())
    return mantida


def baixar_imagem(url: str, pasta: str, cache: Path) -> str:
    """Baixa a imagem, otimiza e devolve a URL em que a API serve o arquivo final (/midia/...)."""
    nome = url.rsplit("/", 1)[-1]
    origem = cache / "imagens" / pasta / nome
    if not origem.exists():
        dados, _ = http_get(url)
        origem.parent.mkdir(parents=True, exist_ok=True)
        origem.write_bytes(dados)
    return f"{URL_MIDIA}/{pasta}/{otimizar_imagem(origem, DIR_MIDIA / pasta).name}"


def localizar_imagens(texto: str, pasta: str, cache: Path) -> str:
    return RE_IMG.sub(lambda m: f"![{m.group(1)}]({baixar_imagem(m.group(2), pasta, cache)})", texto)


def texto_alternativo(descricao: str) -> str:
    d = re.sub(r"^\s*Descrição da imagem:\s*", "", descricao or "")
    return re.sub(r"\s+", " ", d.replace("[", "(").replace("]", ")")).strip()


def aplicar_correcoes(numero: int, lingua: str | None, alternativas: list[dict]) -> list[dict]:
    correcoes = CORRECOES_ALTERNATIVAS.get((numero, lingua))
    if not correcoes:
        return alternativas
    por_letra = {a["letra"]: a["texto"] for a in alternativas}
    por_letra.update(correcoes)
    return [{"letra": letra, "texto": por_letra[letra]} for letra in sorted(por_letra)]


def validar(questoes: list[dict]) -> None:
    problemas = [
        f"Q{q['numero']} ({q['linguaEstrangeira'] or '-'}): {[a['letra'] for a in q['alternativas']]}"
        for q in questoes
        if [a["letra"] for a in q["alternativas"]] != list("ABCDE") or any(not a["texto"].strip() for a in q["alternativas"])
    ]
    if problemas:
        raise RuntimeError("Questões sem as cinco alternativas A–E: " + "; ".join(problemas))
    if len(questoes) != TOTAL_QUESTOES:
        raise RuntimeError(f"Esperadas {TOTAL_QUESTOES} questões, montadas {len(questoes)}")


# ── Conferência com os cadernos oficiais (--auditar) ────────────────────────
RE_ALTERNATIVAS_PDF = re.compile(
    r"A A (.*?) B B (.*?) C C (.*?) D D (.*?) E E (.*?)"
    r"(?= Questões de| INSTRUÇÕES PARA A REDAÇÃO| RASCUNHO DA REDAÇÃO| LINGUAGENS, CÓDIGOS| CIÊNCIAS HUMANAS E SUAS"
    r"| CIÊNCIAS DA NATUREZA E SUAS| MATEMÁTICA E SUAS|$)")


def texto_caderno_oficial(cache: Path, nome: str) -> str:
    txt = cache / nome.replace(".pdf", ".txt")
    if txt.exists():
        return txt.read_text(encoding="utf-8")
    try:
        import logging
        from pypdf import PdfReader
        logging.getLogger("pypdf").setLevel(logging.ERROR)
    except ImportError:
        raise SystemExit("A opção --auditar requer o pacote pypdf: python -m pip install pypdf")
    pdf = cache / nome
    if not pdf.exists():
        z = zipfile.ZipFile(io.BufferedReader(ArquivoRemoto(URL_INEP_ZIP), buffer_size=4 << 20))
        pdf.write_bytes(z.read(next(i for i in z.infolist() if i.filename.endswith(nome))))
    texto = "\n".join((pagina.extract_text() or "") for pagina in PdfReader(str(pdf)).pages)
    txt.write_text(texto, encoding="utf-8")
    return texto


def blocos_oficiais(texto: str) -> dict[int, list[str]]:
    """Texto de cada questão do caderno, sem marca d'água e rodapés."""
    texto = re.sub(r"(?:ENEM\s*2022\s*){2,}", " ", texto)
    texto = re.sub(r"\*\d{6}AZ\d+\*", " ", texto)
    # Rodapé ("CN - 2° dia | Caderno 7 - AZUL - 1ª Aplicação") e o número da página numa linha vizinha;
    # o número precisa estar sozinho na linha para não consumir uma alternativa como "E E 5".
    texto = re.sub(r"(?:^[ \t]*\d{1,3}[ \t]*\n)?[ \t]*(?:LC|CH|CN|MT)\s*-\s*\d°\s*dia\s*\|\s*Caderno\s*\d+\s*-\s*AZUL"
                   r"\s*-\s*1ª\s*Aplicação[ \t]*(?:\n[ \t]*\d{1,3}[ \t]*$)?", " ", texto, flags=re.M)
    marcas = [(int(m.group(1)), m.start()) for m in re.finditer(r"QUEST[ÃA]O\s+(\d{1,3})\b", texto)]
    blocos: dict[int, list[str]] = defaultdict(list)
    for i, (numero, inicio) in enumerate(marcas):
        fim = marcas[i + 1][1] if i + 1 < len(marcas) else len(texto)
        blocos[numero].append(re.sub(r"\s+", " ", texto[inicio:fim]))
    return blocos


def alternativas_do_bloco(bloco: str) -> list[str] | None:
    # No PDF cada alternativa aparece como "A A texto"; usa a última ocorrência (antes podem existir rótulos de figuras).
    for inicio in reversed([m.start() for m in re.finditer(r"(?<!\S)A A ", bloco)]):
        m = RE_ALTERNATIVAS_PDF.match(bloco, inicio)
        if m:
            return [s.strip() for s in m.groups()]
    return None


def normalizar_comparacao(texto: str) -> str:
    t = unicodedata.normalize("NFKD", RE_IMG_QUALQUER.sub("", texto or "").lower())
    t = "".join(c for c in t if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]", "", t)


def auditar_alternativas(questoes: list[dict], cache: Path):
    """Compara as alternativas montadas com o texto extraído dos cadernos oficiais do INEP."""
    oficial: dict[int, list[str]] = defaultdict(list)
    for nome in CADERNOS_OFICIAIS:
        for numero, blocos in blocos_oficiais(texto_caderno_oficial(cache, nome)).items():
            oficial[numero] += blocos
    nao_verificaveis, divergencias = [], []
    for q in questoes:
        candidatos = [alts for alts in map(alternativas_do_bloco, oficial.get(q["numero"], [])) if alts]
        if not candidatos:
            nao_verificaveis.append(q["numero"])
            continue
        fonte = [normalizar_comparacao(a["texto"]) for a in q["alternativas"]]
        # Questões 1–5 aparecem duas vezes no caderno (inglês e espanhol): usa o bloco mais parecido.
        melhor = max(candidatos, key=lambda alts: sum(f == normalizar_comparacao(o) for f, o in zip(fonte, alts)))
        for alternativa, texto_oficial in zip(q["alternativas"], melhor):
            normalizada = normalizar_comparacao(alternativa["texto"])
            if normalizada and normalizada != normalizar_comparacao(texto_oficial):
                divergencias.append((q["numero"], q["linguaEstrangeira"], alternativa["letra"], alternativa["texto"], texto_oficial))
    return sorted(set(nao_verificaveis)), divergencias


# ── Classificação semiautomática ────────────────────────────────────────────
def normalizar(texto: str) -> str:
    t = RE_IMG.sub(" ", texto or "")
    t = re.sub(r"Dispon[íi]vel em:.*", " ", t)
    t = re.sub(r"https?://\S+|www\.\S+", " ", t)
    t = unicodedata.normalize("NFKD", t.lower())
    t = "".join(c for c in t if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", t)


def pontuar(texto: str, palavras: list[str]) -> float:
    total = 0.0
    for p in palavras:
        if p == "%":
            n = texto.count("%")
        elif len(p.strip()) <= 4 or p in PALAVRA_INTEIRA:
            n = len(re.findall(r"(?<![a-z0-9])" + re.escape(p.strip()) + r"(?:s|es)?(?![a-z0-9])", texto))
        else:
            n = len(re.findall(r"(?<![a-z0-9])" + re.escape(p), texto))
        if n:
            total += (2.0 if " " in p.strip() else 1.0) * min(n, 3)
    return total


def classificar(area: str, habilidade: int, lingua: str | None, texto: str) -> tuple[str, str, str]:
    comp = mr.competencia(area, habilidade)
    tax = mr.TAXONOMIA[area]
    t = normalizar(texto)

    if area == "LC":
        disciplina, conteudo = mr.LC_POR_COMPETENCIA[comp]
        if disciplina == "LEM":
            disciplina = "Inglês" if lingua == "ingles" else "Espanhol"
            conteudo = next(iter(tax[disciplina]))
        return disciplina, conteudo, "habilidade"

    if area == "MT":
        permitidos, padrao = mr.MT_POR_COMPETENCIA[comp]
        placar = {c: pontuar(t, tax["Matemática"][c]) for c in permitidos}
        melhor = max(permitidos, key=lambda c: placar[c])
        if placar[melhor] >= 2 and placar[melhor] > placar[padrao]:
            return "Matemática", melhor, "palavras-chave"
        return "Matemática", padrao, "habilidade"

    if area == "CN":
        permitidas, padrao = mr.CN_POR_HABILIDADE[habilidade]
        disciplinas = permitidas or list(tax)
        bonus = 0.5
    else:
        disciplinas, padrao, bonus = list(tax), mr.CH_POR_COMPETENCIA[comp], 1.0

    placar = {(d, c): pontuar(t, kws) for d in disciplinas for c, kws in tax[d].items()}
    por_disciplina = defaultdict(float)
    for (d, _), s in placar.items():
        por_disciplina[d] += s
    if padrao and padrao[0] in por_disciplina:
        por_disciplina[padrao[0]] += bonus
    disciplina = max(disciplinas, key=lambda d: por_disciplina[d])
    if por_disciplina[disciplina] < 2 and padrao:
        return padrao[0], padrao[1], "habilidade"
    conteudos = tax[disciplina]
    conteudo = max(conteudos, key=lambda c: placar[(disciplina, c)])
    if placar[(disciplina, conteudo)] == 0 and padrao and padrao[0] == disciplina:
        conteudo = padrao[1]
    return disciplina, conteudo, "palavras-chave"


# ── TRI: EAP do modelo logístico de 3 parâmetros ────────────────────────────
# Mesma configuração descrita pelo INEP ("Enem: procedimentos de análise"): EAP com
# 40 pontos de quadratura e priori normal padrão. A constante D = 1 foi confirmada
# empiricamente (D = 1,7 não reproduz as notas oficiais).
GRADE = [-4.0 + 8.0 * k / 39 for k in range(40)]
LOG_PRIORI = [-t * t / 2 for t in GRADE]


def tabela_log(a: float, b: float, c: float):
    lp, lq = [], []
    for t in GRADE:
        p = min(max(c + (1 - c) / (1 + math.exp(-a * (t - b))), 1e-12), 1 - 1e-12)
        lp.append(math.log(p))
        lq.append(math.log(1 - p))
    return lp, lq


def eap(tabelas_e_acertos) -> float:
    soma = LOG_PRIORI[:]
    for (lp, lq), acertou in tabelas_e_acertos:
        v = lp if acertou else lq
        for j in range(40):
            soma[j] += v[j]
    m = max(soma)
    w = [math.exp(s - m) for s in soma]
    return sum(GRADE[j] * w[j] for j in range(40)) / sum(w)


def calibrar_escalas(por_caderno, arq_amostra: Path, cadernos_azul: dict[str, str]):
    """Estima, por área, a transformação linear nota = intercepto + inclinação·θ que
    leva a proficiência EAP (métrica dos parâmetros publicados) à nota oficial."""
    cache_tab: dict = {}

    def itens_do_participante(cp: str, area: str, lingua: str):
        chave = (cp, lingua if area == "LC" else "")
        if chave not in cache_tab:
            seq = [r for r in por_caderno[cp] if area != "LC" or int(r["CO_POSICAO"]) > 5 or r["TP_LINGUA"] == lingua]
            cache_tab[chave] = [
                (r["TX_GABARITO"], tabela_log(float(r["NU_PARAM_A"]), float(r["NU_PARAM_B"]), float(r["NU_PARAM_C"])))
                if r["IN_ITEM_ABAN"] != "1" and r["NU_PARAM_A"] else None
                for r in seq
            ]
        return cache_tab[chave]

    amostras = defaultdict(list)
    validacao = defaultdict(list)
    with open(arq_amostra, encoding="latin-1", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            for area in ("LC", "CH", "CN", "MT"):
                nota, cp = r[f"NU_NOTA_{area}"], r[f"CO_PROVA_{area}"]
                if not nota or float(nota) <= 0 or cp not in por_caderno or r["TP_LINGUA"] not in ("0", "1"):
                    continue
                registro = (cp, r["TP_LINGUA"], r[f"TX_RESPOSTAS_{area}"], float(nota))
                if len(amostras[area]) < N_CALIBRACAO:
                    amostras[area].append(registro)
                if cp == cadernos_azul[area]:
                    validacao[area].append(registro)

    escalas, casos_teste = [], []
    for area in ("LC", "CH", "CN", "MT"):
        thetas, notas = [], []
        for cp, lingua, respostas, nota in amostras[area]:
            itens = itens_do_participante(cp, area, lingua)
            pares = [(tab, (respostas[i] if i < len(respostas) else ".") == gab)
                     for i, item in enumerate(itens) if item for gab, tab in [item]]
            thetas.append(eap(pares))
            notas.append(nota)
        mx, my = statistics.fmean(thetas), statistics.fmean(notas)
        inclinacao = sum((x - mx) * (y - my) for x, y in zip(thetas, notas)) / sum((x - mx) ** 2 for x in thetas)
        intercepto = my - inclinacao * mx
        residuos = [y - (intercepto + inclinacao * x) for x, y in zip(thetas, notas)]
        escalas.append({
            "area": area, "ano": ANO,
            "intercepto": round(intercepto, 4), "inclinacao": round(inclinacao, 4),
            "participantes": len(thetas),
            "rmse": round(math.sqrt(statistics.fmean(e * e for e in residuos)), 4),
            "erroMaximo": round(max(abs(e) for e in residuos), 4),
        })
        # Casos de teste: participantes do caderno AZUL espalhados pela distribuição de notas.
        disponiveis = sorted(validacao[area], key=lambda v: v[3])
        passo = max(1, len(disponiveis) // N_VALIDACAO_TESTE)
        for cp, lingua, respostas, nota in disponiveis[::passo][:N_VALIDACAO_TESTE]:
            casos_teste.append({
                "area": area,
                "lingua": ("ingles" if lingua == "0" else "espanhol") if area == "LC" else None,
                "respostas": respostas,
                "notaOficial": nota,
            })
    return escalas, casos_teste


# ── Montagem ────────────────────────────────────────────────────────────────
def motivo_exclusao(texto: str) -> str:
    t = normalizar(texto)
    for chave, descricao in MOTIVOS_EXCLUSAO.items():
        if chave in t:
            return descricao
    return f"Item desconsiderado pelo INEP no cálculo da nota ({texto})"


def montar_questao(numero, lingua, item, enunciado, alternativas, fonte):
    area = area_da_posicao(numero)
    habilidade = int(item["CO_HABILIDADE"])
    alternativas = aplicar_correcoes(numero, lingua, alternativas)
    texto_classificacao = enunciado + "\n" + "\n".join(a["texto"] for a in alternativas)
    disciplina, conteudo, metodo = classificar(area, habilidade, lingua, texto_classificacao)
    if (numero, lingua) in REVISAO_MANUAL:
        disciplina, conteudo = REVISAO_MANUAL[(numero, lingua)]
        metodo = "revisão manual"
    excluida = item["IN_ITEM_ABAN"] == "1" or not item["NU_PARAM_A"]
    return {
        "numero": numero,
        "dia": mr.AREAS[area]["dia"],
        "area": area,
        "linguaEstrangeira": lingua,
        "disciplina": disciplina,
        "conteudo": conteudo,
        "classificacao": metodo,
        "habilidade": habilidade,
        "coItem": int(item["CO_ITEM"]),
        "enunciado": enunciado,
        "alternativas": alternativas,
        "gabarito": item["TX_GABARITO"] if item["TX_GABARITO"] in "ABCDE" else None,
        "tri": None if excluida else {
            "a": float(item["NU_PARAM_A"]), "b": float(item["NU_PARAM_B"]), "c": float(item["NU_PARAM_C"]),
        },
        "motivoExclusaoTri": motivo_exclusao(item["TX_MOTIVO_ABAN"]) if excluida else None,
        "fonteTexto": fonte,
    }


# ── Script SQL da carga (executado pela migration CargaEnem2022) ────────────
def sql(valor) -> str:
    """Literal SQL do PostgreSQL para textos, números e nulos."""
    if valor is None:
        return "NULL"
    if isinstance(valor, (int, float)):
        return repr(valor)
    return "'" + str(valor).replace("'", "''") + "'"


def linhas_values(linhas: list[list], comentarios: list[str] | None = None) -> str:
    saida = []
    for i, linha in enumerate(linhas):
        if comentarios:
            saida.append(f"  -- {comentarios[i]}")
        saida.append("  (" + ", ".join(sql(v) for v in linha) + ")" + ("," if i < len(linhas) - 1 else ""))
    return "\n".join(saida)


def gerar_sql(areas, habilidades, escalas, questoes) -> str:
    n_questoes = len(questoes)
    n_alternativas = sum(len(q["alternativas"]) for q in questoes)
    disciplinas = [[a["sigla"], d["nome"]] for a in areas for d in a["disciplinas"]]
    conteudos = [[a["sigla"], d["nome"], c] for a in areas for d in a["disciplinas"] for c in d["conteudos"]]

    partes = [f"""-- =============================================================================
-- StudyENEM · Banco de questões do ENEM {ANO} (1ª aplicação, caderno AZUL)
--
-- Gerado automaticamente por backend/tools/enem-import/importar_enem.py.
-- NÃO EDITE MANUALMENTE: altere o importador e gere o arquivo novamente.
-- Executado pela migration CargaEnem{ANO} (StudyENEM.API/Data/Migrations).
--
-- Fontes:
--   INEP, Microdados do ENEM {ANO} (ITENS_PROVA_{ANO}.csv): gabarito oficial, habilidade,
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
""",
        f"""-- Áreas do conhecimento
INSERT INTO area (sigla, nome, ordem) VALUES
{linhas_values([[a["sigla"], a["nome"], a["ordem"]] for a in areas])}
ON CONFLICT DO NOTHING;
""",
        f"""-- Habilidades da Matriz de Referência do ENEM ({len(habilidades)})
INSERT INTO habilidade (area_id, codigo, competencia, descricao)
SELECT a.id, v.codigo, v.competencia, v.descricao
FROM (VALUES
{linhas_values([[h["area"], h["codigo"], h["competencia"], h["descricao"]] for h in habilidades])}
) AS v(area, codigo, competencia, descricao)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;
""",
        f"""-- Disciplinas ({len(disciplinas)})
INSERT INTO disciplina (area_id, nome)
SELECT a.id, v.nome
FROM (VALUES
{linhas_values(disciplinas)}
) AS v(area, nome)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;
""",
        f"""-- Conteúdos (objetos de conhecimento) ({len(conteudos)})
INSERT INTO conteudo (disciplina_id, nome)
SELECT d.id, v.nome
FROM (VALUES
{linhas_values(conteudos)}
) AS v(area, disciplina, nome)
JOIN area a ON a.sigla = v.area
JOIN disciplina d ON d.area_id = a.id AND d.nome = v.disciplina
ON CONFLICT DO NOTHING;
""",
        f"""-- Escala da TRI por área: nota = intercepto + inclinação × θ
-- (calibrada contra as notas oficiais de participantes dos microdados)
INSERT INTO escala_tri (area_id, ano, intercepto, inclinacao, calibracao_participantes, calibracao_rmse, calibracao_erro_maximo)
SELECT a.id, v.ano, v.intercepto, v.inclinacao, v.participantes, v.rmse, v.erro_maximo
FROM (VALUES
{linhas_values([[e["area"], e["ano"], e["intercepto"], e["inclinacao"], e["participantes"], e["rmse"], e["erroMaximo"]] for e in escalas])}
) AS v(area, ano, intercepto, inclinacao, participantes, rmse, erro_maximo)
JOIN area a ON a.sigla = v.area
ON CONFLICT DO NOTHING;
""",
        f"""-- Questões ({n_questoes})
INSERT INTO questao (area_id, disciplina_id, conteudo_id, habilidade_id, ano, numero, dia, lingua_estrangeira,
                     codigo_item_inep, enunciado, gabarito, tri_a, tri_b, tri_c, motivo_exclusao_tri, metodo_classificacao)
SELECT a.id, d.id, c.id, h.id, v.ano, v.numero, v.dia, v.lingua,
       v.codigo_item, v.enunciado, v.gabarito, v.tri_a, v.tri_b, v.tri_c, v.motivo, v.metodo
FROM (VALUES
{linhas_values(
    [[ANO, q["numero"], q["dia"], q["linguaEstrangeira"], q["area"], q["disciplina"], q["conteudo"], q["habilidade"],
      q["coItem"], q["enunciado"], q["gabarito"],
      q["tri"]["a"] if q["tri"] else None, q["tri"]["b"] if q["tri"] else None, q["tri"]["c"] if q["tri"] else None,
      q["motivoExclusaoTri"], q["classificacao"]] for q in questoes],
    [f"Questão {q['numero']}{' (' + q['linguaEstrangeira'] + ')' if q['linguaEstrangeira'] else ''} · "
     f"{q['area']} · {q['disciplina']} · {q['conteudo']} · H{q['habilidade']}" for q in questoes])}
) AS v(ano, numero, dia, lingua, area, disciplina, conteudo, habilidade,
       codigo_item, enunciado, gabarito, tri_a, tri_b, tri_c, motivo, metodo)
JOIN area a ON a.sigla = v.area
JOIN disciplina d ON d.area_id = a.id AND d.nome = v.disciplina
JOIN conteudo c ON c.disciplina_id = d.id AND c.nome = v.conteudo
JOIN habilidade h ON h.area_id = a.id AND h.codigo = v.habilidade
ON CONFLICT DO NOTHING;
""",
        f"""-- Alternativas ({n_alternativas})
INSERT INTO alternativa (questao_id, letra, texto)
SELECT q.id, v.letra, v.texto
FROM (VALUES
{linhas_values([[ANO, q["numero"], q["linguaEstrangeira"], alt["letra"], alt["texto"]]
                for q in questoes for alt in q["alternativas"]])}
) AS v(ano, numero, lingua, letra, texto)
JOIN questao q ON q.ano = v.ano AND q.numero = v.numero AND q.lingua_estrangeira IS NOT DISTINCT FROM v.lingua
ON CONFLICT DO NOTHING;
""",
        f"""-- Conferência: a migration falha (e é desfeita) se alguma linha não encontrou suas chaves.
DO $$
DECLARE
  total_questoes integer := (SELECT COUNT(*) FROM questao WHERE ano = {ANO});
  total_alternativas integer := (SELECT COUNT(*) FROM alternativa al JOIN questao q ON q.id = al.questao_id WHERE q.ano = {ANO});
BEGIN
  IF total_questoes <> {n_questoes} OR total_alternativas <> {n_alternativas} THEN
    RAISE EXCEPTION 'Carga do ENEM {ANO} incompleta: % questões e % alternativas (esperado: {n_questoes} e {n_alternativas})',
      total_questoes, total_alternativas;
  END IF;
END $$;
""",
    ]
    return "\n".join(partes)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--cache", type=Path, default=Path(__file__).parent / ".cache")
    parser.add_argument("--auditar", action="store_true",
                        help="confere as alternativas com os cadernos oficiais do INEP (requer pypdf)")
    parser.add_argument("--revisao", action="store_true", help="imprime a classificação de CH, CN e MT para revisão manual")
    args = parser.parse_args()
    args.cache.mkdir(parents=True, exist_ok=True)

    enemdev = baixar_enemdev(args.cache)
    maritaca = baixar_maritaca(args.cache)
    arq_itens, arq_amostra = baixar_inep(args.cache)
    por_caderno = ler_itens(arq_itens)
    print(f"enem.dev: {len(enemdev)} questões | maritaca: {len(maritaca)} | cadernos INEP: {len(por_caderno)}")

    gab_enemdev = {q["index"]: q["correctAlternative"] for q in enemdev}
    azul = {a: identificar_caderno(por_caderno, a, gab_enemdev, LINGUA_INEP["espanhol"]) for a in mr.AREAS}
    print("Cadernos correspondentes à ordem da enem.dev:", {a: (cp, por_caderno[cp][0]["TX_COR"]) for a, cp in azul.items()})

    def item_azul(numero: int, lingua: str | None) -> dict:
        tp = LINGUA_INEP[lingua] if lingua else ""
        return next(r for r in por_caderno[azul[area_da_posicao(numero)]]
                    if int(r["CO_POSICAO"]) == numero and r["TP_LINGUA"] == tp)

    questoes = []
    divergencias = []
    for q in enemdev:
        numero, lingua = q["index"], q["language"]
        pasta = f"q{numero:03d}" + (f"-{lingua}" if lingua else "")
        item = item_azul(numero, lingua)
        if item["TX_GABARITO"] in "ABCDE" and item["TX_GABARITO"] != q["correctAlternative"]:
            divergencias.append((numero, q["correctAlternative"], item["TX_GABARITO"]))
        enunciado = limpar_texto("\n\n".join(p.strip() for p in (q["context"], q["alternativesIntroduction"]) if p and p.strip()))
        alternativas = []
        for a in q["alternatives"]:
            partes = [a["text"].strip()] if a["text"] and a["text"].strip() else []
            if a["file"]:
                partes.append(f"![Alternativa {a['letter']}]({a['file']})")
            alternativas.append({"letra": a["letter"], "texto": localizar_imagens("\n\n".join(partes), pasta, args.cache)})
        questoes.append(montar_questao(numero, lingua, item, localizar_imagens(enunciado, pasta, args.cache), alternativas, "enem.dev"))

    # Questões 1–5 de inglês: maritaca-ai/enem segue outro caderno; mapeamos pelo código do item (CO_ITEM).
    gab_maritaca = {int(m["id"].split("_")[1]): m["label"] for m in maritaca}
    cp_maritaca = identificar_caderno(por_caderno, "LC", gab_maritaca, LINGUA_INEP["ingles"])
    for m in maritaca:
        pos_origem = int(m["id"].split("_")[1])
        if pos_origem > 5:
            continue
        co_item = next(r["CO_ITEM"] for r in por_caderno[cp_maritaca]
                       if int(r["CO_POSICAO"]) == pos_origem and r["TP_LINGUA"] == "0")
        item = next(r for r in por_caderno[azul["LC"]] if r["CO_ITEM"] == co_item and r["TP_LINGUA"] == "0")
        numero = int(item["CO_POSICAO"])
        if m["label"] != item["TX_GABARITO"]:
            raise RuntimeError(f"Gabarito divergente na questão {numero} (inglês)")
        pasta = f"q{numero:03d}-ingles"
        figuras = iter(m["figures"])
        descricoes = iter(m["description"])
        enunciado = corrigir_mojibake(m["question"])
        while "[[placeholder]]" in enunciado:
            url = baixar_imagem(next(figuras), pasta, args.cache)
            enunciado = enunciado.replace("[[placeholder]]", f"![{texto_alternativo(next(descricoes, ''))}]({url})\n\n", 1)
        alternativas = [{"letra": "ABCDE"[i], "texto": corrigir_mojibake(t).strip()} for i, t in enumerate(m["alternatives"])]
        questoes.append(montar_questao(numero, "ingles", item, enunciado.strip(), alternativas, "maritaca-ai/enem"))

    questoes.sort(key=lambda q: (q["numero"], q["linguaEstrangeira"] or ""))
    validar(questoes)
    corrigidas = sum(len(c) for c in CORRECOES_ALTERNATIVAS.values())
    print(f"Questões montadas: {len(questoes)} | gabaritos corrigidos pelo INEP: {divergencias} | "
          f"alternativas corrigidas pelo caderno oficial: {corrigidas} em {len(CORRECOES_ALTERNATIVAS)} questões")

    if args.auditar:
        nao_verificaveis, diferencas = auditar_alternativas(questoes, args.cache)
        print("\n── Conferência das alternativas com os cadernos oficiais do INEP ──")
        print(f"Sem alternativas em texto no PDF (imagens ou fórmulas): {nao_verificaveis}")
        print(f"Divergências: {len(diferencas)}")
        for numero, lingua, letra, fonte, oficial in diferencas:
            print(f"  Q{numero}{' (' + lingua + ')' if lingua else ''} {letra}: montada={fonte!r} | oficial={oficial[:200]!r}")

    escalas, casos_teste = calibrar_escalas(por_caderno, arq_amostra, azul)
    for e in escalas:
        print(f"Escala TRI {e['area']}: nota = {e['intercepto']} + {e['inclinacao']}·θ "
              f"(n={e['participantes']}, RMSE={e['rmse']}, erro máx.={e['erroMaximo']})")

    usados = defaultdict(lambda: defaultdict(list))
    for q in questoes:
        if q["conteudo"] not in usados[q["area"]][q["disciplina"]]:
            usados[q["area"]][q["disciplina"]].append(q["conteudo"])
    areas = [{
        "sigla": sigla, "nome": info["nome"], "ordem": i + 1,
        "disciplinas": [
            {"nome": d, "conteudos": [c for c in mr.TAXONOMIA[sigla][d] if c in usados[sigla][d]]}
            for d in mr.TAXONOMIA[sigla] if d in usados[sigla]
        ],
    } for i, (sigla, info) in enumerate(mr.AREAS.items())]
    habilidades = [{"area": a, "codigo": h, "competencia": mr.competencia(a, h), "descricao": d}
                   for a in mr.AREAS for h, d in mr.HABILIDADES[a].items()]

    ARQ_SQL.parent.mkdir(parents=True, exist_ok=True)
    ARQ_SQL.write_text(gerar_sql(areas, habilidades, escalas, questoes), encoding="utf-8", newline="\n")

    # Só os participantes: o teste lê os parâmetros dos itens e as escalas do próprio script de carga.
    validacao = {
        "descricao": f"Validação da TRI: padrões de resposta reais de participantes do caderno AZUL do ENEM {ANO} "
                     f"com a nota oficial (microdados do INEP). Os parâmetros dos itens e as escalas estão em {ARQ_SQL.name}.",
        "casos": casos_teste,
    }
    ARQ_VALIDACAO.parent.mkdir(parents=True, exist_ok=True)
    ARQ_VALIDACAO.write_text(json.dumps(validacao, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"\nGerado {ARQ_SQL.relative_to(RAIZ_BACKEND)} ({ARQ_SQL.stat().st_size // 1024} KB, "
          f"{len(questoes)} questões, {sum(len(q['alternativas']) for q in questoes)} alternativas)")
    arquivos = [p for p in DIR_MIDIA.rglob("*") if p.is_file()]
    print(f"Gravadas {len(arquivos)} imagens em {DIR_MIDIA.relative_to(RAIZ_BACKEND)} "
          f"({sum(p.stat().st_size for p in arquivos) // 1024} KB)")
    print(f"Gerado {ARQ_VALIDACAO.relative_to(RAIZ_BACKEND)} ({len(casos_teste)} casos)")
    print("Por área/disciplina:", {a: dict(Counter(q["disciplina"] for q in questoes if q["area"] == a)) for a in mr.AREAS})
    print("Método de classificação:", dict(Counter(q["classificacao"] for q in questoes)))
    print("Sem gabarito (anuladas):", [q["numero"] for q in questoes if not q["gabarito"]],
          "| excluídas da TRI:", [q["numero"] for q in questoes if not q["tri"]])

    if args.revisao:
        print("\n── Revisão da classificação ──")
        for q in questoes:
            if q["area"] == "LC":
                continue
            trecho = normalizar(q["enunciado"])[-150:]
            print(f"{q['numero']:>3} {q['area']} H{q['habilidade']:<2} {q['disciplina'][:10]:<10} | "
                  f"{q['conteudo'][:34]:<34} | {q['classificacao'][:5]} | …{trecho}")


if __name__ == "__main__":
    main()
