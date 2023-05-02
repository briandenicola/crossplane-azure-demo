# Overview

This repository is a demonstration of using Crossplane/Upbound in Azure on AKS. It is currently a work in progress

* [Crossplane](https://www.crossplane.io/) is an open source Kubernetes add-on that transforms your cluster into a universal control plane. Crossplane enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.
* [Crossplane with Kubevela](https://kubevela.io/docs/platform-engineers/crossplane/)

# Long Term Vision
![overview](./assets/backstage-crossplane.png)
---

# Prerequisites 
* Azure Subscription
* [Azure Cli](https://github.com/briandenicola/tooling/blob/main/azure-cli.sh)
* [Terraform](https://github.com/briandenicola/tooling/blob/main/terraform.sh)
* [Task](https://github.com/briandenicola/tooling/blob/main/task.sh)
* [Upbound Cli](https://github.com/briandenicola/tooling/blob/main/upbound.sh)

# Quicksteps
```bash
    az login --scope https://graph.microsoft.com/.default
    task up
```

# Sample AKS Cluster Deployed via Crossplane
```bash
    #Create a simple resource group
    kubectl apply -f ./manifests/crossplane/resourcegroup.yaml

    #Create a virtual network and AKS cluster named aks02
    kubectl apply -f ./manifests/crossplane/akscluster.yaml

    kubectl get kubernetescluster
    NAME    READY   SYNCED   EXTERNAL-NAME   AGE
    aks02   True    True     aks02           13m

    #Make a Claim against a Composite Resource (XR)
    kubectl apply -f ./manifests/crossplane/composite/
    kubectl get compositeresourcedefinition.apiextensions.crossplane.io xclusters.aks.bjdazure.tech
    NAME                                     ESTABLISHED   OFFERED   AGE
    xaksclusters.containers.bjdazure.tech    True          True      62s

    kubectl get compositions
    NAME           AGE
    xcluster-dev   6m50s

    kubectl apply -f ./manifests/crossplane/aksclaim.yaml

    kubectl get aksclusters.containers.bjdazure.tech/aks03
    NAME    SYNCED   READY   CONNECTION-SECRET   AGE
    aks03   True     False                       32s

    ...
    kubectl get aksclusters.containers.bjdazure.tech/aks03
    NAME    SYNCED   READY   CONNECTION-SECRET   AGE
    aks03   True     True                        32s

    kubectl get  resourcegroup,virtualnetwork,subnet,kubernetes
    NAME    READY   SYNCED   EXTERNAL-NAME   AGE
    aks03   True    True     aks03           13m
```

# Additional References
## Crossplane
* https://docs.crossplane.io/v1.11/concepts/terminology/
* https://docs.crossplane.io/v1.10/cloud-providers/azure/azure-provider/
* https://docs.crossplane.io/v1.11/concepts/composition/
* https://github.com/PacktPublishing/End-to-End-Automation-with-Kubernetes-and-Crossplane/tree/main/Chapter09/Hand-on-examples
* https://marketplace.upbound.io/providers/upbound/provider-azure/
* https://github.com/vfarcic/devops-toolkit-crossplane
## Other
* https://gist.github.com/vfarcic/6d40ff0847a41f1d1607f4df73cd5bad
* https://open-cluster-management.io/
* https://cuelang.org/
* https://www.youtube.com/watch?v=Ii-lpLuzPxw

# Backlog
- [X] Learn Crossplane
- [ ] Add GitOps/Kubevela to Workload cluster
- [ ] Add Backstage
- [ ] Update automation to deploy app from Backstage to newly created cluster through Crossplane and Flux
