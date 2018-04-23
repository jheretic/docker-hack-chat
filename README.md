# docker-hack-chat

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
 mcgriddle/hack-chat:latest
```

## Parameters

* `-p 8080:8080` - the port the server listens on
* `-p 6060:6060` - the port the client listens on
* `-e WSPROTOCOL` - websocket protocol that the client will use to contact the server. "ws://" or "wss://"
* `-e WSPORT` - websocket port that the client will use to contact the server. cannot be blank.
* `-e WSBASEURL` - base url used for reverse proxy setups. needs to have leading forward slash.
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
 mcgriddle/hack-chat:latest
```


### Encryption

If you want to use ssl, you'll need nginx or similar sitting in front of it and proxying to hack-chat.
Say you wanted to access the client at `https://<some_domain>/hacker-chat-thingy` with an encrypted websocket at `https://<some_domain>/bleepblippitybleepbloop` .


Purposely not specifying the hacker-chat ports here as nginx link to it.
```
docker run -d --name hchat \
 -e WSPROTOCOL="wss://" \
 -e WSPORT="443" \
 -e WSBASEURL="/bleepblippitybleepbloop" \
 -e ADMIN_NAME="boop" \
 -e PASSWORD="pass" \
 -e SALT="2dSg4kS" \
 mcgriddle/hack-chat:latest
```

Create nginx directory so you can easily modify the conf file. Then you'll want to have some user own that directory.
```
sudo mkdir -p /opt/docker-web
sudo groupadd --gid 1002 dockeruser
sudo adduser --no-create-home --system --disabled-login --gid 1002 --uid 121 dockeruser
sudo chown dockeruser:dockeruser /opt/docker-web
```

Start an nginx container. This particular one has self-signed certs already setup. The PUID and PGID need to match whatever group and user was created above, or another user.
```
sudo docker run --name web -p 443:443 --link hchat:hchat -v /opt/docker-web:/config -e PUID=121 -e PGID=1002 -e DH_SIZE=2048 -e TZ=America/New_York mcgriddle/nginx-self-cert
```

Kill the container when you see 'Server Ready'

Now modify the nginx conf in `/opt/docker-web/nginx/site-confs/default` to look like this

```

upstream websocket {
	server hchat:6060;
}

# main server block
server {
	listen 443 ssl default_server;

	root /config/www;
	index index.html index.htm index.php;

	server_name _;

	# all ssl related config moved to ssl.conf
	include /config/nginx/ssl.conf;

	client_max_body_size 0;

	location / {
		try_files $uri $uri/ /index.html /index.php?$args =404;
	}

	location /hacker-chat-thingy/ {
	        # https://github.com/McGriddle/docker-nginx-self-cert/blob/master/root/defaults/proxy.conf
		include /config/nginx/proxy.conf;
		rewrite /reqs(.*) /$1  break;
		proxy_pass http://hchat:8080/;
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

`sudo docker start web`

You should be able to access hchat now on `https://<your_ip>/hacker-chat-thingy/`
![hack-chat-main](https://user-images.githubusercontent.com/5432956/39061496-79851e9a-4492-11e8-9b53-350aa6299058.png)
![hack-chat](https://user-images.githubusercontent.com/5432956/39061455-4d1f1040-4492-11e8-8652-6df0ae70c3c7.png)


### Sources

* [docker alpine base by linuxserver.io](https://github.com/linuxserver/docker-baseimage-alpine)
* [Lets Encrypt docker container by linuxserver.io](https://github.com/linuxserver/docker-letsencrypt)
* [self signed cert container](https://github.com/MarvAmBass/docker-nginx-ssl-secure)
* [my docker child of the two containers above](https://github.com/McGriddle/docker-nginx-self-cert)
* [s6 overlay](https://github.com/just-containers/s6-overlay)
