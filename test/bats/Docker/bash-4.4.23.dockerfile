FROM alpine/git:v2.30.0 as bats
ARG BATS_VERSION
  RUN git clone https://github.com/bats-core/bats-core.git /root/bats-core \
        && cd /root/bats-core \
        && git checkout "${BATS_VERSION}"

FROM bash:4.4.23 as tini
  ENV TINI_VERSION v0.19.0
  RUN wget https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static -O /tini
  RUN chmod +x /tini

FROM bash:4.4.23
  # Bats
  RUN apk add --update parallel ncurses git \
        && mkdir -p ~/.parallel \
        && touch ~/.parallel/will-cite
  COPY --from=bats /root/bats-core /root/bats-core
  RUN /root/bats-core/install.sh "/usr/local"
  # Clean
  RUN rm -rf /var/cache/apk/*
  COPY --from=tini /tini /tini
  WORKDIR /code/
  ENTRYPOINT ["/tini", "--", "bash", "bats"]
