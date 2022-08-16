pipeline {
    environment {
        GIT_REPO = 'https://github.com/TheIronhidex/terraform-var'
        GIT_BRANCH = 'main'
	REGION = 'eu-west-3'
        DOCKER_REPO = 'theironhidex'
        CONTAINER_PORT= '87'
      }

    agent any
    tools {
       terraform 'terraform20803'
    }
    stages {
        
        stage ("Get Code") {
            steps {
                git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO}"
            }
        }

        stage ("Build Image") {
            steps {
                sh "docker build -t ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage ("Publish Image") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-jose', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
                    sh "docker login -u $docker_user -p $docker_pass"
                    sh "docker push ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

        stage('terraform format check') {
            steps{
                sh 'terraform fmt'
            }
        }
	    
        stage('terraform Init') {
            steps{
                sh 'terraform init'
            }
        }
	    
        stage('Build infras?') {
            steps{
                input "Proceed building the infrastructure?"
            }
        }
        
        stage('terraform apply') {
            steps{
                sh """
		terraform apply -var=\"container_port=${env.CONTAINER_PORT}\" \
		-var=\"reponame=${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}\" \
		-var=\"region=${env.REGION}\" \
		-var=\"access_key=${env.\"aws-jose('aws_access_key_id')\"}\" \
		-var=\"secret_key=${env.\"aws-jose('aws_secret_access_key')\"}\" \
		--auto-approve"
                """
	    }
        }
	    
        stage('Destroy infras?') {
            steps{
                input "Proceed destroying the infrastructure?"
            }
        }
	    
        stage('Executing Terraform Destroy') {
            steps{
                sh "terraform destroy --auto-approve"
            }
        }
    }   
}
