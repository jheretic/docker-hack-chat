FROM lsiobase/alpine:3.7
MAINTAINER J
 
RUN apk update && apk add git make nodejs nodejs-npm
RUN git clone https://github.com/hack-chat/main.git /app \
&& cd /app \
&& git checkout b341644d93e99ea066156986c899a1fee974bb08 \
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
