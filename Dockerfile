# Install required libraries
FROM golang:1.11.1-alpine AS builder

RUN apk add --no-cache git=2.18.4-r0 build-base=0.5-r1 && \
    rm -rf /var/lib/apt/lists/* 

RUN git clone https://github.com/google/jsonnet.git && \
    make -C jsonnet 
    
RUN go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb && \
    jb init && \
    jb install https://github.com/grafana/grafonnet-lib/grafonnet

# Create image for dashboard generation
FROM node:10-alpine
LABEL maintainer="corentin.altepe@gmail.com"

RUN apk add --no-cache libstdc++ ca-certificates && \
  # Specific for Azure DevOps pipelines.
  # See: https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#add-requirements
  apk add bash sudo shadow

WORKDIR /dashboards

COPY --from=builder /go/vendor vendor
COPY --from=builder /go/jsonnet/jsonnet /usr/local/bin/

ENV JSONNET_PATH=/dashboards/vendor

# Specific for Azure DevOps
# See: https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops#tell-the-agent-about-nodejs
LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"
CMD [ "node" ]
