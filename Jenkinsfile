pipeline {
    agent any

	// Set the environment variables
    environment {
        PATH = "${env.HOME}/bin:${env.PATH}"
    }

	// Multistage pipeline
    stages {
		// Stage 1 - Install Terraform
        stage('Install Terraform') {
            steps {
                sh '''
					if ! command -v terraform >/dev/null 2>&1; then
						echo "Installing terraform..."
						curl -O https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
						unzip terraform_1.12.2_linux_amd64.zip
						chmod +x ./terraform
						mkdir -p $HOME/bin
						cp ./terraform $HOME/bin/terraform
						export PATH=$HOME/bin:$PATH
					else
						echo "terraform is already installed: $(terraform version)"
					fi
                '''
            }
        }
		
		// Stage 2 - Destroy EKS Cluster
        stage('Destroy EKS Cluster') {
            steps {
				script {
					// Install AWS Steps plugin to make this work
					withAWS(region: "${AWS_REGION}", credentials: 'AWS') {
						try {
							sh '''
								cd app
								terraform init \
								  -backend-config="bucket=${S3_BUCKET}" \
								  -backend-config="key=${S3_KEY}" \
								  -backend-config="region=${AWS_REGION}" \
								  -backend-config="encrypt=true"
								# terraform plan
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
