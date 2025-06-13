import streamlit as st
import pandas as pd
import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import io
import re
import shutil

# Detecta onde está o executável do tesseract
tesseract_path = shutil.which("tesseract")
if tesseract_path:
    pytesseract.pytesseract.tesseract_cmd = tesseract_path
else:
    raise RuntimeError("Tesseract não encontrado no PATH")

st.set_page_config(page_title="GNRE → Excel", layout="wide")
st.title("📄 Extrator GNRE para Planilha Financeira")
st.markdown("Faça upload dos PDFs da GNRE e gere automaticamente a planilha no formato correto.")

uploaded_files = st.file_uploader("📁 Envie um ou mais arquivos PDF:", type="pdf", accept_multiple_files=True)

@st.cache_data
def extract_data_from_pdf(file):
    doc = fitz.open(stream=file.read(), filetype="pdf")
    page = doc[0]
    pix = page.get_pixmap(dpi=300)
    image = Image.open(io.BytesIO(pix.tobytes("png")))
    ocr_text = pytesseract.image_to_string(image)

    # Extrair CNPJ do contribuinte
    cnpj_contrib_match = re.search(r"COMERCIO ARTIGOS MOMBEK LTDA\s+(\d{14})", ocr_text)
    cnpj_contrib = cnpj_contrib_match.group(1) if cnpj_contrib_match else ""

    # UF Favorecida
    uf_match = re.search(r"UF Favorecida\s+([A-Z]{2})", ocr_text)
    uf = uf_match.group(1) if uf_match else ""

    # Histórico com CNPJ - UF
    historico = f"{cnpj_contrib}-{uf}"

    # Classificação
    classificacao = "GNRE"

    # Saída
    saida_match = re.search(r"Total a recolher\s+.*?(\d{1,3},\d{2})", ocr_text)
    saida_valor = saida_match.group(1) if saida_match else ""

    # NFe / RPS: buscar diretamente no OCR (mais preciso)
    nfe_rps_match = re.search(r"No de Controle\s*(\d{10,20})", ocr_text)
    nfe_rps = nfe_rps_match.group(1) if nfe_rps_match else ""

    return {
        "Histórico": historico,
        "Classificação": classificacao,
        "NFe / RPS": nfe_rps,
        "Saídas (Vlr. Original)": saida_valor
    }

if uploaded_files:
    registros = []
    for file in uploaded_files:
        try:
            data = extract_data_from_pdf(file)
            registros.append(data)
        except Exception as e:
            st.error(f"Erro ao processar {file.name}: {str(e)}")

    if registros:
        df = pd.DataFrame(registros)
        df["Data"] = ""  # Campo em branco para preenchimento posterior
        df["Série NF"] = ""
        df["Fornecedor"] = "COMERCIO ARTIGOS MOMBEK LTDA"
        df["Entradas"] = ""
        df["Multa"] = "0,00"
        df["Juros"] = "0,00"
        df["Saldo"] = ""

        # Reordenar colunas
        cols = [
            "Data", "Histórico", "Classificação", "NFe / RPS", "Série NF", "Fornecedor",
            "Entradas", "Saídas (Vlr. Original)", "Multa", "Juros", "Saldo"
        ]
        df = df[cols]

        st.success("✅ Dados extraídos com sucesso!")
        st.dataframe(df, use_container_width=True)

        # Download
        output = io.BytesIO()
        with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
            df.to_excel(writer, index=False, sheet_name='GNRE')
        st.download_button(
            label="📄 Baixar Excel",
            data=output.getvalue(),
            file_name="GNRE_Financeiro.xlsx",
            mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )
