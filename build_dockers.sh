# build the base-images (note not needed since they pull from z3nchada/<>) uncomment to update them.

cd base-images
./build_dockers.sh

cd ../fuzzers
echo "Building fuzzers"
./build_dockers.sh

# next build the execution-clients and consensus clients.
cd ../execution-clients
echo "Building execution clients"
./build_dockers.sh

cd ../consensus-clients
echo "Building consensus-clients"
./build_dockers.sh

# now that we have all the prereqs build the etb-client images.
cd ../etb-clients
echo "Building the etb-clients"
./build_dockers.sh
