#! /bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Deploy Argo CD in EKS Cluster
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function deploy_argocd () {
    argo_url="kubectl get service argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'"
    argo_passwd="kubectl get secret argocd-initial-admin-secret -n argocd  -o jsonpath='{.data.password}' | base64 --decode"
    check_argo_pod_status="kubectl get pods -n argocd"

    kubectl create namespace argocd
    kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd
    sleep 60s
    kubectl patch service argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

    printf "Argo CD Dashboard Link : http://$argo_url/  \n"
    printf "Argo CD Username : admin \n"
    printf "Argo CD Password : $argo_passwd \n"
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2048 Argo Application Deployment in in EKS Cluster
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function 2048_argo_app_deploy () {
cat > 2048-application.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 2048-argo-app
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/rmodi2605/Game-Portal-on-EKS-Cluster.git
    targetRevision: HEAD
    path: 2048-app
  destination:
    server: https://kubernetes.default.svc
    namespace: 2048-app

  syncPolicy:
    syncOptions:
    - CreateNamespace=true
    automated:
      selfHeal: true
      prune: true
EOF

    kubectl apply -f 2048-application.yaml ; sleep 90s
    kubectl patch service myapp-service -n 2048-app -p '{"spec": {"type": "LoadBalancer"}}'
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Verify 2048 Game Application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function verify_2048_app () {
    check_deploy="kubectl get deployment myapp-deployment -n myapp"
    application_link="kubectl get service myapp-service -n 2028-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    status_code=$(curl --output /dev/null --silent --write-out "%{http_code}" --location "http://$application_link/" )

    while $check_deploy | grep 2048-app | awk {'print $2'} != "3/3" ;
    do
        echo "Application is trying to be Ready....." ; sleep 3s
    done

    if [[  status_code == 200 ]] ;
    then
        printf "Application is Ready ! \n"
        printf "Application Access Link => http://$application_link/ "
    else
        printf "Application is NOT Ready"
        kubectl get pods myapp-deployment -n myapp -o wide
    fi
}
