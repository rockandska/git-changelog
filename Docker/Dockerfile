FROM alpine/git:v2.30.2

RUN apk --update add bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

COPY git-changelog /usr/bin

ENTRYPOINT [ "git", "changelog" ]
