#!/bin/bash
# set -e
# set -x

if [[ "$1" == "--help" ]]; then
    echo "Usage: cert-secrets-gc.sh [option]"
    echo "Option:"
    echo "  --help            Show this help message"
    echo "  --dry             Dry run. Dont delete secrets"
    echo "  --filter <regex>  A regex expression used to filter secrets"
    exit 0
fi

if [[ "$1" == "--filter" ]]; then
    SECRET_ANNOTATION_FILTER=$2
fi

log_event() {
    local message="$1"
    local level="$2"
    local now=$(date -u --date='now' +%Y-%m-%dT%H:%M:%SZ)
    local secret_name="${3:-"default"}"
    local secret_namespace="${4:-"default"}"
    local event_name="cert-secrets-gc-$(date -u +%s%N)"
    local host_name=$(hostname -s)
    local template=$(cat Event.template.json)
    template=${template//\{\{message\}\}/$message}
    template=${template//\{\{warning-level\}\}/$level}
    template=${template//\{\{first-timestamp\}\}/$JOBSTART}
    template=${template//\{\{last-timestamp\}\}/$now}
    template=${template//\{\{secret-name\}\}/$secret_name}
    template=${template//\{\{secret-namespace\}\}/$secret_namespace}
    template=${template//\{\{event-name\}\}/$event_name}
    template=${template//\{\{host-name\}\}/$host_name}
    echo "$template" | kubectl create -f -
}

# cert should have been renewed before this date
# if it's not we delete the secret
RENEWAL_DATE=$(date -d "@$(( $(date +%s) - 14 * 24 * 60 * 60 ))" +%s)

# secrets referenced in certificates
kubectl get certificates  -A  -o json  | jq  -r ".items[] | ( .metadata.namespace + \"/\" + .spec.secretName  )" >/tmp/secrets_from_certs

# secrets managed by cert manager and NOT referenced in certs
kubectl get secrets -A -o json | jq  -r '.items[] | select( .metadata.annotations["cert-manager.io/issuer-group"] == "cert-manager.io" and .type == "kubernetes.io/tls" ) | (.metadata.namespace + "/" + .metadata.name )' | grep -x -v -f /tmp/secrets_from_certs >/tmp/abandoned

# secrets currently used by ingress
kubectl get ing -A -o  go-template='{{range .items}}{{$namespace := .metadata.namespace}}{{range .spec.tls }}{{$namespace}}/{{ .secretName }}{{ end }}{{printf "\n"}}{{ end}}' | sed -e '/^$/d; /<no value>/d' > /tmp/used

# secrets from certificates not renewed
# we ignore certificates without renewalTime
kubectl get certificates  -A  -o json  | jq  -r ".items[] | select( .status.renewalTime | select(type == \"string\") | fromdateiso8601 < $RENEWAL_DATE ) | ( .metadata.namespace + \"/\" + .spec.secretName  )" >/tmp/not_renewed

#  get list of unused secrets
grep -v -x -f /tmp/used /tmp/not_renewed > /tmp/unused || echo "secrets not renewed not found"
grep -v -x -f /tmp/used /tmp/abandoned >> /tmp/unused || echo "secrets without certs not found"
# if there's a filter we use it restrictively
# if it returns nothing, we don't delete secrets
if [ -n "$SECRET_ANNOTATION_FILTER" ]; then cat /tmp/unused | grep "$SECRET_ANNOTATION_FILTER" >/tmp/unused_filtered ; mv /tmp/unused_filtered /tmp/unused; fi

for CERT in $(cat /tmp/unused ) ; do
  NAMESPACE=$${CERT%%/*}
  SECRET=$${CERT##*/}
  if kubectl -n $${NAMESPACE} get secret/$${SECRET} &>/dev/null ; then
     if [[ "$1" == "--dry" ]]; then
         echo "Not deleting $${NAMESPACE}}/$${SECRET}"
     else
         echo "Deleting $${NAMESPACE}}/$${SECRET}"
         log_event "Deleting secret  $${NAMESPACE}}/$${SECRET}" "Warning" $${SECRET} $${NAMESPACE}
         kubectl -n $${NAMESPACE} delete secret/$${SECRET}
     fi
  fi
done
