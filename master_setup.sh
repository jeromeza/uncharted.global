[200~#!/bin/bash

printf %"$COLUMNS"s |tr " " "-"
printf %"$COLUMNS"s |tr " " "-"
echo "INSTALLING PREREQUISITES AND CLONING REPO"
printf %"$COLUMNS"s |tr " " "-"
printf "\n" ; apt install git -y
git clone https://github.com/jeromeza/uncharted.global.git

printf %"$COLUMNS"s |tr " " "-"
echo "INSTALLING GCLOUD SDK FOR PROGRAMMATIC CLI ACCESS"
printf %"$COLUMNS"s |tr " " "-"
cd uncharted.global
bash install.sh --disable-prompts
CLOUDSDK_CORE_DISABLE_PROMPTS=1 ~/./google-cloud-sdk/install.sh
source ~/./google-cloud-sdk/path.bash.inc
printf %"$COLUMNS"s |tr " " "-"
echo "PLEASE AUTHENTICATE WITH YOUR GCP USER"
printf %"$COLUMNS"s |tr " " "-"
#gcloud auth login
gcloud auth application-default login

printf %"$COLUMNS"s |tr " " "-"
echo "CREATING GCLOUD PROJECT AND ENABLING SERVICES - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
gcloud projects create terraforming-uncharted3 --set-as-default
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
BILLING=$(printf 'yes' | gcloud beta billing accounts list --quiet | tail -n1 | awk {'print $1'})
gcloud beta billing projects link terraforming-uncharted3 --billing-account=$BILLING
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com

printf %"$COLUMNS"s |tr " " "-"
echo "ASSIGNING IAM PERMISSION BINDINGS TO USERS"
printf %"$COLUMNS"s |tr " " "-"
gcloud projects add-iam-policy-binding terraforming-uncharted3 --member 'user:brian.blignaut@uncharted.global' --role roles/editor
gcloud projects add-iam-policy-binding terraforming-uncharted3 --member 'user:tobias.adamson@uncharted.global' --role roles/editor

printf %"$COLUMNS"s |tr " " "-"
echo "APPLYING TERRAFORM - DEPLOYING GKE CLUSTER - PLEASE WAIT..."
printf %"$COLUMNS"s |tr " " "-"
export project_id=terraforming-uncharted3
export master_authorized_networks=192.145.137.18/32
./tooling/terraform init
./tooling/terraform plan -var="project_id=[${project_id}]" -var="master_authorized_networks=[${master_authorized_networks}]"
