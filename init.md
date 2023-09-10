
Date: 30th Aug 2023
OS: Mac Ventura 13.4
operator-sdk version: "v1.29.0", commit: "78c564319585c0c348d1d7d9bbfeed1098fab006", kubernetes version: "v1.26.0", go version: "go1.20.4", GOOS: "darwin", GOARCH: "arm64"

References: 
- https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/

# Notes

We scaffold the operator using the following command:

```
operator-sdk init --domain cypherpunk.io --repo github.com/Cypherpunk-Labs/akash-confidential-containers-operator 
```
#--plugins go.kubebuilder.io/v4-alpha --skip-go-version-check

Then create our shim API and then modify our SetupWithManager to watch the resource we are interested, which is Deployments.

```
operator-sdk create api --group=preview --version=v1 --kind=Confidential --controller=true --resource=true
```

edit Controllers > confidential_controller.go
add imports 
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
edit SetupWithManager from 
    For(&previewv1.Confidential{}).
to this 
    For(&appsv1.Deployment{}).
edit reconcile to have
    	log.Log.Info(req.Name)

```
make install run 
```






--- 

# scratchpad

<!-- operator-sdk create api --group=apps --version=v1 --kind=Deployment --controller=true --resource=false -->

<!-- operator-sdk create api \
    --group=apps \
    --version=v1 \
    --kind=Deployment \
    --controller

    --resource \ -->

<!-- // Create mutating webhook for deployments via operator-sdk 
operator-sdk create webhook --group apps --version v1 --kind Deployment --defaulting --programmatic-validation

// Create validating webhook for deployments via operator-sdk 
operator-sdk create webhook --group apps --version v1 --kind Deployment --validation --programmatic-validation -->


