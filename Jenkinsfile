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
                sh 'terraform init'
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REGISTRY/$REPO_NAME:$BUILD_NUMBER .'
            }
        }
        stage('Push to ECR') {
            steps {
                sh 'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY'
                sh 'docker push $ECR_REGISTRY/$REPO_NAME:$BUILD_NUMBER'
            }
        }
        stage('Update ECS Service') {
            steps {
                sh '''
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