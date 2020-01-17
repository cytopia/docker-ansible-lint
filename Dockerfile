FROM alpine:3.9 as builder

RUN set -eux \
	&& apk add --no-cache \
		bc \
		gcc \
		libffi-dev \
		musl-dev \
		openssl-dev \
		python3 \
		python3-dev \
		bash

ARG VERSION=latest
RUN set -eux \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile ansible-lint; \
	else \
		pip3 install --no-cache-dir --no-compile "ansible-lint==${VERSION}>=${VERSION},<$(echo "${VERSION}+0.1" | bc)"; \
	fi \
	\
	&& ansible-lint --version | head -1 | grep -E 'ansible-lint[[:space:]]+[0-9]+' \
	\
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.9 as production
LABEL \
	maintainer="cytopia <cytopia@everythingcli.org>" \
	repo="https://github.com/cytopia/docker-ansible-lint"
RUN set -eux \
	&& apk add --no-cache python3 \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf
COPY --from=builder /usr/lib/python3.6/site-packages/ /usr/lib/python3.6/site-packages/
COPY --from=builder /usr/bin/ansible-lint /usr/bin/ansible-lint
WORKDIR /data
ENTRYPOINT ["ansible-lint"]
CMD ["--version"]
