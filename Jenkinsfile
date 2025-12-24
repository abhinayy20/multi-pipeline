pipeline {
    agent any
    
    // Task 2: Pipeline Environment & Credentials (20 Marks)
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        // AWS credentials will be injected securely using your existing credential
        AWS_CREDENTIAL = 'Devops-project-id'
        SSH_CRED_ID = '/home/abhi601/.ssh/devops.pem'
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:${env.PATH}"
    }
    
    stages {
        // Task 1: Automated Triggering via ngrok (20 Marks)
        stage('Ngrok & Webhook Setup') {
            when { beforeAgent true; expression { env.BRANCH_NAME == 'dev' } }
            steps {
                echo "Ensure ngrok is running: ngrok http 8080 (or Jenkins port)"
                echo "Set GitHub webhook to: https://<ngrok-url>/github-webhook/"
                echo "This stage is informational. Manual setup required unless automated externally."
            }
        }
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
                        sh '/bin/bash -c "terraform init"'
                        
                        // Display the contents of the branch-specific tfvars file
                        echo "Displaying ${env.BRANCH_NAME}.tfvars configuration:"
                        sh """#!/bin/bash
                            if [ -f ${env.BRANCH_NAME}.tfvars ]; then
                                echo "==== Contents of ${env.BRANCH_NAME}.tfvars ===="
                                cat ${env.BRANCH_NAME}.tfvars
                                echo "=============================================="
                            else
                                echo "Warning: ${env.BRANCH_NAME}.tfvars not found!"
                                exit 1
                            fi
                        """
                    }
                }
            }
        }
        
        // Task 4: Branch-Specific Terraform Planning (20 Marks)
        stage('Terraform Plan') {
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Generating Terraform plan for ${env.BRANCH_NAME} environment"
                        sh """#!/bin/bash
                            terraform plan \
                                -var-file=${env.BRANCH_NAME}.tfvars \
                                -out=${env.BRANCH_NAME}.tfplan
                        """
                        echo "Terraform plan generated successfully!"
                    }
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
        
        // Terraform Apply (executes after approval)
        stage('Terraform Apply') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Applying Terraform plan for ${env.BRANCH_NAME} environment"
                        sh """#!/bin/bash
                            terraform apply \
                                -auto-approve \
                                ${env.BRANCH_NAME}.tfplan
                        """
                        echo "Infrastructure deployed successfully!"
                    }
                }
            }
        }
        
        // Task 6: Provisioning & Output Capture (20 Marks)
        stage('Capture Outputs & Inventory') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Capturing Terraform outputs and writing dynamic inventory..."
                        def instance_ip = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                        def instance_id = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()
                        env.INSTANCE_IP = instance_ip
                        env.INSTANCE_ID = instance_id
                        writeFile file: 'dynamic_inventory.ini', text: "[ec2]\n${instance_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${env.SSH_CRED_ID}\n"
                        echo "dynamic_inventory.ini created for Ansible."
                    }
                }
            }
        }

        // Task 7: AWS Health Status Verification (20 Marks)
        stage('AWS Health Check') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Waiting for EC2 instance health checks to pass..."
                        sh "aws ec2 wait instance-status-ok --instance-ids ${env.INSTANCE_ID}"
                        echo "EC2 instance is healthy."
                    }
                }
            }
        }

        // Task 8: Splunk Installation & Testing (20 Marks)
        stage('Splunk Install & Test') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    echo "Running Splunk installation playbook..."
                    ansiblePlaybook inventory: 'dynamic_inventory.ini', playbook: 'playbooks/splunk.yml'
                    echo "Testing Splunk service..."
                    ansiblePlaybook inventory: 'dynamic_inventory.ini', playbook: 'playbooks/test-splunk.yml'
                }
            }
        }

        // Task 9: Infrastructure Destruction & Post-Build Actions (20 Marks)
        stage('Validate Destroy') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    def destroyInput = input(
                        id: 'DestroyGate',
                        message: 'Do you want to destroy the infrastructure?',
                        parameters: [choice(name: 'DESTROY', choices: ['Yes', 'No'], description: 'Select Yes to destroy infra')]
                    )
                    if (destroyInput == 'Yes') {
                        echo "Destroy approved. Proceeding..."
                    } else {
                        error "Destroy rejected by user. Aborting destroy stage."
                    }
                }
            }
        }
        stage('Terraform Destroy') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([aws(credentialsId: env.AWS_CREDENTIAL)]) {
                    script {
                        echo "Destroying infrastructure..."
                        sh "terraform destroy -auto-approve -var-file=${env.BRANCH_NAME}.tfvars"
                        echo "Infrastructure destroyed."
                    }
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
            script {
                echo "Triggering destroy on failure..."
                try {
                    sh "terraform destroy -auto-approve -var-file=${env.BRANCH_NAME}.tfvars"
                } catch (Exception e) {
                    echo "Auto-destroy failed: ${e.message}"
                }
            }
        }
        aborted {
            echo "Pipeline aborted for branch: ${env.BRANCH_NAME}"
            script {
                echo "Triggering destroy on abort..."
                try {
                    sh "terraform destroy -auto-approve -var-file=${env.BRANCH_NAME}.tfvars"
                } catch (Exception e) {
                    echo "Auto-destroy failed: ${e.message}"
                }
            }
        }
        always {
            script {
                try {
                    if (fileExists('dynamic_inventory.ini')) {
                        sh 'rm -f dynamic_inventory.ini'
                        echo "dynamic_inventory.ini deleted."
                    }
                    cleanWs(
                        deleteDirs: true,
                        patterns: [
                            [pattern: '*.tfplan', type: 'INCLUDE'],
                            [pattern: '.terraform/', type: 'INCLUDE']
                        ]
                    )
                } catch (Exception e) {
                    echo "Workspace cleanup skipped: ${e.message}"
                }
            }
        }
    }
}
