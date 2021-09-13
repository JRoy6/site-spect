# site-spect - k8s exercise

S1. Create repo for site-spect.
S2. Create ssh key(github only accepts keys now instead of credentials)
S3. Install microk8s. Click [here](https://microk8s.io/docs/install-alternatives) for installation tutorial
# Spent some time understanding microk8s
# Used minikube to deploy ELK stack. 
# Deployment using microk8s takes up too much time
S4.Install minikube.
S5.Install helm. Click [here](https://logz.io/blog/deploying-the-elk-stack-on-kubernetes-with-helm) for deploying ELK stack on k8s
S6.Add helm.elastic repo. Click [here](https://github.com/elastic/helm-charts) for third-party helm charts
S7.Download helm config for elasticsearch cluster on minikube
S8.Install helm config for elasticsearch(Should receive output for pods deployed)
S9.Verify pods deployed
S10.Port forward elasticsearch cluster
S11. Verify pods are running.(Hit the targeted IP).
S12.Install helm config for kibana. 
# Received insufficent cpu error when installing kibana
S18.Port forward kibana pod
S19.Install logstash helm config
S20. Install filebeat.
#filebeat used to ship logs from k8s to kibana
#spent some time troubleshooting
