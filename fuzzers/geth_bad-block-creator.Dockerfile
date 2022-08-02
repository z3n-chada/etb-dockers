FROM etb-client-builder as builder

RUN git clone https://github.com/MariusVanDerWijden/go-ethereum.git \
    && cd go-ethereum \
    && git checkout merge-bad-block-creator \
    && make geth

FROM etb-client-runner

COPY --from=builder /git/go-ethereum/build/bin/geth /usr/local/bin/geth-bad-block

ENTRYPOINT ["/bin/bash"]
