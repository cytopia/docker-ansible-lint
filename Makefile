ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: lint build rebuild test tag login push pull-base-image enter

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

DIR = .
FILE = Dockerfile
IMAGE = cytopia/ansible-lint
VERSION = latest
TAG = latest
NO_CACHE =


# --------------------------------------------------------------------------------------------------
# Default Target
# --------------------------------------------------------------------------------------------------
help:
	@echo "lint                      Lint project files and repository"
	@echo "build   [VERSION=...]     Build bandit docker image"
	@echo "rebuild [VERSION=...]     Build bandit docker image without cache"
	@echo "test    [VERSION=...]     Test built bandit docker image"
	@echo "tag TAG=...               Retag Docker image"
	@echo "login USER=... PASS=...   Login to Docker hub"
	@echo "push [TAG=...]            Push Docker image to Docker hub"


# --------------------------------------------------------------------------------------------------
# Lint Targets
# --------------------------------------------------------------------------------------------------
lint: _lint-files
lint: _lint-workflow

.PHONY: _lint-workflow
_lint-workflow:
	@echo "################################################################################"
	@echo "# Lint Workflow"
	@echo "################################################################################"
	@\
	GIT_CURR_MAJOR="$$( git tag | sort -V | tail -1 | sed 's|\.[0-9]*$$||g' )"; \
	GIT_CURR_MINOR="$$( git tag | sort -V | tail -1 | sed 's|^[0-9]*\.||g' )"; \
	GIT_NEXT_TAG="$${GIT_CURR_MAJOR}.$$(( GIT_CURR_MINOR + 1 ))"; \
	AVAILABLE_REFS="$$( \
		grep 'refs:' -A 100 .github/workflows/nightly.yml \
		| grep 'steps:' -B 100 \
		| grep -E '[[:space:]]+\-' \
		| sed 's/.*\s//g' \
		| sed "s/'//g" \
		| sed 's/"//g' \
		| grep -v master || true \
	)"; \
	if [ -n "$${AVAILABLE_REFS}" ]; then \
		if ! grep 'refs:' -A 100 .github/workflows/nightly.yml \
			| grep  "          - '$${GIT_NEXT_TAG}'" >/dev/null; then \
			echo "[ERR] New Tag required in .github/workflows/nightly.yml: $${GIT_NEXT_TAG}"; \
				exit 1; \
			else \
			echo "[OK] Git Tag present in .github/workflows/nightly.yml: $${GIT_NEXT_TAG}"; \
		fi \
	else \
		echo "[OK] No Tags defined at all in .github/workflows/nightly.yml"; \
	fi
	@echo

.PHONY: lint-files
_lint-files:
	@echo "################################################################################"
	@echo "# Lint Files"
	@echo "################################################################################"
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-cr --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-crlf --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-trailing-single-newline --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-trailing-space --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-utf8 --text --ignore '.git/,.github/,tests/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint file-utf8-bom --text --ignore '.git/,.github/,tests/' --path .


# --------------------------------------------------------------------------------------------------
# Build Targets
# --------------------------------------------------------------------------------------------------
build:
	docker build $(NO_CACHE) \
		--build-arg VERSION=$(VERSION) \
		--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
		--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
		--label "org.opencontainers.image.version"="${VERSION}" \
		-t $(IMAGE) \
		-f $(DIR)/$(FILE) $(DIR)

rebuild: pull-base-image
rebuild: NO_CACHE=--no-cache
rebuild: build


# --------------------------------------------------------------------------------------------------
# Test Targets
# --------------------------------------------------------------------------------------------------
test:
	@$(MAKE) --no-print-directory _test-version
	@$(MAKE) --no-print-directory _test-run

_test-version:
	@echo "------------------------------------------------------------"
	@echo "- Testing correct version"
	@echo "------------------------------------------------------------"
	@if [ "$(VERSION)" = "latest" ]; then \
		echo "Fetching latest version from GitHub"; \
		LATEST="$$( \
			curl -L -sS  https://github.com/ansible/ansible-lint/releases/latest/ \
				| tac | tac \
				| grep -Eo '/ansible-lint/releases/tag/v[.0-9]+"' \
				| grep -Eo '/ansible-lint/releases/tag/v[.0-9]+' \
				| head -1 \
				| sed 's/.*v//g' \
		)"; \
		echo "Testing for latest: $${LATEST}"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "^ansible-lint $${LATEST}\s"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	else \
		echo "Testing for tag: $(VERSION)"; \
		if ! docker run --rm $(IMAGE) --version | grep -E "ansible-lint $(VERSION)[.0-9]+"; then \
			echo "Failed"; \
			exit 1; \
		fi; \
	fi; \
	echo "Success"; \

_test-run:
	@echo "------------------------------------------------------------"
	@echo "- Testing playbook"
	@echo "------------------------------------------------------------"
	@if ! docker run --rm -v $(CURRENT_DIR)/tests:/data $(IMAGE) -v playbook.yml; then \
		echo "Failed"; \
		exit 1; \
	fi; \
	echo "Success";


# -------------------------------------------------------------------------------------------------
#  Deploy Targets
# -------------------------------------------------------------------------------------------------
tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

login:
	@yes | docker login --username $(USER) --password $(PASS)

push:
	docker push $(IMAGE):$(TAG)


# -------------------------------------------------------------------------------------------------
#  Helper Targets
# -------------------------------------------------------------------------------------------------
pull-base-image:
	@grep -E '^\s*FROM' Dockerfile \
		| sed -e 's/^FROM//g' -e 's/[[:space:]]*as[[:space:]]*.*$$//g' \
		| xargs -n1 docker pull;

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=/bin/sh $(ARG) $(IMAGE):$(TAG)
