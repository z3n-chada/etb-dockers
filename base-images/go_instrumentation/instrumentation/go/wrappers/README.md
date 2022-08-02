# Antithesis Go Instrumentation Functions

These functions can be called from instrumented Golang code, 
or directly from a workload.

## Building

Just as a sanity check after you've changed some code:

```shell
nix-shell -p go_1_16
CGO_LDFLAGS=-L$(nix-build ../../ -A instrumentation_stub)/lib go build
```