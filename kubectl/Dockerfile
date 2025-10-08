FROM debian:bookworm-slim AS build
RUN apt update -y  && apt upgrade -y  && apt install curl jq -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    chmod +x kubectl && mv kubectl /usr/bin/

FROM debian:bookworm-slim as debian-kubectl
COPY --from=build /usr/bin/kubectl /usr/bin/kubectl
ENTRYPOINT [ "kubectl" ]
CMD [ "--help" ]

FROM scratch as kubectl-mini
COPY --from=build /usr/bin/kubectl /
ENTRYPOINT [ "/kubectl" ]
CMD [ "--help" ]
