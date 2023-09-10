# Akash confidential containers operator

The goal of this project is to provide a Kubernetes Operator that can mutate a Deployment into a confidential container. This will allow Akash Providers to offer customisations to their users. In order to do this, we leverage the existing Akash SDL spec and find utility in providing unofficial support via the Environments Variables. The operator will detect this custom variable and mutate the Deployment to add runtimeClassName to the kubernetes manifest. This method could also be used for any preview features a provider may wish to introduce to their users.

Once the pre-reqs and operator are installed, Any Akash SDL bid that is deployed with the Environment Variable named "KATA" will be upgraded to run with "kata-qemu" as the runtimeClassName. This will run the container with that level of VM isolation. The application owner will need to find a way to attest the integrity of the runtime environment before they carry out secure operations like handle secure keys for encryption routines. 

## Project Status

This project is a work in progress.

## Usage

## setup_and_prerequisites

### Prerequisites

- Kubernetes 1.16+ (tested with k3s)
- Kustomize 3.5.4+
- kubectl

### MacOS

- brew install operator-sdk kubebuilder kustomize

### kubernetes_node_prerequisites

- [Ubuntu] sudo snap install kata-containers --classic
- https://github.com/kata-containers/kata-containers/blob/3.1.3/tools/packaging/kata-deploy/README.md
    - $ git clone github.com/kata-containers/kata-containers
    - $ cd kata-containers/kata-containers/tools/packaging/kata-deploy
    - $ kubectl apply -f kata-rbac/base/kata-rbac.yaml
    - $ kubectl apply -k kata-deploy/overlays/k3s
- kubectl apply -f https://raw.githubusercontent.com/kata-containers/kata-containers/main/tools/packaging/kata-deploy/runtimeclasses/kata-runtimeClasses.yaml
- systemctl restart k3s.service

## developer quick steps

This will run the operator in developer mode from your IDE, external to your cluster.

- git clone git@github.com:Cypherpunk-Labs/akash-confidential-containers-operator.git
- cd akash-confidential-containers-operator
- make install run


## OLM Bundle install

- operator-sdk olm install
- make deploy IMG="ghcr.io/cypherpunk-labs/akash-confidential-containers-operator:v0.0.1"

The following image has been made public so no login is required.

- ghcr.io/cypherpunk-labs/akash-confidential-containers-operator:v0.0.1

## OLM Bundle uninstall

- make undeploy
- operator-sdk olm uninstall # warning this will remove all operators using this deployment method.

## Testing

```
make test
go tool cover -html=cover.out -o cover.html
```

## My Versions

Date: 06 September 2023

$ operator-sdk version
```
operator-sdk version: "v1.31.0", commit: "e67da35ef4fff3e471a208904b2a142b27ae32b1", kubernetes version: "v1.26.0", go version: "go1.20.6", GOOS: "darwin", GOARCH: "arm64"
```

$ go version
```
go version go1.21.0 darwin/arm64
```

$ kubectl version
```
Client Version: version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.1", GitCommit:"4c9411232e10168d7b050c49a1b59f6df9d7ea4b", GitTreeState:"clean", BuildDate:"2023-04-14T13:14:41Z", GoVersion:"go1.20.3", Compiler:"gc", Platform:"darwin/arm64"}
Kustomize Version: v5.0.1
Server Version: version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.4+k3s1", GitCommit:"36645e7311e9bdbbf2adb79ecd8bd68556bc86f6", GitTreeState:"clean", BuildDate:"2023-07-28T09:46:04Z", GoVersion:"go1.20.6", Compiler:"gc", Platform:"linux/amd64"}
```

$ kubebuilder version
```
Version: main.version{KubeBuilderVersion:"3.11.1", KubernetesVendor:"unknown", GitCommit:"1dc8ed95f7cc55fef3151f749d3d541bec3423c9", BuildDate:"2023-07-03T12:58:51Z", GoOs:"darwin", GoArch:"arm64"}
```

$ kustomize version
```
v5.1.1
```