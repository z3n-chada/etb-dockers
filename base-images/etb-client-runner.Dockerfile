from etb-client-builder:latest as rocks_builder

workdir /git

RUN cd rocksdb && make clean && make -j32 shared_lib

run mkdir -p /rocksdb/lib && cd rocksdb && cp librocksdb.so* /rocksdb/lib/


from debian:bullseye-slim as base
# Install nodejs
workdir /git

run apt update && apt install curl ca-certificates -y --no-install-recommends && curl -sL https://deb.nodesource.com/setup_17.x | bash -

run apt-get update && apt-get install -y --no-install-recommends nodejs 

RUN apt-get update && apt-get install -y --no-install-recommends wget libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev openjdk-17-jre wget 

RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

RUN apt update && apt install -y --no-install-recommends dotnet-runtime-6.0 aspnetcore-runtime-6.0

copy --from=rocks_builder /rocksdb/lib/ /usr/local/rocksdb/lib/

run cp /usr/local/rocksdb/lib/librocksdb.so* /usr/lib

# Antithesis instrumentation resources
COPY lib/libvoidstar.so /usr/lib/libvoidstar.so
RUN mkdir -p /opt/antithesis/
COPY go_instrumentation /opt/antithesis/go_instrumentation

RUN apt update && apt install -y --no-install-recommends lsb-release wget software-properties-common

RUN wget --no-check-certificate https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 14

ENV LLVM_CONFIG=llvm-config-14

RUN rm -rf /git

RUN mkdir -p /git

ENTRYPOINT ["/bin/bash"]
