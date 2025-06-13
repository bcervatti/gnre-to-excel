#!/bin/bash

# Instalar tesseract-ocr
apt-get update && apt-get install -y tesseract-ocr

# Iniciar o Streamlit
streamlit run gnre_pdf_to_excel.py --server.port=$PORT --server.address=0.0.0.0
