KEY="mykey"
CHAINID="test-1"
MONIKER="localtestnet"
KEYALGO="secp256k1"
KEYRING="test"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# remove existing daemon
rm -rf ~/.dig*

make install

digd config keyring-backend $KEYRING
digd config chain-id $CHAINID

# if $KEY exists it should be deleted
digd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Evmos (Moniker can be anything, chain-id must be an integer)
digd init $MONIKER --chain-id $CHAINID 

# Allocate genesis accounts (cosmos formatted addresses)
digd add-genesis-account $KEY 100000000000000000000000000stake --keyring-backend $KEYRING

# Sign genesis transaction
digd gentx $KEY 1000000000000000000000stake --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
digd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
digd validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
digd start --pruning=nothing  --minimum-gas-prices=0.0001stake

