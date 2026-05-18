# ========== BASE DO CONTAINER ==========
# Usa Debian oldstable como imagem base (versão estável anterior da Debian)
# Debian é leve e estável, ideal para aplicações web
FROM debian:oldstable
# Comentário: oldstable é uma versão congelada que recebe suporte prolongado

# ========== INSTALAÇÃO DE PACOTES ==========
# Actualiza o repositório de pacotes antes de instalar
# && permite múltiplos comandos na mesma camada Docker (mais eficiente)
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    # php8.2-fpm: PHP FastCGI Process Manager versão 8.2
    # FPM é o programa que processa ficheiros PHP
    # Nginx comunica com FPM através de uma socket Unix (não HTTP)
    php8.2-mysql \
    # php8.2-mysql: Extensão PHP para comunicar com bases de dados MySQL/MariaDB
    # Necessária para o WordPress conectar ao MariaDB
    php8.2-curl \
    # php8.2-curl: Extensão para fazer requisições HTTP
    # WordPress usa para comunicar com APIs externas
    php8.2-gd \
    # php8.2-gd: Extensão para processar imagens
    # Necessária para redimensionar e editar imagens no WordPress
    php8.2-mbstring \
    # php8.2-mbstring: Suporte para strings com múltiplos bytes (UTF-8, etc)
    # Necessária para caracteres especiais em nomes de ficheiros, etc
    php8.2-xml \
    # php8.2-xml: Extensão para processar ficheiros XML
    # WordPress usa para feeds RSS, XML-RPC, etc
    php8.2-zip \
    # php8.2-zip: Extensão para trabalhar com ficheiros ZIP
    # Plugin e temas WordPress frequentemente vêm em formato ZIP
    mariadb-client \
    # mariadb-client: Ferramentas para conectar ao MariaDB remotamente
    # Usadas no script para verificar se a base de dados está pronta
    curl \
    # curl: Ferramenta para fazer requisições HTTP
    # Usada para fazer download dos ficheiros do WordPress
    ca-certificates \
    # ca-certificates: Certificados de autoridades certificadoras confiáveis
    # Necessário para validar certificados HTTPS quando se comunica com servidores remotos
    && rm -rf /var/lib/apt/lists/* \
    # Remove package cache para reduzir tamanho da imagem
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    # curl: Faz download do WP-CLI (WordPress Command Line Interface)
    # -fsSL: flags para um download robusto (fail, silent, show errors, location follow)
    # wp-cli.phar é o executável do WP-CLI em formato PHAR (PHP Archive)
    # -o /usr/local/bin/wp: Salva no local padrão de comandos do sistema
    && chmod +x /usr/local/bin/wp
    # chmod +x: Dá permissão de execução ao ficheiro wp-cli

# ========== COPIAR FICHEIRO DE CONFIGURAÇÃO PHP ==========
# Copia o ficheiro de configuração customizado do PHP-FPM
# www.conf: Configuração da pool de processos "www" do PHP-FPM
# Permite ajustar número de processos, limites de memória, timeout, etc
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# ========== COPIAR O SCRIPT DE INICIALIZAÇÃO ==========
# Copia o script run.sh que instala e inicia o WordPress
# tools/run.sh: O script que vimos comentado acima
# /usr/local/bin/run.sh: Destino (localização padrão para scripts do sistema)
COPY tools/run.sh /usr/local/bin/run.sh

# ========== TORNAR O SCRIPT EXECUTÁVEL ==========
# Dá permissão de execução ao script run.sh
# chmod +x: Adiciona permissão de execução
RUN chmod +x /usr/local/bin/run.sh

# ========== DEFINIR DIRECTÓRIO DE TRABALHO ==========
# Define o directório de trabalho padrão para o container
# /var/www/html: Directório padrão onde aplicações web residem em Linux
# Isto faz com que qualquer comando executado no container comece aqui por defeito
WORKDIR /var/www/html

# ========== EXPOSIÇÃO DE PORTAS ==========
# Expõe a porta 9000 (porta padrão do PHP-FPM)
# Nginx vai comunicar com PHP-FPM nesta porta através de uma socket Unix
# (Não é uma porta TCP normal, é uma socket Unix)
EXPOSE 9000

# ========== COMANDO DE INICIALIZAÇÃO ==========
# Define o comando que será executado quando o container iniciar
# CMD marca este como o comando padrão (pode ser substituído no docker run)
# ["/usr/local/bin/run.sh"]: Executa o script que instala e inicia o WordPress/PHP-FPM
CMD ["/usr/local/bin/run.sh"]