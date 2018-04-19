FROM lsiobase/alpine:3.7
MAINTAINER J
 
ENV ADMIN_NAME adminn
ENV PASSWORD passwordadmin
ENV SALT j3N2GDa
 
RUN apk update && apk add git make nodejs nodejs-npm supervisor
RUN git clone https://github.com/hack-chat/main.git /app \
&& cd /app \
&& git checkout 4c1485ce2c1d2d985e9733214b211a4f40c0c375 \
&& cd server \
&& npm install \
&& mkdir -p config \
&& ln -sT main.js server.js \
&& cd ../client \
&& npm install -g less jade http-server \
&& apk del git make nodejs-npm \
&& rm -rf /var/cache/apk/* \
&& rm -rf /root \
&& mkdir -p / /root \
&& mkdir -p /var/log/client \
&& chown -R nobody:nobody /var/log/client \
&& mkdir -p /var/log/server \
&& chown -R nobody:nobody /var/log/server

COPY root/ /
COPY config.json /app/server/config/config.json
 
EXPOSE 8080 6060
