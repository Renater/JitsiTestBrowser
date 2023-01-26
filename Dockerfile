FROM debian:stable-slim

RUN apt update && apt-get -y install curl gettext-base\
    && apt-get update\
    && apt-get install -y --install-recommends apache2\
    && apt-get -y install php php-mysql php-mbstring php-gmp composer zip unzip php-zip


RUN mkdir /usr/local/WebRTCTestBrowser
COPY ./scripts /usr/local/WebRTCTestBrowser/scripts
COPY ./src /usr/local/WebRTCTestBrowser/src
COPY ./gen /usr/local/WebRTCTestBrowser/gen
COPY ./docker/webrtctest.conf /usr/local/WebRTCTestBrowser/webrtctest.conf

COPY composer.json /usr/local/WebRTCTestBrowser/composer.json
COPY composer.lock /usr/local/WebRTCTestBrowser/composer.lock

RUN cd /usr/local/WebRTCTestBrowser\
    && composer install -n \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80 443

# redirect apache logs to docker stdout/stderr
RUN ln -sf /proc/1/fd/1 /var/log/apache2/access.log
RUN ln -sf /proc/1/fd/2 /var/log/apache2/error.log

COPY ./docker/entrypoint.sh /var/
RUN chmod +x /var/entrypoint.sh

ENTRYPOINT ["/bin/bash", "/var/entrypoint.sh"]