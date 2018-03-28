FROM alpine:3.7

ENV GITEA_VER="v1.4.0"
ENV GOPATH="/opt/git/go"

RUN addgroup git && \
	mkdir -p /opt/git && \
	adduser -h /opt/git -s /bin/bash \
		-D -G git git && \
	chown git:git /opt/git

RUN echo "git:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps go \
		make musl-dev && \
	apk add git bash openssh && \
	go get -d -u code.gitea.io/gitea && \
	cd $GOPATH/src/code.gitea.io/gitea && \
	git checkout tags/$GITEA_VER && \
	PATH=$PATH:$GOPATH/bin \
		make clean generate build -j$(nproc) && \
	apk del --purge deps && \
	rm -rf $GOPATH/src/code.gitea.io/gitea/.git* && \
	rm -rf ~/go/pkg/ && \
	rm -rf $GOPATH/src/code.gitea.io/gitea/vendor && \
	chown git:git -R $GOPATH/*
