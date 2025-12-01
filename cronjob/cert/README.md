# Cert Secrets Garbage Collector

This image deletes unused secrets from the cluster

## Run the image in a cluster

This image needs access secrets and ingresses. So here we use service account `my-account` in namespace `my-namespace` which has the needed rights

```
kubectl run -n my-namespace test-cert-secrets-gc --rm -i --image=ghcr.io/cooptilleuls/sre/minimal/cronjob-cert-secrets-gc:latest --overrides='{ "spec": { "serviceAccountName": "my-account" } }'
```

## Run the image from local environment (outside the cluster)

### Build the image which includes gcloud sdk and aws cli

The minimal image on the registry can not authenticate on google cloud. If you want to use it, you need to build the fat image which includes gcloud sdk

```
docker build --network host -t cert-secrets-gc-fat .
```

### Run the fat image to connect to clusters using gcloud or aws cli

You can now run the image. Be sure to mount any relevant config as a volume in the container

```
docker run --network host -v ~/.kube:/root/.kube -v ~/.config/gcloud:/root/.config/gcloud -v ~/.aws:/root/.aws -it --rm cert-secrets-gc-fat
```
