pipeline {
    agent any

	// Set the environment variables
    environment {
        AWS_REGION = 'us-east-1'
        CUSTOM_BIN = "${env.HOME}/bin"
        PATH = "${env.HOME}/bin:${env.PATH}"
    }

	// Multistage pipeline
    stages {
		// Stage 1 - Checkout code repository
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'Github',
                    url: 'https://github.com/prashant-aggarwal/awr-devops-cap-eks-destroy-terraform.git'
            }
        }

		// Stage 2 - Install Terraform
        stage('Install Terraform') {
            steps {
                sh '''
					echo "Installing terraform..."
					curl -O https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
					unzip terraform_1.12.2_linux_amd64.zip
					chmod +x ./terraform
					mkdir -p $HOME/bin
					cp ./terraform $HOME/bin/terraform
					export PATH=$HOME/bin:$PATH
					terraform version
                '''
            }
        }
		
		// Stage 3 - Destroy EKS Cluster
        stage('Destroy EKS Cluster') {
            steps {
				script {
					// Install AWS Steps plugin to make this work
					withAWS(region: "${env.AWS_REGION}", credentials: 'AWS') {
						try {
							sh '''
								cd app
								terraform destroy -auto-approve
							'''
						} catch (exception) {
							echo "❌ Failed to create EKS cluster: ${exception}"
							error("Halting pipeline due to EKS cluster creation failure.")
						}
					}
				}
			}
		}
    }

    // Cleanup the workspace in the end
	post {
        always {
            cleanWs()
        }
    }
}
