#!/bin/bash
set -o errexit -o nounset -o pipefail
command -v shellcheck > /dev/null && shellcheck "$0"

if [ $# -ne 1 ]; then
  echo "Usage: ./download_releases.sh RELEASE_TAG"
  exit 1
fi

tag="v1.0.0-beta6"

for contract in hackatom reflect; do
  url="https://github.com/CosmWasm/cosmwasm/releases/download/$tag/${contract}.wasm"
  echo "Downloading $url ..."
  wget -O "${contract}.wasm" "$url"
done

tag="$1"
url="https://github.com/tessornetwork/mokita-bindings/releases/download/$tag/moki_reflect.wasm"
echo "Downloading $url ..."
wget -O "moki_reflect.wasm" "$url"

rm -f version.txt
echo "$tag" >version.txt