---
title: 'Deploying a blog as a static site with Anubis AI scraping protection'
description: A simple and private git server running Charm's soft-serve on fly.io
pubDate: '2025-08-31'
updatedDate: '2025-08-31'
heroImage: /images/anubis.png
---

I recently migrated from GitHub to Codeberg due to recent events around how GitHub is using/pushing AI and their trajectory as a business. [Codeberg](https://codeberg.org) is an alternative focused entirely on free and open-source software, so if you work on FOSS regularly, I'd highly recommend checking out Codeberg.

This article isn't about Codeberg or hosting platforms, but the git hosting platform change forced me to reassess how I host this blog.
I couldn't automatically deploy to Render's static site platform because for some reason, they [do not allow Codeberg](https://community.render.com/t/unable-to-add-codeburg-hosted-git-project/38144) or any less well-known git repos in their source fields. This just feels like a willful move to penalize anyone not supporting big-tech, but maybe they have a legitimate reason I'm not aware of.

Regardless, this encouraged me to rethink my setup and push me to rely less on companies I generally dislike. I've been wanting to use AI scraper blocking tools on my sites for a while, specifically through [Anubis](https://anubis.techaro.lol/), and this felt like a good opportunity.

## The setup

Alright, done with the story — Anubis is a server that typically runs between your reverse proxy and your backend/file server. I really didn't want to deploy multiple running servers for this, so I found [this explicitly "not-for-production" Anubis Caddy module](https://github.com/daegalus/caddy-anubis/) that enables me to run Anubis directly in my Caddy server.

We need a custom Dockerfile to build a Caddy server with modules, but it's pretty straightforward. You set up a `caddy-builder` setup which compiles the module with the Caddy server, and then you copy that into a Caddy runtime server.

```docker
# Build custom Caddy with Anubis plugin
FROM caddy:2-builder AS caddy-builder

RUN xcaddy build \
    --with github.com/daegalus/caddy-anubis

# Runtime image
FROM caddy:2-alpine

# Copy the caddy modules
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# Use a custom Caddyfile
COPY ./Caddyfile /etc/caddy/Caddyfile
```

But since I use [Astro](https://astro.build/) as my static site generator, I needed to add a build step for that as well.

```docker
FROM node:24-alpine AS astro-builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build
```

The final runtime image step looks like this:

```docker
FROM caddy:2-alpine

# Copy the caddy modules
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# Copy the built site
COPY --from=astro-builder /app/dist /usr/share/caddy
COPY ./Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
```

With a basic setup, it wasn't working for me with Anubis. I was getting a mis-configuration error related to Client IP. The next step was flushing out the `Caddyfile` to both serve the site as intended, and forward the user's IP address to the Anubis module.


```hcl # (actually a caddyfile, but hcl is pretty close)
# this is the final Caddyfile, including things that are specific to the deployment to Fly.io and reducing logging
{
	# disable HTTPS because it's going to be handled by fly.io
	auto_https off
	servers {
		# sets fly proxy as trusted proxy
		trusted_proxies static 172.16.0.0/16
		client_ip_headers X-Forwarded-For Fly-Client-IP
	}
	log {
		level INFO
		exclude http.handlers.anubis.anubis
	}
}

:8080 {
	# required for anubis to work
	request_header +X-Real-IP {client_ip}

	handle /health {
		respond "OK" 200
	}

	handle {
		# Enable Anubis anti-AI/scraper protection
		anubis

		# static file server
		root * /usr/share/caddy
		file_server
	}
}
```

This gave me a setup that worked locally, through the following instructions:

```sh
# build the image locally
docker build -t bonkydev .

# run the docker image while mapping to port 8080
docker run -it --rm -p 8080:8080 bonkydev

# then visiting localhost:8080
```

However, I was getting errors on Fly.io no matter what I did. Specifically, a `PR_END_OF_FILE_ERROR` that meant precious little to me. After a lot of trial and error, I confirmed that the error was due to the SSL setup and some interplay with the Fly domain and the Caddy server.

Check out the broken site yourself here: https://bianchi-dev.fly.dev/

I ended up disabling the `force_https` settings in the `fly.toml` just to test stuff out. It seemed that `http` worked just fine, but `https` didn't. And I still haven't figured out why!

I set up my custom domain for the site, and all was good again 🤷. I did see a lot of Fly forum posts talking about similar things, so perhaps they do something funky with their preview domains that causes problems when using a web server that also typically serves it's own TLS.

Anyhow, at the end of the day, we have a blog site deployed to Fly.io with Anubis providing a Proof-of-work challenge for all visitors 🎉!

Feel free to copy the setup, all documented in this repo here:
https://codeberg.org/bianchidotdev/bianchi.dev
