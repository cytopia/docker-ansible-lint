#!/usr/bin/env groovy

/**
 * This pipeline will build and deploy a Docker image with Kaniko
 * https://github.com/GoogleContainerTools/kaniko
 * without needing a Docker host
 *
 * You need to create a jenkins-docker-cfg secret with your docker config
 * as described in
 * https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-in-the-cluster-that-holds-your-authorization-token
 */

def label = "build-ansible-lint-jdk11-${UUID.randomUUID().toString()}"
def home = "/home/jenkins/agent"
def workspace = "${home}/workspace/build-docker-ansible-lint-jdk11"
def workdir = "${workspace}/src/github.com/rasautomation/docker-ansible-lint-jdk11/"

// Ansible Lint Version
def VERSION = "4.1.0"

podTemplate (
    label: label,
    yaml:
"""
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/
    resources:
      limits:
        ephemeral-storage: 5Gi
      requests:
        ephemeral-storage: 2Gi
  volumes:
    - name: docker-config
      configMap:
        name: docker-config
"""
) {
    node(label) {
        dir(workdir) {
            stage('Checkout SCM') {
                timeout(time: 3, unit: 'MINUTES') {
                    checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: [[$class: 'CleanBeforeCheckout']],
                        userRemoteConfigs: scm.userRemoteConfigs
                    ])
                }
                echo sh(script: 'env|sort', returnStdout: true)
            }
            stage('Docker Build docker-ansible-lint-jdk11') {
                echo sh(script: 'env|sort', returnStdout: true)
                container(name: 'kaniko', shell: '/busybox/sh') {
                    echo sh(script: 'env|sort', returnStdout: true)
                    sh '''
                    #!/busybox/sh
                    /kaniko/executor \
                        -f `pwd`/Dockerfile \
                        -c `pwd` \
                        --destination=287908807331.dkr.ecr.us-east-2.amazonaws.com/ansible-lint-jdk11:${VERSION}
                    '''
                }
            }
        }
    }
}
