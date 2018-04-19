# docker-hacker-chat

Docker container for https://github.com/hack-chat/main


## Usage

```
docker run -d --name hchat \
 -p 8080:8080 \
 -p 6060:6060 \
 -e WSPROTOCOL="ws://" \
 -e WSPORT="6060" \
 -e WSBASEURL="" \
 -e ADMIN_NAME="boop" \
 -e PASSWORD="pass" \
 -e SALT="2dSg4kS" \
 mcgriddle/hacker-chat:latest
```

## Parameters

* `-p 8080:8080` - the port the server listens on
* `-p 6060:6060` - the port the client listens on
* `-e WSPROTOCOL` - websocket protocol that the client will use to contact the server. "ws://" or "wss://"
* `-e WSPORT` - websocket port that the client will use to contact the server. cannot be blank.
* `-e ADMIN_NAME` - cannot be blank
* `-e PASSWORD` - bannot be blank
* `-e SALT` - cannot be blank


## Examples

### Just Run It

Access it on `0.0.0.0:8080`

```
docker run -d --name hchat \
 -p 8080:8080 \
 -p 6060:6060 \
 -e WSPROTOCOL="ws://" \
 -e WSPORT="6060" \
 -e WSBASEURL="" \
 -e ADMIN_NAME="boop" \
 -e PASSWORD="pass" \
 -e SALT="2dSg4kS" \
 mcgriddle/hacker-chat:latest
```


### Encryption

If you want to use ssl, you'll need nginx or similar sitting in front of it and proxying to hacker-chat.
Say you wanted to access the client at https://<some_domain>/hacker-chat-thingy with an encrypted websocket at https://<some_domain>/bleepblippitybleepbloop .

```
docker run -d --name hchat \
 -p 5050:8080 \
 -p 6060:6060 \
 -e WSPROTOCOL="wss://" \
 -e WSPORT="443" \
 -e WSBASEURL="/bleepblippitybleepbloop" \
 -e ADMIN_NAME="boop" \
 -e PASSWORD="pass" \
 -e SALT="2dSg4kS" \
 mcgriddle/hacker-chat:latest
```


Nginx would look something like this
```

upstream websocket {
	server <ip_of_hchat>:6060;
}

server {
	listen 443 ssl default_server;
	
	#other cert stuff and configurations

	location /hacker-chat-thingy/ {
  		proxy_set_header Host $host:$server_port;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto https;
		proxy_redirect  http://  $scheme://;
		proxy_http_version 1.1;
		proxy_set_header Connection "";
		proxy_cache_bypass $cookie_session;
		proxy_no_cache $cookie_session;
		proxy_buffers 32 4k;

		rewrite /reqs(.*) /$1  break;
		proxy_pass http://<ip_of_hchat>:5050/;
  }
 
	location /bleepblippitybleepbloop {
		rewrite ^/bleepblippitybleepbloop / break;
		proxy_pass http://websocket;
		proxy_http_version 1.1;
		proxy_set_header Upgrade websocket;
		proxy_set_header Connection upgrade;
	}

}
```




