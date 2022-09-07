FROM etb-client-builder:latest as base 

WORKDIR /git

from base as builder

RUN git clone https://github.com/sigp/lighthouse.git && cd lighthouse && git checkout unstable

run rustup toolchain install nightly-2022-07-12

run cd lighthouse && cargo +nightly-2022-07-12 build --release --manifest-path lighthouse/Cargo.toml --target x86_64-unknown-linux-gnu --features modern --verbose --bin lighthouse
RUN cd lighthouse && git log -n 1 --format=format:"%H" > /lighthouse.version
from debian:bullseye-slim

COPY --from=builder /git/lighthouse/target/x86_64-unknown-linux-gnu/release/lighthouse /usr/local/bin/lighthouse
COPY --from=builder /lighthouse.version /lighthouse.version

ENTRYPOINT ["/bin/bash"]
