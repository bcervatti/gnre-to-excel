FROM python:3.10-slim

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libgl1-mesa-glx \
    poppler-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de dependência
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código
COPY . .

# Expõe a porta padrão do Streamlit
EXPOSE 8501

# Comando de inicialização
CMD ["streamlit", "run", "gnre_pdf_to_excel.py", "--server.port=8501", "--server.address=0.0.0.0"]
