# Russia Minimal Geosite

A builder for a minimal `geosite.dat` routing database for Russian users. It downloads the upstream [russia-blocked-geosite](https://github.com/runetfreedom/russia-blocked-geosite) dataset, extracts only the categories you need, enriches them with extra hand-curated domains, and repackages everything into a compact binary ready for V2Ray-compatible clients.

The resulting `geosite.dat` is committed to this repository so you can consume it directly without running the build pipeline yourself.

## Use case

Russian users who route internet traffic through a proxy need routing rules that:

- Send **Russian services** (Yandex, VK, Tinkoff, …) **directly** — avoids latency and geo-blocks on domestic services
- Send **blocked or restricted sites** through the proxy
- **Block** ad networks

This project provides both the `geosite.dat` database and a ready-made `r-domestic.json` config for clients that support this format (e.g. [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid)).

## Categories included

| Tag | Routing | Description |
|-----|---------|-------------|
| `ru-available-only-inside` | Direct | Russian services best accessed without a proxy (Yandex, VK, Tinkoff, etc.) |
| `category-ru` | Direct | Russian-language / Russia-registered domains |
| `apple` | Direct | Apple services |
| `microsoft` | Direct | Microsoft services |
| `steam` | Direct | Steam |
| `category-games` | Direct | Game platforms |
| `reddit` | Direct | Reddit |
| `ru-blocked` | Proxy | Sites blocked in Russia |
| `category-ai-!cn` | Proxy | AI services (excluding China) |
| `category-ai-chat-!cn` | Proxy | AI chat services (excluding China) |
| `category-cryptocurrency` | Proxy | Crypto exchanges and tools |
| `cursor` | Proxy | Cursor IDE |
| `forza` | Proxy | Forza Horizon |
| `piratebay` | Proxy | The Pirate Bay |
| `roblox` | Proxy | Roblox |
| `rutracker` | Proxy | RuTracker |
| `category-ads-all` | Block | Ad networks |

Custom domains in `enrich/ru-available-only-inside` and `enrich/ru-blocked` are merged into the corresponding categories at build time.

## Prerequisites

This project requires Go and two build tools.

### Install Go

Download and install Go from [https://golang.org/dl/](https://golang.org/dl/). Make sure Go is added to your PATH.

### Install domain-list-community

Clone and build the `domain-list-community` tool:

```bash
git clone https://github.com/v2fly/domain-list-community.git
cd domain-list-community
go build -o domain-list-community ./
```

Place the resulting binary in your PATH or in the repository root.

### Install v2dat

Clone and build the `v2dat` tool:

```bash
git clone https://github.com/urlesistiana/v2dat.git
cd v2dat
go build -o v2dat ./
```

Place the resulting binary in your PATH or in the repository root.

## Build

Run the full pipeline from the repository root:

```bash
./minimize.sh
```

This downloads the latest `geosite.dat` from upstream, extracts the needed sections into `./categories`, enriches them from `./enrich`, adds the `domain:` prefix where needed, and rebuilds a minimized `geosite.dat` in the repository root.

### Run steps individually

```bash
# Extract sections from the downloaded geosite.dat
./v2dat unpack geosite -o extracted geosite.dat

# Enrich category files with extra domains
./append-enrich-to-categories.sh [enrich_dir] [categories_dir]

# Add domain: prefix
./add-domain-prefix.sh ./categories

# Rebuild the .dat file
./domain-list-community --datapath=./categories
```

## Customise

To add your own domains:

- **Direct** — add them to `enrich/ru-available-only-inside`, one domain per line
- **Proxy** — add them to `enrich/ru-blocked`, one domain per line

Lines are automatically deduplicated and merged with the upstream category at build time. You can use any prefix supported by `domain-list-community`, for example `full:example.com` for an exact match.

## Using the config

`r-domestic.json` is a ready-made routing config for clients that support this format. The `Geositeurl` field points to the `geosite.dat` in this repository:

```json
"Geositeurl": "https://raw.githubusercontent.com/Dmitriy9000/russia-minimal-geosite/main/geosite.dat"
```

Import it into your client (e.g. NekoBox → Profiles → Import) and the client will fetch the latest `geosite.dat` automatically.

## License

MIT — see [LICENSE](LICENSE).
