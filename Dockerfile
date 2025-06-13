FROM python:3.10

# Instala tesseract e dependências
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    poppler-utils \
    libgl1-mesa-glx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Diretório de trabalho
WORKDIR /app

# Copia e instala dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do projeto
COPY . .

# Expõe a porta padrão
EXPOSE 8501

# Roda a aplicação
CMD ["streamlit", "run", "gnre_pdf_to_excel.py", "--server.port=8501", "--server.address=0.0.0.0"]
