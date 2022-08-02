from etb-client-builder:latest as base

from base as builder

RUN mkdir -p /go/src/github.com/ethereum/ 
WORKDIR /go/src/github.com/ethereum/

ARG GETH_BRANCH="master"

RUN git clone https://github.com/ethereum/go-ethereum \
    && cd go-ethereum \
    && git checkout ${GETH_BRANCH} 

RUN cd go-ethereum \
    && go install ./...
    
RUN cd go-ethereum && git log -n 1 --format=format:"%H" > /geth.version

from debian:bullseye-slim

COPY --from=builder /root/go/bin/geth /usr/local/bin/geth
COPY --from=builder /root/go/bin/bootnode /usr/local/bin/bootnode
COPY --from=builder /geth.version /geth.version


ENTRYPOINT ["/bin/bash"]
