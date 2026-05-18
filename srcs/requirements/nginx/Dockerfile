# ========== BASE DO CONTAINER ==========
# Usa Debian oldstable como imagem base (versão estável anterior da Debian)
# Debian é leve e tem bom suporte para servidores web
FROM debian:oldstable

# ========== INSTALAÇÃO DE PACOTES ==========
# Actualiza o repositório de pacotes antes de instalar
# && permite múltiplos comandos na mesma camada Docker
RUN apt-get update && apt-get install -y \
    nginx \
    # nginx: O servidor web que vai servir o WordPress
    # É extremamente rápido e eficiente, ideal para produção
    # Nginx funciona como proxy reverso para encaminhar requests ao PHP-FPM
    openssl \
    # openssl: Ferramentas para criar certificados SSL/TLS
    # Usada no script run.sh para gerar o certificado auto-assinado HTTPS
    gettext-base \
    # gettext-base: Contém a ferramenta 'envsubst'
    # Usada no script run.sh para substituir variáveis de ambiente na configuração
    && rm -rf /var/lib/apt/lists/*
    # Removes package cache para reduzir o tamanho da imagem Docker

# ========== COPIAR FICHEIRO DE TEMPLATE DE CONFIGURAÇÃO ==========
# Copia o template de configuração do Nginx
# nginx.conf.template: Ficheiro com ${DOMAIN_NAME} que será substituído depois
# /etc/nginx/templates/nginx.conf.template: Directório padrão de templates Nginx
COPY conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template

# ========== COPIAR O SCRIPT DE INICIALIZAÇÃO ==========
# Copia o script run.sh que vai executar a substituição de variáveis e iniciar Nginx
# tools/run.sh: O script que vimos comentado acima
# /usr/local/bin/run.sh: Destino (localização padrão para scripts do sistema)
COPY tools/run.sh /usr/local/bin/run.sh

# ========== TORNAR O SCRIPT EXECUTÁVEL ==========
# Dá permissão de execução ao script run.sh
# chmod +x: Adiciona permissão de execução
RUN chmod +x /usr/local/bin/run.sh

# ========== EXPOSIÇÃO DE PORTAS ==========
# Expõe a porta 443 (HTTPS/SSL)
# Esta é a porta padrão para tráfego seguro HTTP/2
# Nginx também escuta em HTTP (porta 80) mas a configuração redireciona para HTTPS
EXPOSE 443

# ========== COMANDO DE INICIALIZAÇÃO ==========
# ENTRYPOINT define o programa que sempre executa (não pode ser substituído tão facilmente)
# Isto é preferível a CMD para garantir que o script sempre executa
# ["/usr/local/bin/run.sh"]: Executa o script que configura SSL e inicia o Nginx
ENTRYPOINT ["/usr/local/bin/run.sh"]