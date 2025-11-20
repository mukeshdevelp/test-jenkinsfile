pipeline {
  agent any

  environment {
    AWS_CREDS = credentials('aws-credentials')
    AWS_DEFAULT_REGION = 'eu-west-1'  // set your AWS region
    INVENTORY_FILE = 'ssm_inventory.ini'
  }

  stages {
    stage('Terraform Init') {
      steps {
        withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',  // your Jenkins AWS credentials ID
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    // Using the AWS credentials in the environment
                    sh '''
                    # Run an AWS CLI command to list S3 buckets as a test
                    aws s3 ls
                    '''
                }

        sh 'terraform init'
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
        terraform apply -auto-approve
        terraform refresh   # or terraform apply -auto-approve
        terraform output -json > outputs.json
      '''
      }
    }
    stage('Parse Terraform Outputs') {
      steps {
        script {
          def instanceId = sh(script: "terraform output -json instance_id | jq -r '.'", returnStdout: true).trim()
          env.INSTANCE_ID = instanceId
          echo "Instance ID is ${env.INSTANCE_ID}"
        }
      }
    }

    stage('Install Ansible Collections') {
      steps {
        // Install the required Ansible collections
        sh 'ansible-galaxy collection install community.aws'
      }
    }

    stage('Create Dynamic Inventory') {
      steps {
        script {
          // Write the aws_ec2.yml inventory plugin config
          writeFile file: 'aws_ec2.yml', text: '''
---
plugin: amazon.aws.aws_ec2
regions:
  - eu-west-1
filters:
  tag:environment: staging
hostnames:
  - instance-id
compose:
  ansible_host: instance_id
  ansible_connection: community.aws.aws_ssm
'''
          echo "Dynamic AWS EC2 inventory file created."
    }
  }
}
  stage('Run Ansible Playbook') {
  steps {
    sh 'ansible-playbook -i aws_ec2.yml install_roles.yml'
  }
  }

    
  }
}
