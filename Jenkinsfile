pipeline {
    agent any

    stages {

        stage ("Clean Workspace") {
            steps {
               cleanWs() 
            }
        }

        stage ("Git Repository Clone") {
            steps {
                   git branch: 'main', 
                   credentialsId: 'Game-Portal-on-EKS-Cluster', 
                   url: 'https://github.com/rmodi2605/Game-Portal-on-EKS-Cluster.git'
            }
        }

        /*stage ("Clone Git Repo") {
            steps {
                sh '''
                    cd ~
                    git clone https://github.com/rmodi2605/Game-Portal-on-EKS-Cluster.git
                '''
            }
        }*/

        stage ("Create EKS Cluster by using Terraform") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'source /var/lib/jenkins/Game-Portal-on-EKS-Cluster/bash_script/create_eks_cluster.sh'
                sh 'create_eks_using_terraform'
            }
        }

        stage ("Update Kubeconfig File") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'verify_kubernetes_cluster'
            }
        }

        stage ("Check EKS Cluster Access") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'check_eks_cluster_access'
            }
        }
        
        /*stage ("Deploy Argo CD in EKS Cluster") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'source ./Game-Portal-on-EKS-Cluster/bash_script/deploy_2048_argo_app.sh'
                sh 'deploy_argocd'
            }
        }

        stage ("2048 Argo Application Deployment") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh '2048_argo_app_deploy'
            }
        }

        stage ("Verify 2048 Game Application") {
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh 'verify_2048_app'
            }
        }*/

    }

     post {
        always {
            sh '''
                echo "Cleaning up after deployment"
                cd /var/lib/jenkins/  
                rm -rf Game-Portal-on-EKS-Cluster
                pwd
                echo ""
                ls -la 
            '''
        }
    }
}
