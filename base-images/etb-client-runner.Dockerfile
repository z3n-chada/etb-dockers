FROM etb-client-builder:latest as rocks_builder

WORKDIR /git

RUN cd rocksdb && make clean && make -j32 shared_lib

RUN mkdir -p /rocksdb/lib && cd rocksdb && cp librocksdb.so* /rocksdb/lib/


FROM debian:bullseye-slim as base
# Install nodejs
WORKDIR /git

RUN apt update && apt install curl ca-certificates -y --no-install-recommends \
    wget \
    lsb-release \
    software-properties-common && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    libgflags-dev \
    libsnappy-dev \
    zlib1g-dev \
    libbz2-dev \
    liblz4-dev \
    libzstd-dev \
    openjdk-17-jre \
    dotnet-runtime-7.0 \
    aspnetcore-runtime-7.0

COPY --from=rocks_builder /rocksdb/lib/ /usr/local/rocksdb/lib/

RUN cp /usr/local/rocksdb/lib/librocksdb.so* /usr/lib

# Antithesis instrumentation resources
COPY lib/libvoidstar.so /usr/lib/libvoidstar.so
RUN mkdir -p /opt/antithesis/
COPY go_instrumentation /opt/antithesis/go_instrumentation

RUN wget --no-check-certificate https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 14

ENV LLVM_CONFIG=llvm-config-14

RUN rm -rf /git

RUN mkdir -p /git

ENTRYPOINT ["/bin/bash"]
