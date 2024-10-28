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

# scrutini

## principale

mlr --icsv --ojsonl --from "${folder}"/../dati/comune/scrutini_risultati/csv/main.csv put '$minint_elettorale="107".fmtnum($int_cod_prov,"%03d").fmtnum($int_cod_com,"%04d")' >"${folder}"/tmp/scrutini_risultati/main.jsonl

mlr --jsonl cut -f minint_elettorale,com_istat_code /"${folder}"/../riferimenti/comuni_07.jsonl >"${folder}"/tmp/scrutini_risultati/comuni.jsonl

mlr --jsonl join --ul -j minint_elettorale -f "${folder}"/tmp/scrutini_risultati/main.jsonl then unsparsify /"${folder}"/tmp/scrutini_risultati/comuni.jsonl >"${folder}"/tmp/scrutini_risultati/main_comuni.jsonl

mlr --ijsonl --ocsv --from "${folder}"/tmp/scrutini_risultati/main_comuni.jsonl put '$int_perc_vot=sub(string($int_perc_vot),",",".")' >"${folder}"/../dati/scrutini_comuni_principale.csv

## candidati

mlr --csv --from "${folder}"/../dati/scrutini_comuni_principale.csv cut -f _link,com_istat_code then label _link_main >"${folder}"/tmp/scrutini_risultati/scrutini_comuni_principale_ref.csv

mlr --csv join --ul -j _link_main -f "${folder}"/../dati/comune/scrutini_risultati/csv/cand.csv then unsparsify "${folder}"/tmp/scrutini_risultati/scrutini_comuni_principale_ref.csv >"${folder}"/../dati/scrutini_comuni_candidati.csv

mlr -I --csv  put '$perc=sub(string($perc),",",".");$perc_lis=sub(string($perc_lis),",",".")' "${folder}"/../dati/scrutini_comuni_candidati.csv

## liste

mlr --csv --from "${folder}"/../dati/comune/scrutini_risultati/csv/cand.csv cut -f _link,_link_main,cogn,nome then label _link_cand >"${folder}"/tmp/scrutini_risultati/scrutini_comuni_candidati_ref.csv

mlr --csv join --ul -j _link_main -f "${folder}"/tmp/scrutini_risultati/scrutini_comuni_candidati_ref.csv then unsparsify "${folder}"/tmp/scrutini_risultati/scrutini_comuni_principale_ref.csv >"${folder}"/tmp/scrutini_risultati/scrutini_comuni_principale_ref_cand.csv

mlr --csv filter -x 'is_null($pos)' "${folder}"/../dati/comune/scrutini_risultati/csv/cand_liste.csv >"${folder}"/tmp/scrutini_risultati/cand_liste.csv

mlr --csv join --ul -j _link_cand -f "${folder}"/tmp/scrutini_risultati/cand_liste.csv then unsparsify then sort -t _link_cand,link "${folder}"/tmp/scrutini_risultati/scrutini_comuni_principale_ref_cand.csv >"${folder}"/../dati/scrutini_comuni_liste.csv

mlr -I --csv  put '$perc=sub(string($perc),",",".")' then sort -t _link_main,pos "${folder}"/../dati/scrutini_comuni_liste.csv
