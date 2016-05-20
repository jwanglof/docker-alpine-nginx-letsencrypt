FROM alpine:3.3

MAINTAINER Johan Wänglöf <jwanglof@gmail.com>

###
# Nginx
###
RUN apk add --update nginx

# Symlink nginx' default logs to std* so Docker Logs can see them
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log


###
# Lets Encrypt
###
RUN export CERTBOT_DEPS="py-pip \
                         build-base \
                         libffi-dev \
                         python-dev \
                         ca-certificates \
                         openssl-dev \
                         linux-headers \
                         dialog \
                         wget" && \
            apk --update add openssl \
                             augeas-libs \
                             ${CERTBOT_DEPS}

RUN pip install --upgrade --no-cache-dir pip virtualenv

RUN mkdir /letsencrypt
RUN mkdir /etc/ssl/botillsammans
WORKDIR /letsencrypt

# Get the certbot so we can use Lets Encrypt
RUN wget https://dl.eff.org/certbot-auto
RUN chmod a+x certbot-auto

# Clean up
RUN apk del ${CERTBOT_DEPS}
RUN rm -rf /var/cache/apk/*

WORKDIR /

COPY ./run.sh /
RUN chmod a+x /run.sh

EXPOSE 80 443

CMD ["sh", "/run.sh"]