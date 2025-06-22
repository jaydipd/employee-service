#Steps for ngrok(use to host local apps on the internet)
1. go to D:\softwares\ngrok-v3-stable-windows-amd64 and open cmd
2. Run the following command to add your authtoken to the default ngrok.yml configuration file.
   ```ngrok config add-authtoken 2xrTwqaYX7FfmJujoIqTyPmVgyz_2M44TJrGZau5zDNdHNhfg```
3. Put your app online at an ephemeral domain forwarding to your upstream service. For example, if it is listening on port http://localhost:9001(this is jenkins URL)
   then run the following command ```ngrok http http://localhost:9001```

#Steps to check if jenkins able to connect to aws.
1.configure aws credentials(ACCESS KEY and SECRET KEY)
2.create pipeline with below content and run it , you should get response from aws.
   ```pipeline {
         agent any
         stages {
              stage('Test AWS') {
                  steps {
                         withAWS(credentials: 'aws-credentials', region: 'ap-south-1') {
                              bat 'aws sts get-caller-identity'
                      }
                    }
                  }
                 }
               }
   ```
#Terraform module location ```D:\terraform\hello-world```