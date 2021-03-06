#!/bin/bash
# Check for project argument as $1 - if not present, abort
if [ -z "$*" ]; then echo "Please specify a unique project name" && exit 0; fi

# Install and auth to GCP SDK as your GCP user
# This is needed to create the GCP project (on the free tier) - as you cannot do this via Terraform - mainly because you cannot create an organization via a service account - which TF runs as
# See: https://stackoverflow.com/questions/62385602/making-a-gcp-project-in-cli-without-being-able-to-make-a-parent-as-a-trial-user
printf %"$COLUMNS"s |tr " " "-"
echo "INSTALLING GCLOUD SDK FOR PROGRAMMATIC CLI ACCESS"
printf %"$COLUMNS"s |tr " " "-"
bash install.sh --disable-prompts
CLOUDSDK_CORE_DISABLE_PROMPTS=1 ~/./google-cloud-sdk/install.sh
source ~/./google-cloud-sdk/path.bash.inc
printf %"$COLUMNS"s |tr " " "-"
echo "PLEASE AUTHENTICATE WITH YOUR GCP USER"
printf %"$COLUMNS"s |tr " " "-"
gcloud auth login

# Create GCP project and enable required services for GKE
printf %"$COLUMNS"s |tr " " "-"
echo "CREATING GCLOUD PROJECT AND ENABLING SERVICES - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
gcloud projects create "$1" --set-as-default
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
BILLING=$(printf 'yes' | gcloud beta billing accounts list --quiet | tail -n1 | awk {'print $1'})
gcloud beta billing projects link "$1" --billing-account=$BILLING
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com

# Assign IAM permissions to users
printf %"$COLUMNS"s |tr " " "-"
echo "ASSIGNING IAM PERMISSION BINDINGS TO USERS"
printf %"$COLUMNS"s |tr " " "-"
gcloud projects add-iam-policy-binding "$1" --member 'user:brian.blignaut@uncharted.global' --role roles/editor
gcloud projects add-iam-policy-binding "$1" --member 'user:tobias.adamson@uncharted.global' --role roles/editor

# Apply Terraform to build GKE cluster
# For this we need to re-auth via the GCP SDK as application service account - I can't seem to spot away around this on the free tier
# For a normal non free account I would create a service account, with admin rights for Terraform --> attach it to my organization --> use it to deploy future projects / resources
# However for this demo, that wasn't possible (see free account restrictions above)
printf %"$COLUMNS"s |tr " " "-"
echo "APPLYING TERRAFORM - DEPLOYING GKE CLUSTER - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
gcloud auth application-default login
export USER_IP=$(/usr/bin/curl -s ifconfig.me)
sed -i "s/whitelist/$USER_IP\/32/g" main.tf
./tooling/terraform init
printf 'yes' | ./tooling/terraform apply -var project_id="$1"

# Apply Helm chart to setup webserver 
# Bundling Helm here as it's easy to upgrade / group k8s resources
printf %"$COLUMNS"s |tr " " "-"
echo "DEPLOYING WEBSERVER VIA HELM CHART - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
./tooling/helm install webserver webserver_chart/ --kubeconfig ./kubeconfig-prod --set Image=nginx

# Install Prometheus repo
printf %"$COLUMNS"s |tr " " "-"
echo "DEPLOYING PROMETHEUS VIA HELM CHART - FOR DASHBOARD / MONITORING - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
./tooling/helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
./tooling/helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
./tooling/helm repo update
./tooling/kubectl --kubeconfig ./kubeconfig-prod create ns monitor
./tooling/helm install --kubeconfig ./kubeconfig-prod prometheus-operator prometheus-community/prometheus-operator --namespace monitor
./tooling/kubectl --kubeconfig ./kubeconfig-prod apply -f prometheus_chart/templates/ingress.yml

printf %"$COLUMNS"s |tr " " "-"
echo "YOUR WEBSITE WILL BE AVAILABLE ON THE BELOW IP ADDRESS - WITHIN THE NEXT FEW MINS"
printf %"$COLUMNS"s |tr " " "-"
sleep 120
export INGRESS_IP=$(./tooling/kubectl --kubeconfig ./kubeconfig-prod get ingress | tail -n1 | awk {'print $4'})
echo "http://$INGRESS_IP"

printf %"$COLUMNS"s |tr " " "-"
echo "YOUR GRAFANA DASHBOARDS WILL BE AVAILABLE ON THE BELOW IP ADDRESS - WITHIN THE NEXT FEW MINS"
printf %"$COLUMNS"s |tr " " "-"
export PROMINGRESS_IP=$(./tooling/kubectl --kubeconfig ./kubeconfig-prod get ingress -n monitor | tail -n1 | awk {'print $4'})
echo "http://$PROMINGRESS_IP"
