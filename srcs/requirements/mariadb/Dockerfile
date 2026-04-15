FROM debian:oldstable

RUN apt update && apt install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.conf
COPY tools/run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/run.sh

EXPOSE 3306

CMD ["/usr/local/bin/run.sh"]