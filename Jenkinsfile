pipeline {
    environment {
        GIT_REPO = 'https://github.com/TheIronhidex/terraform-var'
        GIT_BRANCH = 'main'
        DOCKER_REPO = 'theironhidex'
        CONTAINER_PORT= '87'
        AWS_ACCESS_KEY_ID = "aws-jose('aws_access_key_id')"
        AWS_SECRET_ACCESS_KEY = "aws-jose('aws_secret_access_key')"
	TF_VAR_region = "eu-west-3"
	TF_VAR_repository_id = "${JOB_BASE_NAME}"
        TF_VAR_image_version = "${BUILD_NUMBER}"
        TF_VAR_access_key = "${AWS_ACCESS_KEY_ID}"
	TF_VAR_secret_key = "${AWS_SECRET_ACCESS_KEY}"
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-jose', passwordVariable: 'docker_pass', usernameVariable: 'docker_user')]) {
                    sh "docker login -u $docker_user -p $docker_pass"
                    sh "docker push ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

	stage ("Create init-script.sh") {
	    steps {
		sh '''
                   cat <<EOT > init-script.sh
                   docker login -u theironhidex -p
                   docker pull ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}
                   docker run -d -p 80:80 ${env.DOCKER_REPO}/${JOB_BASE_NAME}:${BUILD_NUMBER}
                   docker system prune -f
                   EOT
		'''
	    }
	}
        
        stage('terraform format check') {
            steps{
                sh 'terraform fmt'
            }
        }
        
        stage('terraform Init') {
            steps{
                sh """
		export TF_VAR_region='eu-west-3'
        	export TF_VAR_access_key = ${AWS_ACCESS_KEY_ID}
		export TF_VAR_secret_key = ${AWS_SECRET_ACCESS_KEY}
		terraform init
		""" 
            }
        }
        
        stage('terraform apply') {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }

        stage('Checking for destroying the infrastructure') {
            steps{
                input "Proceed destroying the instance?"
                sh 'terraform destroy --auto-approve'
            }
        }

    }

    
}
