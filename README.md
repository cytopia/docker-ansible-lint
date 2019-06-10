# Docker image for `ansible-lint`

[![Build Status](https://travis-ci.com/cytopia/docker-ansible-lint.svg?branch=master)](https://travis-ci.com/cytopia/docker-ansible-lint)
[![Tag](https://img.shields.io/github/tag/cytopia/docker-ansible-lint.svg)](https://github.com/cytopia/docker-ansible-lint/releases)
[![](https://images.microbadger.com/badges/version/cytopia/ansible-lint:latest.svg)](https://microbadger.com/images/cytopia/ansible-lint:latest "ansible-lint")
[![](https://images.microbadger.com/badges/image/cytopia/ansible-lint:latest.svg)](https://microbadger.com/images/cytopia/ansible-lint:latest "ansible-lint")
[![](https://img.shields.io/badge/github-cytopia%2Fdocker--ansible--lint-red.svg)](https://github.com/cytopia/docker-ansible-lint "github.com/cytopia/docker-ansible-lint")
[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

> #### All awesome CI images
>
> [ansible](https://github.com/cytopia/docker-ansible) |
> [ansible-lint](https://github.com/cytopia/docker-ansible-lint) |
> [awesome-ci](https://github.com/cytopia/awesome-ci) |
> [jsonlint](https://github.com/cytopia/docker-jsonlint) |
> [terraform-docs](https://github.com/cytopia/docker-terraform-docs) |
> [yamllint](https://github.com/cytopia/docker-yamllint)


View **[Dockerfile](https://github.com/cytopia/docker-ansible-lint/blob/master/Dockerfile)** on GitHub.

[![Docker hub](http://dockeri.co/image/cytopia/ansible-lint)](https://hub.docker.com/r/cytopia/ansible-lint)

Tiny Alpine-based multistage-build dockerized version of [ansible-lint](https://github.com/ansible/ansible-lint)<sup>[1]</sup>.
The image is built nightly against the latest stable version of `ansible-lint` and pushed to Dockerhub.

<sup>[1] Official project: https://github.com/ansible/ansible-lint</sup>


## Available Docker image versions

| Docker tag | Build from |
|------------|------------|
| `latest`   | Current stable ansible-lint version |


## Docker mounts

The working directory inside the Docker container is **`/data/`** and should be mounted locally to
the root of your project where your `.ansible-lint` config file is located.


## Usage

```bash
# Single playbook
docker run --rm -v $(pwd):/data cytopia/ansible-lint ansible-lint playbook.yml

# All playbooks via wildcard
docker run --rm -v $(pwd):/data cytopia/ansible-lint ansible-lint *.yml
```


## License

**[MIT License](LICENSE)**

Copyright (c) 2019 [cytopia](https://github.com/cytopia)
