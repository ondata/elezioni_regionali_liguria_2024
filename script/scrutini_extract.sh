#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp
mkdir -p "${folder}"/tmp/scrutini_risultati/
mkdir -p "${folder}"/tmp/scrutini_preferenze/

jq -s '.' "${folder}"/../dati/comune/scrutini_risultati_comune* >"${folder}"/tmp/scrutini_risultati_comune.json

flatterer --force "${folder}"/tmp/scrutini_risultati_comune.json "${folder}"/tmp/scrutini_risultati/

cp -r "${folder}"/tmp/scrutini_risultati/ "${folder}"/../dati/comune

jq -s '.' "${folder}"/../dati/comune/scrutini_preferenze_comune* >"${folder}"/tmp/scrutini_preferenze_comune.json

flatterer --force "${folder}"/tmp/scrutini_preferenze_comune.json "${folder}"/tmp/scrutini_preferenze/

cp -r "${folder}"/tmp/scrutini_preferenze/ "${folder}"/../dati/comune


