# uncharted.global
GKE assignment

--- Clone repo: ---    
$ git clone https://github.com/jeromeza/uncharted.global.git. 
  
--- Usage: ---    
$ cd uncharted.global/   
$ ./master_deploy.sh YOUR_UNIQUE_PROJECT_ID_HERE   
$ ./master_destroy.sh YOUR_UNIQUE_PROJECT_ID_HERE   
  
NOTE: Your project ID has to be unique across GCP (not just your account) - so don't use a generic name  
  
--- The deploy script will then: ---   
1.) Install and auth via GCP SDK - as your GCP user (you will need to respond to the prompts)  
2.) Create GCP project and enable required services for GKE (compute, container, iam etc)  
3.) Assign users to project / IAM permissions to users   
4.) Apply Terraform to build GKE cluster - as service specific GCP user (you will need to respond to the prompts)  
5.) Apply Helm chart to setup our webserver and configure k8s (deployment, pods, service, ingress, hpa etc)  
6.) Publish the ingress IP that will serve our site  
