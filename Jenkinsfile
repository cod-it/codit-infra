pipeline {
  environment {
    PROJECT = "sandbox-io-289003"
    CLUSTER = "jenkins-cd"
    CLUSTER_ZONE = "us-east1-d"
  }

  agent {
    kubernetes {
      label 'my-agent'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: cd-jenkins
  containers:
  - name: kubectl
    image: dtzar/helm-kubectl:3.11
    imagePullPolicy: IfNotPresent
    command:
    - cat
    tty: true

"""
}
  }
  stages {

    stage('Deploy to kubernetes') {
      steps {
        container('kubectl') {
          dir("k8") {
           sh "kubectl apply -f . "
        }
      }
    }
  }
  }
}