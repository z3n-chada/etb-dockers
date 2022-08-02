# all of the built execution clients.
from besu:develop as besu_builder
from erigon:devel as erigon_builder
from geth:master as geth_builder
from nethermind:master as nethermind_builder
from geth:bad-block-creator as geth_bad_block_builder
from tx-fuzzer:latest as tx_fuzzer_builder
from lighthouse:unstable as lh_builder
from nimbus:unstable as nimbus_builder
from prysm:develop as prysm_builder
from teku:master as teku_builder
from lodestar:master as ls_builder

from z3nchada/etb-client-runner:latest

# now copy in all the execution clients.

copy --from=tx_fuzzer_builder /run/tx-fuzz.bin /usr/local/bin/tx-fuzz
copy --from=geth_bad_block_builder /usr/local/bin/geth-bad-block /usr/local/bin/geth-bad-block-creator
copy --from=geth_builder /usr/local/bin/geth /usr/local/bin/geth
copy --from=geth_builder /usr/local/bin/bootnode /usr/local/bin/bootnode
copy --from=geth_builder /geth.version /geth.version
copy --from=besu_builder /opt/besu /opt/besu
copy --from=besu_builder /besu.version /besu.version
run ln -s /opt/besu/bin/besu /usr/local/bin/besu 
copy --from=nethermind_builder /nethermind/ /nethermind/
copy --from=nethermind_builder /nethermind.version /nethermind.version
run ln -s /nethermind/Nethermind.Runner /usr/local/bin/nethermind
copy --from=erigon_builder /usr/local/bin/erigon /usr/local/bin/erigon
copy --from=erigon_builder /erigon.version /erigon.version

# copy in all of the consensus clients
copy --from=lh_builder /usr/local/bin/lighthouse /usr/local/bin/lighthouse
copy --from=lh_builder /lighthouse.version /lighthouse.version
copy --from=nimbus_builder /usr/local/bin/nimbus_beacon_node /usr/local/bin/nimbus_beacon_node
copy --from=nimbus_builder /usr/local/bin/nimbus_validator_client /usr/local/bin/nimbus_validator_client
copy --from=nimbus_builder /nimbus.version /nimbus.version
copy --from=prysm_builder /usr/local/bin/beacon-chain /usr/local/bin/beacon-chain
copy --from=prysm_builder /usr/local/bin/validator /usr/local/bin/validator
copy --from=prysm_builder /prysm.version /prysm.version
copy --from=teku_builder /opt/teku /opt/teku
copy --from=teku_builder /teku.version /teku.version
run ln -s /opt/teku/bin/teku /usr/local/bin/teku
copy --from=ls_builder /usr/app/ /usr/app/
run ln -s /usr/app/node_modules/.bin/lodestar /usr/local/bin/lodestar

entrypoint ["/bin/bash"]
