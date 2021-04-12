# uncharted.global
GKE assignment

### **--- Clone repo: ---**  
$ git clone https://github.com/jeromeza/uncharted.global.git   
  
### **--- Usage: ---**       
$ cd uncharted.global/   
$ ./master_deploy.sh YOUR_UNIQUE_PROJECT_ID_HERE   
$ ./master_destroy.sh YOUR_UNIQUE_PROJECT_ID_HERE   
  
NOTE: Your project ID has to be unique across GCP (not just your account) - so don't use a generic name  
  
### **--- The deploy script will then: ---**      
1.) Install and auth via GCP SDK - as your GCP user (you will need to respond to the prompts)  
2.) Create GCP project and enables required services for GKE (compute, container, iam etc)  
3.) Assign users to project / IAM permissions to users   
4.) Apply Terraform to build GKE cluster - as service specific GCP user (you will need to respond to the prompts)  
5.) Apply Helm chart to setup our webserver and configure k8s (deployment, pods, service, ingress, hpa etc)  
6.) Publish the ingress IP that will serve our site  

### **--- Requirements met: ---**     
As per PDF supplied

### **--- Improvments: (done) ---**       
- Add in Helm to group k8s resources and allow for easier deployments (done)
- Add in hpa (horizontal pod autoscaler) to show scaling on CPU / memory etc (done)

**To test the hpa:**  
$ ./stress YOUR_INGRESS_IP_HERE  
./tooling/kubectl --kubeconfig ./kubeconfig-prod get hpa  
./tooling/kubectl --kubeconfig ./kubeconfig-prod get pods  

**NOTE** that it auto scales based on CPU usage, and the number of pods will increase as this climbs

### **--- Future Improvements: (to do) ---**    
- Add in Prometheus for monitoring / metrics dashboard
- Add in persistent storage / volume claims, to ensure pod logging persists
- Adding in ELK stack for centralized logging / log interrogation
- Add SSL to ingress
- Proxy behind something like CloudFlare for DDoS protection / CDN (asset caching, speed) etc
