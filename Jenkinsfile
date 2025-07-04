pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REGISTRY = '145523123074.dkr.ecr.ap-south-1.amazonaws.com'
        REPO_NAME = 'employee-service'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/jaydipd/employee-service.git'
            }
        }
        stage('Terraform Init & Plan') {
            steps {
                bat 'cd terraform && terraform init'
                bat 'cd terraform && terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                bat 'cd terraform && terraform apply -auto-approve tfplan'
            }
        }
        stage('Build') {
            steps {
                bat 'mvn clean package'
            }
        }
     stage('Build Docker Image') {
    steps {
        bat 'docker build -t %ECR_REGISTRY%/%REPO_NAME%:%BUILD_NUMBER% .'
    }
}
   stage('Push to ECR') {
    steps {
        bat 'aws ecr get-login-password --region %AWS_DEFAULT_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%'
        bat 'docker push %ECR_REGISTRY%/%REPO_NAME%:%BUILD_NUMBER%'
    }
}
      stage('Destroy'){
          steps {
                        bat 'cd terraform && terraform destroy -auto-approve'
                    }
        }
    }
}