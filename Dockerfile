FROM debian:bullseye-slim

# Atualiza pacotes e instala tesseract + libs essenciais
RUN apt-get update && \
    apt-get install -y \
    tesseract-ocr \
    python3 \
    python3-pip \
    libgl1-mesa-glx \
    && apt-get clean

# Define caminho do Tesseract como variável de ambiente
ENV TESSERACT_CMD=/usr/bin/tesseract

# Define diretório de trabalho
WORKDIR /app

# Copia dependências
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copia o app
COPY . .

# Porta Streamlit
EXPOSE 8501

# Comando para iniciar o app
CMD ["streamlit", "run", "gnre_pdf_to_excel.py", "--server.port=8501", "--server.address=0.0.0.0"]
