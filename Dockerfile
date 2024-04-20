FROM swift:5.7.3

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
  && rm -r /var/lib/apt/lists/*

WORKDIR /build
COPY . .

RUN swift package resolve
RUN swift build
