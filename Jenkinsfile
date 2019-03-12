pipeline {
    agent any
    environment {
        APPS_NAME = "node-todo"
        FQDN = "todo.foobz.com.au"
        DOCKER_IMAGE_NAME = "foobz/node-todo"
    }
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                //archiveArtifacts artifacts: 'dist/node-todo.zip'
            }
        }
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                    app.inside {
                        sh 'echo Hello, World!'
                    }
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Deploy To Production - Cloud1') {
            when {
                branch 'master'
            }
            steps {
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig_cloud1',
                    configs: 'node-todo-kube.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        stage('Deploy To Production - Cloud2') {
            when {
                branch 'master'
            }
            steps {
                milestone(2)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig_cloud2',
                    configs: 'node-todo-kube.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        stage('DeployAppServices - AS3') {
            steps {
                // Deploy AppServices with AS3 with test
                milestone(3)
                build (job: "bigip-app-services-as3", 
                       parameters: 
                       [string(name: 'FQDN', value: FQDN),
                       string(name: 'APPS_NAME', value: APPS_NAME)])
            }
        }
    }
}
