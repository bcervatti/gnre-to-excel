FROM python:3.10-slim

# Instalar dependências do sistema incluindo o Tesseract
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libgl1-mesa-glx \
    && apt-get clean

# Copiar dependências Python
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copiar os arquivos da aplicação
COPY . /app
WORKDIR /app

# Porta padrão do Streamlit
EXPOSE 8501

# Comando de inicialização
CMD ["streamlit", "run", "gnre_pdf_to_excel.py", "--server.port=8501", "--server.address=0.0.0.0"]
