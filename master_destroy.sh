#!/bin/bash
./tooling/helm uninstall webserver --kubeconfig ./kubeconfig-prod
printf 'yes' | ./tooling/terraform destroy -var project_id="$1"
