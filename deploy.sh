#!/bin/bash
set -e
set -x

run_terraform(){
    rm -rf ./.terraform
    terraform init
    terraform apply -auto-approve
}

# Run Terraform against AWS root, then Kubernetes root
pushd ./terraform/roots/aws
run_terraform
popd
pushd ./terraform/roots/kubernetes
run_terraform
aws eks update-kubeconfig --name weather
kubectl apply -f aws-auth.yaml
popd

JENKINS_NAMESPACE=jenkins
JENKINS_POD=$(kubectl get pod -n ${JENKINS_NAMESPACE} | tail -n 1 | awk '{print $1}')
kubectl cp -n ${JENKINS_NAMESPACE} jenkins/plugins.txt ${JENKINS_POD}:/var/jenkins_home/
kubectl cp -n ${JENKINS_NAMESPACE} jenkins/casc.yaml ${JENKINS_POD}:/var/jenkins_home/
kubectl cp -n ${JENKINS_NAMESPACE} jenkins/WeatherPipeline ${JENKINS_POD}:/var/jenkins_home/jobs/
kubectl exec -it -n ${JENKINS_NAMESPACE} ${JENKINS_POD} -- /bin/jenkins-plugin-cli -f /var/jenkins_home/plugins.txt -d /var/jenkins_home/plugins
kubectl scale deployment -n jenkins jenkins --replicas=0
kubectl scale deployment -n jenkins jenkins --replicas=1
sleep 5
NEW_POD=$(kubectl get pod -n ${JENKINS_NAMESPACE} | tail -n 1 | awk '{print $1}')

# Wait for Jenkins to be fully active
set +e
ITS_UP=0

echo Giving new Jenkins pod time to do its thing..
sleep 20

for i in {0..30}; do
    echo Polling Jenkins logs, attempt $i
    kubectl logs -n ${JENKINS_NAMESPACE} ${NEW_POD} | grep "Jenkins is fully up and running"
    if [ $? -eq 0 ]; then
        ITS_UP=1
        break
    fi
    sleep 5
done

if [[ ITS_UP -eq 0 ]]; then
    echo "Something might be wrong with Jenkins"
    exit 1
fi

# Get admin username and password, then kick off job
set -e

JENKINS_USER=$(kubectl get secret -n ${JENKINS_NAMESPACE} admin-password -o yaml | grep "username:" | awk '{print $2}' | base64 -d)
JENKINS_PASSWORD=$(kubectl get secret -n ${JENKINS_NAMESPACE} admin-password -o yaml | grep "password:" | awk '{print $2}' | base64 -d)
AUTH="${JENKINS_USER}:${JENKINS_PASSWORD}"

echo "Just wait a little while longer because it's Jenkins..."
sleep 30
curl -X GET --user $AUTH https://jenkins.davidjoliver86.xyz/job/WeatherPipeline/build?token=ImMrMeeseeks