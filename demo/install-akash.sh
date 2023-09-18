kubectl create ns akash-services
kubectl label ns akash-services akash.network/name=akash-services akash.network=true

kubectl create ns lease
kubectl label ns lease akash.network=true

sudo snap install helm --classic
helm repo add akash https://akash-network.github.io/helm-charts

sudo apt update && sudo apt install jq unzip -y
cd ~
sudo curl -sfL https://raw.githubusercontent.com/akash-network/provider/main/install.sh | bash

export AKASH_KEYRING_BACKEND=test
export AKASH_KEYNAME=default
#provider-services keys add default
bin/provider-services keys add default 2>&1 | tee -a provider-wallet.txt
#provider-services keys export default
export AKASH_KEY_PASSWORD=$(echo "akash$RANDOM$RANDOM")
echo "$AKASH_KEY_PASSWORD" | bin/provider-services keys export default 2> akash.key.pem

## Get details of network from https://github.com/akash-network/net
export AKASH_CHAIN_ID=sandbox-01
export AKASH_NODE=https://rpc.sandbox-01.aksh.pw:443
export AKASH_GAS=auto
export AKASH_GAS_PRICES=0.025uakt
export AKASH_GAS_ADJUSTMENT=1.5

IFS=':' read -ra WALLETRESULT <<< $(cat provider-wallet.txt | grep address)
#echo "${result[1]}"
export AKASH_ACCOUNT_ADDRESS="$(echo ${WALLETRESULT[1]} | xargs)"

export AKASH_PROVIDER_DOMAIN=sb01.cypherpunklabs.uk


# fund account else get this error 'Error: rpc error: code = NotFound desc = rpc error: code = NotFound desc = account akash1yxj968trypsmhj4wqeml7tdp2s0dtrdhmc5kqs not found: key not found'
curl 'https://faucet.sandbox-01.aksh.pw/faucet' \
  -H 'authority: faucet.sandbox-01.aksh.pw' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'cache-control: max-age=0' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'origin: https://faucet.sandbox-01.aksh.pw' \
  -H 'referer: https://faucet.sandbox-01.aksh.pw/' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' \
  --data-raw "address=$AKASH_ACCOUNT_ADDRESS" \
  --compressed ;


cat > provider.yaml << EOF
---
from: "$AKASH_ACCOUNT_ADDRESS"
key: "$(cat ~/akash.key.pem | openssl base64 -A)"
keysecret: "$(echo $AKASH_KEY_PASSWORD | openssl base64 -A)"
domain: "$AKASH_PROVIDER_DOMAIN"
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

helm upgrade --install akash-provider akash/provider -n akash-services -f provider.yaml \
--set bidpricescript="$(wget https://raw.githubusercontent.com/akash-network/helm-charts/main/charts/akash-provider/scripts/price_script_generic.sh && cat price_script_generic.sh | openssl base64 -A)" \
--set chainid=sandbox-01 \
--set image.tag=0.4.6

##### Debug steps
# helm uninstall akash-provider -n akash-services
# kubectl -n akash-services logs -l app=akash-provider -c init --tail 200 -f
# kubectl get pods -n akash-services
# kubectl describe -n akash-services pod akash-provider-0

helm install akash-hostname-operator akash/akash-hostname-operator -n akash-services

cat > ingress-nginx-custom.yaml << EOF
controller:
  service:
    type: ClusterIP
  ingressClassResource:
    name: "akash-ingress-class"
  kind: DaemonSet
  hostPort:
    enabled: true
  admissionWebhooks:
    port: 7443
  config:
    allow-snippet-annotations: false
    compute-full-forwarded-for: true
    proxy-buffer-size: "16k"
  metrics:
    enabled: true
  extraArgs:
    enable-ssl-passthrough: true
tcp:
  "8443": "akash-services/akash-provider:8443"
EOF

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --version 4.7.1 \
  --namespace ingress-nginx --create-namespace \
  -f ingress-nginx-custom.yaml

