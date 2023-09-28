kubectl apply -k github.com/confidential-containers/operator/config/release?ref=v0.7.0
sleep 60
kubectl apply -k github.com/confidential-containers/operator/config/crd
kubectl apply -k github.com/confidential-containers/operator/config/samples/ccruntime/default