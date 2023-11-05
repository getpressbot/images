# pressbot images ships with wp-cli, mariadb and php
FROM debian:bookworm-slim as pressbot_base

WORKDIR /pressbot/

ARG WORDPRESS
ARG PHP=5.6

ENV PHP_EXTENSIONS="cli mbstring xml common curl"

COPY scripts/ /scripts/

# -> Sury Repo & Dependencies
RUN apt-get update && \
  apt-get -y install lsb-release ca-certificates curl && \
  curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
  sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
  apt-get update && \
  # -> WP CLI
  curl -Os https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp && \
  # -> Nginx & Database
  apt-get install -y nginx mariadb-server

FROM pressbot_base

RUN apt-get install -y php${PHP} && \
  # -> Extensions
  for ext in ${str}; do \
      apt-get install -y php${PHP}-"$ext"; \
  done && \
  apt-get install -y php${PHP}-fpm # FPM is required


#HEALTHCHECK --start-period=5s --interval=2s --timeout=5s --retries=8 CMD bash /scripts/healthcheck.sh
CMD [ "nginx", "-g", "daemon off;" ]