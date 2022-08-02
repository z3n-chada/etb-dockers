from etb-client-builder:latest as builder

workdir /git

run git clone https://github.com/sigp/lighthouse.git && cd lighthouse && git checkout unstable

RUN cd lighthouse && LD_LIBRARY_PATH=/usr/lib/ RUSTFLAGS="-Cpasses=sancov -Cllvm-args=-sanitizer-coverage-level=3 -Cllvm-args=-sanitizer-coverage-trace-pc-guard -Ccodegen-units=1 -Cdebuginfo=2 -L/usr/lib/ -lvoidstar" cargo build --release --manifest-path lighthouse/Cargo.toml --target x86_64-unknown-linux-gnu --features modern --verbose --bin lighthouse
RUN cd lighthouse && git log -n 1 --format=format:"%H" > /lighthouse.version

from z3nchada/etb-client-runner:latest

ENV LD_LIBRARY_PATH=/usr/lib/

COPY --from=builder /git/lighthouse/target/x86_64-unknown-linux-gnu/release/lighthouse /usr/local/bin/lighthouse
COPY --from=builder /lighthouse.version /lighthouse.version

ENTRYPOINT ["/bin/bash"]
