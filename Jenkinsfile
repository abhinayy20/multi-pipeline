pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS     = '-no-color'

        // Jenkins Credentials IDs (CORRECT)
        AWS_CRED_ID = 'Devops-project-id'
        SSH_CRED_ID = 'devops-ssh-key'

        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:${env.PATH}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Terraform Initialization') {
            steps {
                withCredentials([
                    aws(credentialsId: env.AWS_CRED_ID)
                ]) {
                    script {
                        echo "Initializing Terraform for branch: ${env.BRANCH_NAME}"
                        sh 'terraform init'

                        echo "Displaying ${env.BRANCH_NAME}.tfvars configuration:"
                        sh """
                            if [ -f ${env.BRANCH_NAME}.tfvars ]; then
                                cat ${env.BRANCH_NAME}.tfvars
                            else
                                echo "${env.BRANCH_NAME}.tfvars not found!"
                                exit 1
                            fi
                        """
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    aws(credentialsId: env.AWS_CRED_ID)
                ]) {
                    script {
                        echo "Generating Terraform plan for ${env.BRANCH_NAME}"
                        sh """
                            terraform plan \
                              -var-file=${env.BRANCH_NAME}.tfvars \
                              -out=${env.BRANCH_NAME}.tfplan
                        """
                    }
                }
            }
        }

        stage('Validate Apply') {
            when { branch 'dev' }
            steps {
                script {
                    input message: 'Approve Terraform apply for DEV?'
                }
            }
        }

        stage('Terraform Apply') {
            when { branch 'dev' }
            steps {
                withCredentials([
                    aws(credentialsId: env.AWS_CRED_ID)
                ]) {
                    script {
                        sh """
                            terraform apply \
                              -auto-approve \
                              ${env.BRANCH_NAME}.tfplan
                        """
                    }
                }
            }
        }

        stage('Show Outputs') {
            when { branch 'dev' }
            steps {
                withCredentials([
                    aws(credentialsId: env.AWS_CRED_ID)
                ]) {
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline failed for ${env.BRANCH_NAME}"
        }
        always {
            cleanWs()
        }
    }
}
