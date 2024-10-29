#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp
mkdir -p "${folder}"/tmp/scrutini_sezioni_risultati/

jq -s '.' "${folder}"/../dati/sezione/scrutini_sezione_* >"${folder}"/tmp/scrutini_risultati_sezione.json

flatterer --force "${folder}"/tmp/scrutini_risultati_sezione.json "${folder}"/tmp/scrutini_sezioni_risultati/

cp -r "${folder}"/tmp/scrutini_sezioni_risultati/ "${folder}"/../dati/sezione/

sed -i 's/###\+//g' "${folder}"/../dati/sezione/scrutini_sezioni_risultati/csv/main.csv

mlr -S -I --csv --from "${folder}"/../dati/sezione/scrutini_sezioni_risultati/csv/main.csv put '$int_perc_vot=sub($int_perc_vot,",",".")'

mlr -S -I --csv --from "${folder}"/../dati/sezione/scrutini_sezioni_risultati/csv/cand.csv put '$perc=sub($perc,",",".");$perc_lis=sub($perc_lis,",",".")'

mlr -S -I --csv --from "${folder}"/../dati/sezione/scrutini_sezioni_risultati/csv/cand_liste.csv put '$perc=sub($perc,",",".")'
