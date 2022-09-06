#!/bin/bash

BUILDKIT=1 docker build --no-cache -t etb-client-builder -f etb-client-builder.Dockerfile .
BUILDKIT=1 docker build --no-cache -t etb-client-runner -f etb-client-runner.Dockerfile .
