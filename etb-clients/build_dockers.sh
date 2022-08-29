#!/bin/bash

BUILDKIT=1 docker build --no-cache -t etb-all-clients -f etb-all-clients.Dockerfile .
BUILDKIT=1 docker build --no-cache -t etb-all-clients:inst -f etb-all-clients_inst.Dockerfile .
