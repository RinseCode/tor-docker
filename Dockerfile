# Tor builder
FROM docker.io/library/alpine:3.23.3 AS tor-builder

ARG TOR_VERSION=0.4.8.22
RUN apk add --update --no-cache \
    git build-base automake autoconf make \
    build-base openssl-dev libevent-dev zlib-dev \
    xz-dev zstd-dev

# Install Tor from source
WORKDIR /tor
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git --depth 1 --branch tor-"${TOR_VERSION}" /tor && \
      ./autogen.sh

# Notes:
# - --enable-gpl is required to compile PoW anti-DoS: https://community.torproject.org/onion-services/advanced/dos/
# --enable-static-tor
RUN ./configure \
    --disable-asciidoc \
    --disable-manpage \
    --disable-html-manual \
    --enable-gpl && \
      make && \
      make install

# Build the lyrebird binary (cross-compiling)
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS lyrebird-builder
ARG LYREBIRD_VERSION="0.8.1"

WORKDIR /lyrebird
RUN apk add --update --no-cache git && \
      git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git --depth 1 --branch lyrebird-"${LYREBIRD_VERSION}" /lyrebird

ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-X main.lyrebirdVersion=$(VERSION)" ./cmd/lyrebird

# Tor runner
FROM docker.io/library/alpine:3.23.3 AS runner

LABEL org.opencontainers.image.source="https://github.com/rinsecode/tor-docker"

WORKDIR /app
ENV HOME=/app

RUN apk add --update --no-cache \
      libevent \
      xz-libs \
      zstd-libs && \
    chmod -R g+w /app /run

# install tor
RUN mkdir -p /usr/local/bin /usr/local/etc/tor /usr/local/share/tor
COPY --from=tor-builder /usr/local/bin/tor /usr/local/bin/tor
COPY --from=tor-builder /tor/src/tools/tor-resolve /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-print-ed-signing-cert /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-gencert /usr/local/bin/.
COPY --from=tor-builder /tor/contrib/client-tools/torify /usr/local/bin/.
COPY --from=tor-builder /tor/src/config/torrc.sample /usr/local/etc/tor/.
COPY --from=tor-builder /tor/src/config/geoip /usr/local/share/tor/.
COPY --from=tor-builder /tor/src/config/geoip6 /usr/local/share/tor/.

# install transports
COPY --from=lyrebird-builder /lyrebird/lyrebird /usr/local/bin/.

# create service dir (we don't define VOLUME because https://github.com/docker-library/mysql/issues/255
# and other issues when running as non-root user)
RUN mkdir -p /run/tor/service && chown -R 1001 /run/tor

# change to non root
USER 1001

ENTRYPOINT ["/usr/local/bin/tor"]
