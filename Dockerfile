FROM alpine:latest as builder

RUN set -x \
	&& apk add --no-cache \
		gcc \
		libffi-dev \
		musl-dev \
		openssl-dev \
		python3 \
		python3-dev

ARG VERSION=latest
RUN set -x \
	&& if [ "${VERSION}" = "latest" ]; then \
		pip3 install ansible-lint; \
	else \
		pip3 install ansible-lint==${VERSION}; \
	fi \
	&& ( find /usr/lib/python* -name '__pycache__' -exec rm -rf {} \; || true ) \
	&& ( find /usr/lib/python* -name '*.pyc' -exec rm -rf {} \; || true )


FROM alpine:latest as production
RUN apk add --no-cache python3
COPY --from=builder /usr/lib/python3.6/ /usr/lib/python3.6/
COPY --from=builder /usr/bin/ansible-lint /usr/bin/ansible-lint
WORKDIR /data
ENTRYPOINT ["ansible-lint"]
CMD ["--help"]
