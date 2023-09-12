git clone https://github.com/kata-containers/kata-containers.git
cd kata-containers/tools/packaging/kata-deploy
kubectl apply -f kata-rbac/base/kata-rbac.yaml
kubectl apply -f kata-deploy/base/kata-deploy.yaml
kubectl apply -f runtimeclasses/kata-runtimeClasses.yaml
kubectl apply -f examples/test-deploy-kata-dragonball.yaml
