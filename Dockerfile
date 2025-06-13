FROM ubuntu:22.04

# Instala Python + Tesseract + dependências
RUN apt-get update && \
    apt-get install -y python3 python3-pip tesseract-ocr libgl1-mesa-glx poppler-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia requirements e instala
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copia código da aplicação
COPY . .

# Expõe a porta do Streamlit
EXPOSE 8501

# Comando de inicialização
CMD ["streamlit", "run", "gnre_pdf_to_excel.py", "--server.port=8501", "--server.address=0.0.0.0"]
