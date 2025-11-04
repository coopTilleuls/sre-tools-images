FROM debian:bookworm-slim AS build
ARG KUBECTL_VERSION 
RUN apt update -y  && apt upgrade -y  && apt install curl -y
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"  && \
	curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" && \
	echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
	chmod +x kubectl && mv kubectl /usr/bin/

FROM debian:bookworm-slim AS kubectl-mini
COPY --from=build /usr/bin/kubectl /usr/bin/kubectl
ENTRYPOINT [ "kubectl" ]
CMD [ "--help" ]

FROM ghcr.io/jqlang/jq:latest AS jq

FROM kubectl-mini AS debian-kubectl
COPY --from=jq /jq /usr/bin/jq
