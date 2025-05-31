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
                bat 'terraform init'
                bat 'terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -auto-approve tfplan'
            }
        }
        stage('Build') {
            steps {
                bat 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                bat 'docker build -t $ECR_REGISTRY/$REPO_NAME:$BUILD_NUMBER .'
            }
        }
        stage('Push to ECR') {
            steps {
                bat 'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY'
                bat 'docker push $ECR_REGISTRY/$REPO_NAME:$BUILD_NUMBER'
            }
        }
        stage('Update ECS Service') {
            steps {
                bat '''
                aws ecs update-service \
                    --cluster employee-cluster \
                    --service employee-service \
                    --task-definition $(aws ecs register-task-definition --cli-input-json file://task-definition.json | jq -r '.taskDefinition.taskDefinitionArn') \
                    --force-new-deployment
                '''
            }
        }
    }
}