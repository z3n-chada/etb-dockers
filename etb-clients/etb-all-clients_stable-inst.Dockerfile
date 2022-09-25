from etb-client-builder:latest as builder_base
workdir /git

arg LIGHTHOUSE_BRANCH="stable"
arg PRYSM_BRANCH="v3.1.1-rc"
arg NIMBUS_BRANCH="stable"
arg LODESTAR_BRANCH="next"
arg TEKU_BRANCH="master"

arg GETH_BRANCH="master"
arg NETHERMIND_BRANCH="master"
arg BESU_BRANCH="main"
arg ERIGON_BRANCH="devel"


from builder_base as lighthouse_builder
run git clone https://github.com/sigp/lighthouse.git && cd lighthouse && git checkout ${LIGHTHOUSE_BRANCH}
run rustup toolchain install nightly-2022-07-12
run cd lighthouse && LD_LIBRARY_PATH=/usr/lib/ RUSTFLAGS="-Cpasses=sancov-module -Cllvm-args=-sanitizer-coverage-level=3 -Cllvm-args=-sanitizer-coverage-trace-pc-guard -Ccodegen-units=1 -Cdebuginfo=2 -L/usr/lib/ -lvoidstar" cargo +nightly-2022-07-12 build --release --manifest-path lighthouse/Cargo.toml --target x86_64-unknown-linux-gnu --features modern --verbose --bin lighthouse
run cd lighthouse && git log -n 1 --format=format:"%H" > /lighthouse.version

from builder_base as teku_builder
run git clone https://github.com/Consensys/teku.git && \
    cd teku && git checkout $TEKU_BRANCH && \
    git log -n 1 --format=format:"%H" > /teku.version && \
    ./gradlew distTar installDist


from builder_base as nimbus_builder
run git clone https://github.com/status-im/nimbus-eth2.git && \
    cd nimbus-eth2 && git checkout ${NIMBUS_BRANCH} && \
    git log -n 1 --format=format:"%H" > /nimbus.version
run cd nimbus-eth2 && make -j64 nimbus_beacon_node NIMFLAGS="--cc:clang --clang.exe:clang-14 --clang.linkerexe:clang-14 --passC:'-fno-lto -fsanitize-coverage=trace-pc-guard' --passL:'-fno-lto -L/usr/lib/ -lvoidstar'" && \
    make -j64 nimbus_validator_client NIMFLAGS="--cc:clang --clang.exe:clang-14 --clang.linkerexe:clang-14 --passC:'-fno-lto -fsanitize-coverage=trace-pc-guard' --passL:'-fno-lto -L/usr/lib/ -lvoidstar'"

from builder_base as prysm_builder
run mkdir -p /git/src/github.com/prysmaticlabs/
run mkdir -p /build
run cd /git/src/github.com/prysmaticlabs/ && git clone https://github.com/prysmaticlabs/prysm && \
    cd prysm && git checkout $PRYSM_BRANCH && \
    git log -n 1 --format=format:"%H" > /prysm.version
