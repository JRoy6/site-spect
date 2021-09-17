default: test

.ONESHELL:

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: 
install: install_charts ports ## Install the application stack

.PHONY: 
uninstall: uninstall_charts ## Uninstall the application stack

 ## ampersand runs the command in the background
.PHONY: ports
ports:  ## port-forward pods
	kubectl port-forward deployment/elk-kibana 5601 > /dev/null & 
	kubectl port-forward deployment/elk-grafana 3000 > /dev/null &

.PHONY: 
kill_ports: ## kill the port forward commands
	ps aux | grep port-forward | grep -v "grep" | awk '{print $$2}' | xargs -n1 kill
	ps aux | grep port-forward | grep -v "grep"

## verify port connection is killed
.PHONY: install_charts
install_charts:
	helm install elk .

.PHONY: uninstall_charts
uninstall_charts:
	helm uninstall elk

.PHONY: minikube start
yeskube: ## start minikube
	minikube start

.PHONY:  minikube stop
nokube: ## stop minikube
	minikube stop

.PHONY: minikube dashboard
kubedash: ##minikube dashboard
	minikube dashboard > /dev/null 2>&1 &
