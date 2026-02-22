```markdown
## Prerequisites

This project requires Go and two build tools. Follow the instructions below to set up your environment.

### Install Go

Download and install Go from [https://golang.org/dl/](https://golang.org/dl/). Make sure Go is added to your PATH.

### Install domain-list-community

Clone and build the domain-list-community tool:

```bash
git clone https://github.com/v2fly/domain-list-community.git
cd domain-list-community
go build -o domain-list-community ./
```

Make sure the resulting binary is in your PATH or note its location for use in build commands.

### Install v2dat

Clone and build the v2dat tool:

```bash
git clone https://github.com/urlesistiana/v2dat.git
cd v2dat
go build -o v2dat ./
```

Make sure the resulting binary is in your PATH or note its location for use in build commands.

```

**Using Minimize Script**

- **Purpose:** Runs the full pipeline to download, extract, enrich, prefix and rebuild a minimized `geosite.dat` containing only the Russian-related sections used by this project.
- **Prerequisites:** Ensure the tools listed above are installed and available in your `PATH`: `v2dat`, `domain-list-community`, and `curl`. The repository scripts `append-enrich-to-categories.sh` and `add-domain-prefix.sh` must be executable.
- **Run:** From the repository root run:

```bash
./minimize.sh
```

- **What it does:** `minimize.sh` downloads the latest `geosite.dat`, extracts only the sections this project needs into `./categories`, enriches those category files from `./enrich`, adds the `domain:` prefix where needed, and rebuilds a minimized `geosite.dat` in the repository root.
- **Output:** `geosite.dat` produced in the repo root (the script renames `dlc.dat` to `geosite.dat`).
- **Customize / Run steps individually:** If you prefer to run parts manually:

  - Extract: `./v2dat unpack geosite -o extracted geosite.dat`
  - Enrich: `./append-enrich-to-categories.sh [enrich_dir] [categories_dir]`
  - Add prefix: `./add-domain-prefix.sh ./categories`
  - Build: `./domain-list-community --datapath=./categories`

If you want `append-enrich-to-categories.sh` or `add-domain-prefix.sh` to target different directories, pass them as positional arguments (see the scripts' usage comments).
