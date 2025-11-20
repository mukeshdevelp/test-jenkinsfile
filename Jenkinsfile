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
        sh 'terraform apply -auto-approve'
      }
    }

    stage('Generate Ansible Inventory') {
      steps {
        script {
          def instanceId = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()

          writeFile file: env.INVENTORY_FILE, text: """\
[ssm_instances]
${instanceId}

[ssm_instances:vars]
ansible_connection=community.aws.aws_ssm
ansible_user=ec2-user
"""
        }
      }
    }

    stage('Run Ansible Playbook') {
      steps {
        // Run ansible-playbook using the generated inventory and playbook file
        sh 'ansible-playbook -i ssm_inventory.ini install_roles.yml'
      }
    }
  }
}
