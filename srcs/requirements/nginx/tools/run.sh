#!/bin/bash
# Shebang: Indica que este é um script bash

set -e
# 'set -e' faz o script parar se qualquer comando falhar
# Evita que o Nginx inicie com configurações quebradas

# ========== CRIAÇÃO DO DIRECTÓRIO SSL ==========
# Cria o directório onde os certificados SSL/TLS serão armazenados
# -p: cria o directório e qualquer directório pai necessário
# SSL é necessário para servir HTTPS em vez de HTTP
mkdir -p /etc/nginx/ssl

# ========== GERAÇÃO DO CERTIFICADO SSL (se não existir) ==========
# Verifica se o certificado já existe (em execuções subsequentes)
if [ ! -f "/etc/nginx/ssl/${DOMAIN_NAME}.crt" ]; then
    # Gera um certificado auto-assinado válido por 365 dias
    # Este não é um certificado confiável (auto-assinado), mas serve para desenvolvimento
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        # -req: Cria um certificado directamente (sem CSR intermédio)
        # -x509: Cria certificado X.509 (padrão SSL/TLS)
        # -nodes: Não encripta a chave privada (não pede password)
        # -days 365: O certificado é válido por 365 dias
        # -newkey rsa:2048: Gera uma nova chave RSA com 2048 bits
        -keyout "/etc/nginx/ssl/${DOMAIN_NAME}.key" \
        # -keyout: Define onde guardar a chave privada
        # Usamos ${DOMAIN_NAME} que vem da variável de ambiente Docker
        -out "/etc/nginx/ssl/${DOMAIN_NAME}.crt" \
        # -out: Define onde guardar o certificado público
        -subj "/C=AO/ST=Luanda/L=Luanda/O=42/CN=${DOMAIN_NAME}"
        # -subj: Define o assunto do certificado sem interacção
        # C=País (AO=Angola), ST=Estado, L=Localidade, O=Organização, CN=Nome Comum (domínio)
fi

# ========== SUBSTITUIÇÃO DE VARIÁVEIS NA CONFIGURAÇÃO ==========
# Substitui ${DOMAIN_NAME} no template de configuração
# envsubst: ferramenta que substitui variáveis de ambiente ($VARIÁVEL ou ${VARIÁVEL})
# '$DOMAIN_NAME': especifica qual a variável a substituir (sintaxe de shell)
envsubst '$DOMAIN_NAME' \
    # < : Redireciona o arquivo template como entrada
    < /etc/nginx/templates/nginx.conf.template \
    # > : Redireciona a saída para o arquivo de configuração final
    > /etc/nginx/conf.d/default.conf

# ========== EXECUÇÃO DO NGINX ==========
# Inicia o Nginx em modo foreground (não daemoniza)
# exec substitui o processo actual do script - importante para Docker receber sinais SIGTERM
# -g "daemon off;": Informa ao Nginx que é o processo principal (não usar modo daemon)
# Isto permite que o Docker possa parar o container com SIGTERM e o Nginx responda correctamente
exec nginx -g "daemon off;"