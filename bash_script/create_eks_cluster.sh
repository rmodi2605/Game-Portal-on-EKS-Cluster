#! /bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Clone Git Repo & Create EKS Cluster by using Terraform
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function create_eks_using_terraform () {
    git clone https://github.com/rmodi2605/Game-Portal-on-EKS-Cluster.git
    sleep 2s ;  cd /var/lib/jenkins/Game-Portal-on-EKS-Cluster/eks_cluster ; chmod +x *
    terraform init ; sleep 15s
    validate=$(terraform validate)
    if [[ $validate == *Success* ]];
    then
        terraform plan
        terraform apply --auto-approve
        if [ $? -eq 0 ]; 
        then
            echo "Terraform Successfully Created EKS Cluster."
        else
            echo "Terraform Failed to create EKS Cluster."
        fi
    else
        echo "Terraform Code Validation Failed."
    fi
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Update Kubeconfig File to Access EKS Cluster
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function verify_kubernetes_cluster () {
    sudo rm -rf /home/$USER/.kube ; mkdir /home/$USER/.kube ; touch /home/$USER/.kube/config ; chmod +x config 
    aws eks update-kubeconfig --name rmodi-test-k8-cluster --region ca-central-1
    kubeconfig_check=$(cat /home/$USER/.kube/config  | grep current-context)
    if [[ $kubeconfig_check == *rmodi-test-k8-cluster* ]] ;  
    then
        echo "KubeConfig file updated Successfully."
        check_eks_cluster_access
    else 
        echo "KubeConfig file is not updated correctly."
    fi
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Check EKS Cluster is Ready to Accessible
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function check_eks_cluster_access () {
    k8_cluster_check="kubectl cluster-info | egrep 'Kubernetes control plane' | grep running"
    if [[ $k8_cluster_check == *running* ]];
    then
        echo -e "\nEKS Cluster is Ready to Access"
    else
        echo -e "\nEKS Cluster is NOT Ready"
    fi
}