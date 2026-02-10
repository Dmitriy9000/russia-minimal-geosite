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
