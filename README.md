# Docker image for `ansible-lint` w/ OpenJDK 11

This Docker image extends the [cytopia/ansible-lint](https://hub.docker.com/r/cytopia/ansible-lint) image to include OpenJDK 11.

This allows us to run SonarQube code analysis on Ansible repositories using the [sbaudoin/sonar-ansible](https://github.com/sbaudoin/sonar-ansible) plugin for SonarQube.
