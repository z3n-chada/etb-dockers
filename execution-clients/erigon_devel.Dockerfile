from etb-client-builder:latest as builder

workdir /git

arg erigon_branch="devel"

run mkdir -p /build

run git clone --depth 1 --recurse-submodules -j8 \
	https://github.com/ledgerwatch/erigon.git -b ${erigon_branch}

run cd erigon/ \
    && make erigon

RUN cd erigon && git log -n 1 --format=format:"%H" > /erigon.version
from debian:bullseye-slim

copy --from=builder /git/erigon/build/bin/erigon /usr/local/bin/erigon
COPY --from=builder /erigon.version /erigon.version

ENTRYPOINT ["/bin/bash"]
