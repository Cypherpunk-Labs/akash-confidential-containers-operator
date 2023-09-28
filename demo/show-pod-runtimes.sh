kubectl get po --sort-by='.spec..runtimeClassName' -A -o json |\
 jq -r '[.items[] | {name:.metadata.name, ns:.metadata.namespace, class:.spec.runtimeClassName}]' |\
 jq -r '"name\tnamespace\tclass",
        "----\t----------\t-----",
        ( .[] | "\(.name)\t\(.ns)\t\(.class)" )' |\
column -t -s $'\t'
