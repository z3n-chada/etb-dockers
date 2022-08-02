# Ethereum-Testnet-Bootstrapper
docker build scripts for building all combinations of el/cl clients, repo specific dockers, and fuzzers.

Dockers built and used in this repo:
| DockerImage               | Purpose                                                  | Public Download                                                                                             |
| ------------------------- |:-------------------------------------------------------- |:----------------------------------------------------------------------------------------------------------- |
| etb-all-clients           | all consensus and el clients in flat image.              | [z3nchada/etb-all-clients](https://hub.docker.com/repository/docker/z3nchada/etb-all-clients)               |
| etb-all-clients:inst      | all instrumented consensus and el clients in flat image. | [z3nchada/etb-all-clients](https://hub.docker.com/repository/docker/z3nchada/etb-all-clients)               |
| etb-client-builder        | all prereqs for building instrumented clients            | [z3nchada/etb-client-builder](https://hub.docker.com/repository/docker/z3nchada/etb-client-builder)         |
| etb-client-runner         | image with everything needed to run any client or fuzzer | [z3nchada/etb-client-runner](https://hub.docker.com/repository/docker/z3nchada/etb-client-runner)           |
| prysm:develop             | intermediate docker for prysm                            | N/A                                                                                                         |
| prysm:develop-inst        | intermediate docker for instrumented prysm               | N/A                                                                                                         |
| lighthouse:unstable       | intermediate docker for lighthouse                       | N/A                                                                                                         |
| lighthouse:unstable-inst  | intermediate docker for instrumented lighthouse          | N/A                                                                                                         |
| teku:master               | intermediate docker for teku                             | N/A                                                                                                         |
| lodestar:main             | intermediate docker for lodestar                         | N/A                                                                                                         |
| nimbus:kiln-dev-auth      | intermediate docker for nimbus                           | N/A                                                                                                         |
| nimbus:kiln-dev-auth-inst | intermediate docker for instrumented nimbus              | N/A                                                                                                         |
| geth:master               | intermediate docker for geth                             | N/A                                                                                                         |
| erigon:devel              | intermediate docker for erigon                           | N/A                                                                                                         |
| besu:main                 | intermedate docker for besu                              | N/A                                                                                                         |
| nethermind:kiln           | intermediate docker for nethermind                       | N/A                                                                                                         |
| geth:bad-block-creator    | intermediate docker for bad-block fuzzer                 | [z3nchada/geth-bad-block-creator](https://hub.docker.com/repository/docker/z3nchada/geth-bad-block-creator) |
| tx-fuzzer:                | intermedate docker for transaction spamming              | [z3nchada/tx-fuzzer](https://hub.docker.com/repository/docker/z3nchada/geth-bad-block-creator)              |
