# bianchi.dev

![enbyware](https://pride-badges.pony.workers.dev/static/v1?label=enbyware&labelColor=%23555&stripeWidth=8&stripeColors=FCF434%2CFFFFFF%2C9C59D1%2C2C2C2C)

Created with [astro](https://astro.build/).

## Development

This project's dependencies are managed by [mise](https://mise.jdx.dev/).

```sh
mise install
```

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |

## Deployment

This site is protected by [Anubis](https://anubis.techaro.lol/) AI scraping protection.
It's deployed with a [Caddy](https://caddyserver.com/) server using Anubis as a module on fly.io.

Tasks for working with Caddy/Anubis/Fly:

```sh
# format caddy config
mise run caddy:fmt

# validate caddy config
mise run caddy:lint

# run full caddy/anubis setup locally
mise run docker:dev

# deploy to fly
mise run deploy

# get fly logs
mise run logs
```
