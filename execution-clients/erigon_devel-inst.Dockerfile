from etb-client-builder:latest as builder

workdir /git

arg erigon_branch="devel"

run mkdir -p /build

# TODO: Adding --depth 1 sometimes causes issues for some reason
run git clone --recurse-submodules -j8 \
	https://github.com/ledgerwatch/erigon.git -b ${erigon_branch}


# add items to this exclusions list to exclude them from instrumentation
RUN touch /opt/antithesis/go_instrumentation/exclusions.txt
# Ignore files with special `// go:` comments due to this issue: https://trello.com/c/Wmaxylu9
RUN cd erigon && grep -l -r go: | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt
RUN cd erigon && grep -l -r snappy | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt

# Antithesis -------------------------------------------------
WORKDIR /git
RUN mkdir -p erigon_instrumented && LD_LIBRARY_PATH=/opt/antithesis/go_instrumentation/lib /opt/antithesis/go_instrumentation/bin/goinstrumentor -antithesis=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers/ -exclude=/opt/antithesis/go_instrumentation/exclusions.txt -stderrthreshold=INFO erigon erigon_instrumented
RUN cp -r erigon_instrumented/customer/* erigon/
RUN cd erigon && go mod edit -require=antithesis.com/instrumentation/wrappers@v1.0.0 -replace antithesis.com/instrumentation/wrappers=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers
# Antithesis -------------------------------------------------

RUN cd erigon/ \
    && CGO_CFLAGS="-I/opt/antithesis/go_instrumentation/include" CGO_LDFLAGS="-L/opt/antithesis/go_instrumentation/lib" make erigon

RUN cd erigon && git log -n 1 --format=format:"%H" > /erigon.version
FROM etb-client-runner

copy --from=builder /git/erigon/build/bin/erigon /usr/local/bin/erigon
COPY --from=builder /git/erigon_instrumented/symbols/* /opt/antithesis/symbols/
COPY --from=builder /erigon.version /erigon.version

ENTRYPOINT ["/bin/bash"]
