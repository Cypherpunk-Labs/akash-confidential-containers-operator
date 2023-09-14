kubectl create ns akash-services
kubectl label ns akash-services akash.network/name=akash-services akash.network=true

kubectl create ns lease
kubectl label ns lease akash.network=true

sudo snap install helm --classic
helm repo add akash https://akash-network.github.io/helm-charts


export AKASH_CHAIN_ID=sandbox-01
export AKASH_NODE=https://rpc.sandbox-01.aksh.pw:443
export AKASH_GAS=auto
export AKASH_GAS_PRICES=0.025uakt
export AKASH_GAS_ADJUSTMENT=1.5

export ACCOUNT_ADDRESS=REDACTED
export KEY_PASSWORD=REDACTED
export DOMAIN=sb01.cypherpunklabs.uk


cat > provider.yaml << EOF
---
from: "$ACCOUNT_ADDRESS"
key: "$(cat ~/akash.key.pem | openssl base64 -A)"
keysecret: "$(echo $KEY_PASSWORD | openssl base64 -A)"
domain: "$DOMAIN"
node: "$AKASH_NODE"
withdrawalperiod: 12h
attributes:
  - key: region
    value: "England, United Kingdom"
  - key: host
    value: akash
  - key: tier
    value: community
  - key: organization
    value: "CypherPunk Labs"
EOF


kubectl apply -f https://raw.githubusercontent.com/akash-network/provider/v0.4.6/pkg/apis/akash.network/crd.yaml

#helm install akash-provider akash/provider -n akash-services -f provider.yaml

# helm uninstall akash-provider -n akash-services
# kubectl -n akash-services logs -l app=akash-provider -c init --tail 200 -f

helm upgrade --install akash-provider akash/provider -n akash-services -f provider.yaml \
--set bidpricescript="$(wget https://raw.githubusercontent.com/akash-network/helm-charts/main/charts/akash-provider/scripts/price_script_generic.sh && cat price_script_generic.sh | openssl base64 -A)" \
--set chainid=sandbox-01 \
--set image.tag=0.4.6


helm install akash-hostname-operator akash/akash-hostname-operator -n akash-services