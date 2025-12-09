# Usa a imagem oficial do PySpark/Jupyter como base
FROM jupyter/pyspark-notebook:latest

# Define o usuário 'root' para poder instalar pacotes globalmente
USER root

# Instala o pacote delta-sharing usando pip
RUN pip install delta-sharing

USER 'jovyan'