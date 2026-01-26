# tor-docker

[![Build multiarch image - latest](https://github.com/RinseCode/tor-docker/actions/workflows/main.yml/badge.svg)](https://github.com/RinseCode/tor-docker/actions/workflows/main.yml)
[![Build multiarch image - tag](https://github.com/RinseCode/tor-docker/actions/workflows/main-tag.yml/badge.svg)](https://github.com/RinseCode/tor-docker/actions/workflows/main-tag.yml)

`Tor` daemon multiarch container.
All depedencie updates are automated.
So if a new tor version is released the docker image will be updated and released.

Additional transport plugins included in the image:

- `lyrebird`

Tested architectures:

- `amd64`
- `arm`
- `arm64`

Source code:

- https://gitlab.torproject.org/tpo/core/tor
- https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird

Downloads:

- https://www.torproject.org/download/tor

Used by:

- [RinseCode/tor-controller](https://github.com/RinseCode/tor-controller)

## Tor

Tor is an anonymity network that provides:

- privacy
- enhanced tamper proofing
- freedom from network surveillance
- NAT traversal

## How to

## Standard build

Builds Tor from source. Method used to create releases in this repo.

```bash
docker buildx build \
    --platform=linux/amd64,linux/arm,linux/arm64 \
    --build-arg TOR_VERSION=0.4.8.21 \
    --tag ghcr.io/rinsecode/tor:0.4.8.21 \
    --tag ghcr.io/rinsecode/tor:latest \
    --squash \
    -f Dockerfile.quick \
    .
```

## Quick build

Installs pre-built Tor from Alpine's repositories. Useful for testing/troubleshooting.

WARNING: some Tor features might be missing, depending on the [Alpine community build setup](https://github.com/alpinelinux/aports/tree/master/community/tor)

```bash
docker buildx build \
    --platform=linux/amd64,linux/arm,linux/arm64 \
    --build-arg TOR_VERSION=0.4.8.21 \
    --tag ghcr.io/rinsecode/tor:0.4.8.21 \
    --tag ghcr.io/rinsecode/tor:latest \
    --squash \
    -f Dockerfile \
    .
```

## Usage

```shell
docker pull ghcr.io/rinsecode/tor:0.4.8.21
```
