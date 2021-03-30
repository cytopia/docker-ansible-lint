FROM alpine:3.13 as builder

RUN set -eux \
	&& apk add --no-cache \
		bc \
		cargo \
		gcc \
		libffi-dev \
		musl-dev \
		openssl-dev \
		py3-pip \
		python3 \
		python3-dev \
		rust

ARG VERSION
RUN set -eux \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile ansible-lint; \
	else \
		pip3 install --no-cache-dir --no-compile "ansible-lint>=${VERSION},<$(echo "${VERSION}+1" | bc)"; \
	fi \
	\
	&& pip3 install ansible \
	\
	&& ansible-lint --version | head -1 | grep -E 'ansible-lint[[:space:]]+[0-9]+' \
	\
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


FROM alpine:3.13 as production
ARG VERSION
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#LABEL "org.opencontainers.image.created"=""
#LABEL "org.opencontainers.image.version"=""
#LABEL "org.opencontainers.image.revision"=""
LABEL "maintainer"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.authors"="cytopia <cytopia@everythingcli.org>"
LABEL "org.opencontainers.image.vendor"="cytopia"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.url"="https://github.com/cytopia/docker-ansible-lint"
LABEL "org.opencontainers.image.documentation"="https://github.com/cytopia/docker-ansible-lint"
LABEL "org.opencontainers.image.source"="https://github.com/cytopia/docker-ansible-lint"
LABEL "org.opencontainers.image.ref.name"="ansible-lint ${VERSION}"
LABEL "org.opencontainers.image.title"="ansible-lint ${VERSION}"
LABEL "org.opencontainers.image.description"="ansible-lint ${VERSION}"

RUN set -eux \
	&& apk add --no-cache \
		bash \
		git \
		python3 \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-galaxy \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-playbook \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/ansible-lint /usr/bin/ansible-lint
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection

RUN set -eux \
	&& ansible-lint --version | head -1 | grep -E 'ansible-lint[[:space:]]+[0-9]+' \
	\
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

WORKDIR /data
ENTRYPOINT ["ansible-lint"]
CMD ["--version"]
