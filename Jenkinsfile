pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/Surya-the-creater/docker-.git', branch: 'master'
            }
        }
        stage('Build Image') {
            steps {
                sh 'docker build -t myecomm .'
            }
        }
        stage('Tag Image') {
            steps {
                sh 'docker tag myecomm suryahosur/myecomm'
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }
        stage('Image Push') {
            steps {
                sh 'docker push suryahosur/myecomm'
            }
        }
        stage('Run Image') {
            steps {
                sh 'docker run -itd -P --name=web_ecomm suryahosur/myecomm'
            }
        }
    }
}