workdir /git/src/github.com/prysmaticlabs/prysm
#Antithesis Instrumentation
# add items to this exclusions list to exclude them from instrumentation
run touch /opt/antithesis/go_instrumentation/exclusions.txt
# Ignore files with special `// go:` comments due to this issue: https://trello.com/c/Wmaxylu9
run grep -l -r go: | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt
run grep -l -r snappy | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt
# Antithesis -------------------------------------------------
workdir /git/src/github.com/prysmaticlabs
run mkdir -p prysm_instrumented && LD_LIBRARY_PATH=/opt/antithesis/go_instrumentation/lib /opt/antithesis/go_instrumentation/bin/goinstrumentor -antithesis=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers/ -exclude=/opt/antithesis/go_instrumentation/exclusions.txt -stderrthreshold=INFO prysm prysm_instrumented
run cp -r prysm_instrumented/customer/* prysm/
run cd prysm && go mod edit -require=antithesis.com/instrumentation/wrappers@v1.0.0 -replace antithesis.com/instrumentation/wrappers=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers
# Antithesis -------------------------------------------------
# Get dependencies
run cd /git/src/github.com/prysmaticlabs/prysm && go get -t -d ./...

#Build with instrumentation
run cd /git/src/github.com/prysmaticlabs/prysm && CGO_CFLAGS="-I/opt/antithesis/go_instrumentation/include" CGO_LDFLAGS="-L/opt/antithesis/go_instrumentation/lib" go build -o /build ./...
run go env GOPATH

from builder_base as lodestar_builder
workdir /usr/app 
run apt install -y --no-install-recommends python3-dev make g++
run ln -s /usr/local/bin/python3 /usr/local/bin/python
run npm install -g npm@8.8.0
run npm install @chainsafe/lodestar-cli@$LODESTAR_BRANCH
run ln -s /usr/app/node_modules/.bin/lodestar /usr/local/bin/lodestar

#Execution Builds
from builder_base as besu_builder
workdir /usr/src
run git clone --progress https://github.com/hyperledger/besu.git && cd besu && git checkout ${BESU_BRANCH} && ./gradlew installDist
run cd besu && git log -n 1 --format=format:"%H" > /besu.version



from builder_base as erigon_builder
arg ERIGON_BRANCH="devel"
run mkdir -p /build
run git clone --recurse-submodules -j8 https://github.com/ledgerwatch/erigon.git -b ${ERIGON_BRANCH}
# add items to this exclusions list to exclude them from instrumentation
run touch /opt/antithesis/go_instrumentation/exclusions.txt
# Ignore files with special `// go:` comments due to this issue: https://trello.com/c/Wmaxylu9
run cd erigon && grep -l -r go: | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt
run cd erigon && grep -l -r snappy | grep \.go$ >> /opt/antithesis/go_instrumentation/exclusions.txt
# Antithesis -------------------------------------------------
run mkdir -p erigon_instrumented && LD_LIBRARY_PATH=/opt/antithesis/go_instrumentation/lib /opt/antithesis/go_instrumentation/bin/goinstrumentor -antithesis=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers/ -exclude=/opt/antithesis/go_instrumentation/exclusions.txt -stderrthreshold=INFO erigon erigon_instrumented
run cp -r erigon_instrumented/customer/* erigon/
run cd erigon && go mod edit -require=antithesis.com/instrumentation/wrappers@v1.0.0 -replace antithesis.com/instrumentation/wrappers=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers
# Antithesis -------------------------------------------------
run cd erigon/ \
    && CGO_CFLAGS="-I/opt/antithesis/go_instrumentation/include" CGO_LDFLAGS="-L/opt/antithesis/go_instrumentation/lib" make erigon
run cd erigon && git log -n 1 --format=format:"%H" > /erigon.version

from builder_base as geth_builder
run mkdir -p /go/src/github.com/ethereum/ 
workdir /go/src/github.com/ethereum/
run git clone https://github.com/ethereum/go-ethereum \
    && cd go-ethereum \
    && git checkout ${GETH_BRANCH} 
# add items to this exclusions list to exclude them from instrumentation
run touch /opt/antithesis/go_instrumentation/exclusions.txt
# Antithesis -------------------------------------------------
workdir /go/src/github.com/ethereum/
run mkdir -p geth_instrumented && LD_LIBRARY_PATH=/opt/antithesis/go_instrumentation/lib /opt/antithesis/go_instrumentation/bin/goinstrumentor -antithesis=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers/ -exclude=/opt/antithesis/go_instrumentation/exclusions.txt -stderrthreshold=INFO go-ethereum geth_instrumented
run cp -r geth_instrumented/customer/* go-ethereum/
run cd go-ethereum && go mod edit -require=antithesis.com/instrumentation/wrappers@v1.0.0 -replace antithesis.com/instrumentation/wrappers=/opt/antithesis/go_instrumentation/instrumentation/go/wrappers 
# Antithesis -------------------------------------------------
# Get dependencies
run cd /go/src/github.com/ethereum/go-ethereum && go get -t -d ./...
run cd go-ethereum \
run && CGO_CFLAGS="-I/opt/antithesis/go_instrumentation/include" CGO_LDFLAGS="-L/opt/antithesis/go_instrumentation/lib" go install ./...
run cd go-ethereum && git log -n 1 --format=format:"%H" > /geth.version

# nethermind
from builder_base as nethermind_builder
run git clone https://github.com/NethermindEth/nethermind && cd nethermind && git checkout ${NETHERMIND_BRANCH}
run cd nethermind && git submodule update --init src/Dirichlet src/int256 src/Math.Gmp.Native
run cd /git/nethermind &&  dotnet publish src/Nethermind/Nethermind.Runner -c release -o out
run cd /git/nethermind && git log -n 1 --format=format:"%H" > /nethermind.version

#===============================fuzzers/spammers===============================
from builder_base as geth_bad_block_builder
run git clone https://github.com/edwards-antithesis/go-ethereum \
    && cd go-ethereum \
    && git checkout ant-merge-bad-block-creator \
    && make geth

# build tx-spammer seperate.
from tx-fuzzer:latest as tx_fuzzer_builder

#======================Runner=============================
from z3nchada/etb-client-runner:latest
env LD_LIBRARY_PATH=/usr/lib/

from etb-client-runner:latest 
run apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

#===================Consensus Clients============================
#teku
run mkdir -p /opt/teku
copy --from=teku_builder /git/teku/build/install/teku/. /opt/teku/
copy --from=teku_builder /teku.version /teku.version
run ln -s /opt/teku/bin/teku /usr/local/bin/teku
#lighthouse
copy --from=lighthouse_builder /git/lighthouse/target/x86_64-unknown-linux-gnu/release/lighthouse /usr/local/bin/lighthouse
copy --from=lighthouse_builder /lighthouse.version /lighthouse.version
#prysm
copy --from=prysm_builder /build/beacon-chain /usr/local/bin/
copy --from=prysm_builder /build/validator /usr/local/bin/
copy --from=prysm_builder /build/client-stats /usr/local/bin/
copy --from=prysm_builder /git/src/github.com/prysmaticlabs/prysm_instrumented/symbols/* /opt/antithesis/symbols/
copy --from=prysm_builder /git/src/github.com/prysmaticlabs/* /git/src/github.com/prysmaticlabs/
copy --from=prysm_builder /prysm.version /prysm.version
#nimbus
copy --from=nimbus_builder /git/nimbus-eth2/build/nimbus_beacon_node /usr/local/bin/nimbus_beacon_node
copy --from=nimbus_builder /git/nimbus-eth2/build/nimbus_validator_client /usr/local/bin/nimbus_validator_client
copy --from=nimbus_builder /nimbus.version /nimbus.version
#lodestar
copy --from=lodestar_builder /usr/app/ /usr/app/
run ln -s /usr/app/node_modules/.bin/lodestar /usr/local/bin/lodestar

#===================Execution Clients============================
# besu
copy --from=besu_builder /usr/src/besu/build/install/besu/. /opt/besu/
copy --from=besu_builder /besu.version /besu.version
run ln -s /opt/besu/bin/besu /usr/local/bin/besu
# erigon
copy --from=erigon_builder /git/erigon/build/bin/erigon /usr/local/bin/erigon
copy --from=erigon_builder /git/erigon_instrumented/symbols/* /opt/antithesis/symbols/
copy --from=erigon_builder /erigon.version /erigon.version
# geth
copy --from=geth_builder /root/go/bin/geth /usr/local/bin/geth
copy --from=geth_builder /root/go/bin/bootnode /usr/local/bin/bootnode
copy --from=geth_builder /go/src/github.com/ethereum/geth_instrumented/symbols/* /opt/antithesis/symbols/
copy --from=geth_builder /geth.version /geth.version
#nethermind
copy --from=nethermind_builder /git/nethermind/out /nethermind/
copy --from=nethermind_builder /nethermind.version /nethermind.version
run chmod +x /nethermind/Nethermind.Runner

# geth-bad-block-creator
copy --from=geth_bad_block_builder /git/go-ethereum/build/bin/geth /usr/local/bin/geth-bad-block
copy --from=tx_fuzzer_builder /run/tx-fuzz.bin /usr/local/bin/tx-fuzz
