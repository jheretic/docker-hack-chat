# docker-hacker-chat

Docker container for https://github.com/hack-chat/main



```
docker run -d --name dockerhchat \
 -p 4545:8080 \
 -p 2020:6060 \
 -e WSPROTOCOL="ws://" \
 -e WSPORT="2020" \
 -e WSBASEURL="" \
 -e ADMIN_NAME="boop" \
 -e PASSWORD="pass" \
 -e SALT="2dSg4kS" \
 mcgriddle/hacker-chat:latest
```




