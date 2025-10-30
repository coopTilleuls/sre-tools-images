FROM debian:bookworm-slim AS build
RUN apt-get update -y  && apt-get upgrade -y  && apt-get install curl -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    chmod +x kubectl && mv kubectl /usr/bin/

FROM debian:bookworm-slim AS cronjob
COPY --from=build /usr/bin/kubectl /usr/bin/kubectl
COPY --from=ghcr.io/jqlang/jq:latest /jq /usr/bin/jq
COPY --chmod=0755 cert-secrets-gc.sh /usr/local/bin/cert-secrets-gc.sh 
ENV PATH="/usr/local/bin:${PATH}"
ENTRYPOINT [ "cert-secrets-gc.sh" ]
CMD [ "--dry" ]

# Fat image includes gcloud
FROM google/cloud-sdk:latest AS cloud-sdk-base
RUN apt-get update && apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin

FROM cronjob AS cronjob-gcloud
RUN apt-get update -y  && apt-get upgrade -y  && apt-get install python3 -y
COPY --from=cloud-sdk-base /usr/lib/google-cloud-sdk /usr/lib/google-cloud-sdk
ENV CLOUDSDK_ROOT_DIR="/usr/lib/google-cloud-sdk"
ENV PATH="${CLOUDSDK_ROOT_DIR}/bin:${PATH}"
