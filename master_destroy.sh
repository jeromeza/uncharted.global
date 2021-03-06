#!/bin/bash
# Check for project argument as $1 - if not present, abort
if [ -z "$*" ]; then echo "Please specify a unique project name" && exit 0; fi

# Remove helm chart and perform terraform destroy
./tooling/helm uninstall webserver --kubeconfig ./kubeconfig-prod
./tooling/helm uninstall prometheus-operator -n monitor --kubeconfig ./kubeconfig-prod
./tooling/kubectl --kubeconfig ./kubeconfig-prod delete -f prometheus_chart/templates/ingress.yml
sleep 60
printf 'yes' | ./tooling/terraform destroy -var project_id="$1"
