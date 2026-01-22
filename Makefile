.PHONY: all
all: build

# Dockerfile.quick installs Tor using pre-built binaries
.PHONY: quick
quick:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.8.21 \
		--tag ghcr.io/rinsecode/tor:0.4.8.21 \
		--tag ghcr.io/rinsecode/tor:latest \
		--squash \
		-f Dockerfile.quick \
		.

# Dockerfile builds Tor from source
.PHONY: build
build:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.8.21 \
		--tag ghcr.io/rinsecode/tor:0.4.8.21 \
		--tag ghcr.io/rinsecode/tor:latest \
		--squash \
		-f Dockerfile \
		.
