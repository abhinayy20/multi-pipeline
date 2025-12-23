pipeline {
    agent any
    
    // Task 2: Pipeline Environment & Credentials (20 Marks)
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        // AWS credentials will be injected securely using your existing credential
        AWS_CREDENTIAL = 'Devops-project-id'
        SSH_CRED_ID = 'ssh-private-key'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out branch: ${env.BRANCH_NAME}"
            }
        }
        
        // Task 3: Initialization & Variable Inspection (20 Marks)
        stage('Terraform Initialization') {
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Initializing Terraform for branch: ${env.BRANCH_NAME}"
                        sh 'terraform init'
                    
                    // Display the contents of the branch-specific tfvars file
                    echo "Displaying ${env.BRANCH_NAME}.tfvars configuration:"
                    sh """
                        if [ -f ${env.BRANCH_NAME}.tfvars ]; then
                            echo "==== Contents of ${env.BRANCH_NAME}.tfvars ===="
                            cat ${env.BRANCH_NAME}.tfvars
                            echo "=============================================="
                        else
                            echo "Warning: ${env.BRANCH_NAME}.tfvars not found!"
                            exit 1
                        fi
                    }
                    """
                }
            }
        }
        
        // Task 4: Branch-Specific Terraform Planning (20 Marks)
        stage('TwithCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Generating Terraform plan for ${env.BRANCH_NAME} environment"
                        sh """
                            terraform plan \
                                -var-file=${env.BRANCH_NAME}.tfvars \
                                -out=${env.BRANCH_NAME}.tfplan
                        """
                        echo "Terraform plan generated successfully!"
                    }
                    """
                    echo "Terraform plan generated successfully!"
                }
            }
        }
        
        // Task 5: Conditional Manual Approval Gate (20 Marks)
        stage('Validate Apply') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    echo "Requesting approval for dev environment deployment..."
                    def userInput = input(
                        id: 'ApprovalGate',
                        message: 'Do you want to apply this Terraform plan to the dev environment?',
                        parameters: [
                            choice(
                                name: 'APPROVAL',
                                choices: ['Approve', 'Reject'],
                                description: 'Select Approve to proceed with terraform apply'
                            )
                        ]
                    )
                    
                    if (userInput == 'Approve') {
                        echo "Deployment approved! Proceeding to apply..."
                    } else {
                        error "Deployment rejected by user. Aborting pipeline."
                    }
                }
            }
        }
        
        // Optional: Terraform Apply (for future use)
        stage('Terraform Apply') {
            when {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Applying Terraform plan for ${env.BRANCH_NAME} environment"
                        sh """
                            terraform apply \
                                -auto-approve \
                                ${env.BRANCH_NAME}.tfplan
                        """
                        echo "Infrastructure deployed successfully!"
                    }
                            ${env.BRANCH_NAME}.tfplan
                    """
                    echo "Infrastructure deployed successfully!"
                }
            }
        }
        
        // Optional: Display Outputs
        stage('SwithCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Displaying Terraform outputs:"
                        sh 'terraform output'
                    }
            }
            steps {
                script {
                    echo "Displaying Terraform outputs:"
                    sh 'terraform output'
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline failed for branch: ${env.BRANCH_NAME}"
        }
        always {
            cleanWs(
                deleteDirs: true,
                patterns: [
                    [pattern: '*.tfplan', type: 'INCLUDE'],
                    [pattern: '.terraform/', type: 'INCLUDE']
                ]
            )
        }
    }
}
