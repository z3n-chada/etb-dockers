FROM etb-client-builder:latest as base

from base as builder

WORKDIR /git

ARG GIT_BRANCH="develop"

RUN mkdir -p /git/src/github.com/prysmaticlabs/
RUN mkdir -p /build

RUN cd /git/src/github.com/prysmaticlabs/ && \
    git clone --branch "$GIT_BRANCH" \
    --recurse-submodules \
    --depth 1 \
    https://github.com/prysmaticlabs/prysm

RUN cd /git/src/github.com/prysmaticlabs/prysm && git log -n 1 --format=format:"%H" > /prysm.version
# Get dependencies
RUN cd /git/src/github.com/prysmaticlabs/prysm && go get -t -d ./... && go build -o /build ./...

from debian:bullseye-slim

COPY --from=builder /build/beacon-chain /usr/local/bin/
COPY --from=builder /build/validator /usr/local/bin/
COPY --from=builder /build/client-stats /usr/local/bin/
COPY --from=builder /prysm.version /prysm.version

ENTRYPOINT ["/bin/bash"]
