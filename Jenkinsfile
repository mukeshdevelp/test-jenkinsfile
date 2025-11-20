pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'eu-west-1'
    AWS_CREDS = credentials('aws-credentials')
  }

  stages {

    stage('Terraform Init') {
      steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-credentials',
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          sh 'aws s3 ls'
        }
        sh 'terraform init'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
          terraform apply -auto-approve
          terraform output -json > outputs.json
        '''
      }
    }

    stage('Parse Terraform Outputs') {
      steps {
        script {
          env.INSTANCE_ID = sh(
            script: "terraform output -json instance_id | jq -r '.'",
            returnStdout: true
          ).trim()
          echo "Instance ID = ${env.INSTANCE_ID}"
        }
      }
    }
    stage('Install AWS SDK for Python & Ansible') {
  steps {
    sh '''
      python3 -m venv venv
      . venv/bin/activate

      pip install --upgrade pip
      pip install boto3 botocore ansible

      ansible-galaxy collection install amazon.aws
      ansible-galaxy collection install community.aws
       
        ansible-playbook -i /var/lib/jenkins/workspace/test-sm-1/aws_ec2.yaml install_roles.yml -vvv
    '''
  }
}


    

    

    
  }
}
