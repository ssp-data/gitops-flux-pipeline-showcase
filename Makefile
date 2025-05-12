# Flux Infrastructure Makefile

.PHONY: help reconcile reconcile-all status check logs diff suspend resume

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

reconcile: ## Reconcile flux-system kustomization with source
	flux reconcile kustomization flux-system --with-source

reconcile-all: ## Reconcile all kustomizations with source
	flux reconcile kustomization --all --with-source

status: ## Get status of all Flux resources
	flux get all

check: ## Check Flux installation
	flux check

logs: ## Get logs from Flux controllers
	kubectl -n flux-system logs -l app=helm-controller -f
	kubectl -n flux-system logs -l app=source-controller -f
	kubectl -n flux-system logs -l app=kustomize-controller -f

kestra-logs: ## Get logs from Kestra pods
	kubectl logs -l app.kubernetes.io/name=kestra -f

diff: ## Show diff between live and Git state
	flux diff kustomization flux-system --path=./clusters/my-cluster

suspend: ## Suspend reconciliation of all resources
	flux suspend kustomization --all

resume: ## Resume reconciliation of all resources
	flux resume kustomization --all

get-helmreleases: ## List all HelmReleases
	flux get helmreleases -A

get-sources: ## List all sources (Git, Helm)
	flux get sources all -A

port-forward-kestra: ## Port forward Kestra UI to localhost:8080
	kubectl port-forward svc/kestra 8080:8080