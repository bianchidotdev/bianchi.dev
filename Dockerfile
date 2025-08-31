# Multi-stage build for Astro + Custom Caddy with Anubis

# Build custom Caddy with Anubis plugin
# FROM caddy:2-builder AS caddy-builder

# RUN xcaddy build \
#     --with github.com/daegalus/caddy-anubis


# Build the Astro site
FROM node:24-alpine AS astro-builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# Runtime image
FROM caddy:2-alpine

# Copy the caddy modules
# COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# Copy the built site
COPY --from=astro-builder /app/dist /usr/share/caddy
COPY ./Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080
