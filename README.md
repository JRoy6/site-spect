# site-spect-K8s exercise

## Requirements
* Docker version >= 20.10.8
* Helm >= v3.6.3
* Kubernetes >= 1.22.1 

## How To
* cd to where you want to clone the repo
* clone the repo
    - git clone git@github.com:JRoy6/site-spect.git
* cd into site-spect
* run "make install"
    - Stack will be deployed and ports will be forwarded.
* go to [grafana dashboard for k8s cluster](http://127.0.0.1:3000/d/efa86fd1d0c121a26444b636a3f509a8/kubernetes-compute-resources-cluster?orgId=1&refresh=10s)
    - [grafana dashboard for individual pods](http://127.0.0.1:3000/d/85a562078cdf77779eaa1add43ccec1e/kubernetes-compute-resources-namespace-pods?orgId=1&refresh=10s)
    - this assumes you are running docker for mac. Change ip if necessary
* go to [kibana dashboard](http://127.0.0.1:5601/)
    - login: admin/prom-operator
* go to k8s dashboard
    - in a new shell, run "make kubedash"
* run "make uninstall" to destroy cluster.

## To-Do 
    - Use helm dependicies

## Day 1 (~4hrs)
### S1. Start with creating a repo for site-spect.
### S2. Create an ssh key.
    - GitHub now only accepts ssh keys instead of user credentials.
### S3. Install microk8s for macOS. [Microk8s installation](https://microk8s.io/docs/install-alternatives) 
    - Spent some time understanding microk8s.
    - Deployment using microk8s was taking too long.
    - Switched to minikube.
### S4. Install minikube. [Minikube installation](https://minikube.sigs.k8s.io/docs/start/) 
    - curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
    - sudo install minikube-darwin-amd64 /usr/local/bin/minikube
    - Pods were unstable.
    - Restarted minikube with new resources.
    - minikube start --memory 7900 --cpus 4
### S5. Install helm.  [Helm charts installation](https://logz.io/blog/deploying-the-elk-stack-on-kubernetes-with-helm)
### S6. Add helm repo. [Helm chart repo](https://github.com/elastic/helm-charts) 
### S7. Download helm config for elasticsearch cluster on minikube.
    - curl -O https://raw.githubusercontent.com/elastic/Helm-charts/master/elasticsearch/examples/minikube/values.yaml
### S8. Install helm config for elasticsearch.
    - helm install elasticsearch elastic/elasticsearch -f elasticsearch.yaml
    - Should receieve output for pods deployed.
    - There were lots of example "values.yaml" files.
    - I used the ones that seemed appropriate.
### S9. Verify pods deployed.
    - kubectl get pods
### S10. Port forward elasticsearch cluster.
    - kubectl port-forward svc/elasticsearch-master 9200
### S11. Verify pods are running.
    - Use URL from port forward output.
### S12. Install helm config for kibana.
    - helm install kibana elastic/kibana.
    - No values.yaml that seemed necessary so didn't use. 
    - Received insufficent cpu error when installing kibana.
    - Discovered minikube was not running as a container.
### S18. Port forward kibana pod.
    - kubectl port-forward deployment/kibana 5601
### S19. Install logstash helm config
    - Helm install logstash elastic/logstash -f logstash.yaml
    - Becareful not to override .yaml files when downloading.
    - Default .yaml filename "values.yaml"
## Day 2 (~5hrs)
### S20. Install filebeat.
    - helm install filebeat elastic/filebeat -f filebeat.yaml
    - Filebeat used to ship logs from k8s to kibana.
    - Spent some time troubleshooting.
    - Had to deploy in kube-system namespace
    - Received connection refused error. Found solution on Google.
    - Had to edit .yaml file. "hosts: 'elasticsearch-master.default.svc.cluster.local:9200'"
### S21. Install prometheus/grafana stack repos. [Prom/grafana repos](https://prometheus-community.github.io/helm-charts)
    - helm install prometheus prometheus-community/kube-prometheus-stack.
    - Spent some time troubleshooting prometheus/grafana.
    - Pods were crazy then stabilized. 
### S22. Port forward grafana
    - kubectl port-forward deployment/prometheus-grafana 3000
    - Have to keep the command running
### S23. Login to grafana ui.
    - admin/prom-operator
* Spent time troubleshooting minikube CPU & Memory usage.
    - Fixed by restarting minikube with new resources.
    - Command on step 4.
## Day 3 (~2hrs)
 * Spent time figuring how prometheus is configured.
    - [Prometheus explained](https://www.youtube.com/watch?v=h4Sl21AKiDg&list=PLbookXju_sYAMfKgB93dcXMUUpmjO3Zmx&index=29)
    - [Prometheus using helm](https://www.youtube.com/watch?v=QoDqxm7ybLc&t=877s)
    - Its configured out the box to scrape from  k8s and itself.
 * Found commands useful for looking deeper into how its configured. 
    - kubectl describe deployment prometheus-kube-prometheus-operator
    - kubectl describe statefulset prometheus-prometheus-kube-prometheus-prometheus
 * Statefulset holds configs that shows things like  mounted volumes, etc
    - kubectl get secret prometheus-prometheus-kube-prometheus-prometheus -o yaml
    - kubectl get configmap prometheus-prometheus-kube-prometheus-prometheus-rulefiles-0 -o yaml
    - kubectl get secret prometheus-prometheus-kube-prometheus-prometheus -o json | jq -r '.data | .[]'
## Day 4 (~6hrs)
 * Spent time reading documentation on helm. 
    - [helm charts and subcharts](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/)
### S24. Create helm chart and subcharts to deploy ELK stack and prom/grafana at once.
    - helm create elk
### S25. Pull helm charts for prom/grafana and ELK stack into repo.
    - Cd into charts/directory and pull third-party charts
    - helm pull prometheus-community/kube-prometheus-stack --untar
    - helm pull elastic/filebeat --untar
    - helm pull elastic/logstash --untar
    - helm pull elastic/kibana --untar
    - helm pull elastic/elasticsearch --untar
* Replace the contents elk/values.yaml with custom configurations you need.
    - [subchart configurations](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/#overriding-values-from-a-parent-chart)
* Forward ports needed
    - kubectl port-forward deployment/elk-grafana 3000
    - kubectl port-forward deployment/elk-kibana 5601
### S26. Create Makefile to make things easier.
    - Commands to forward the ports and keep it running in the background.
    - Ugly way of killing port-forward commands.
