#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

# Directory per salvare i dati
mkdir -p "${folder}"/../dati/regione
mkdir -p "${folder}"/../dati/provincia
mkdir -p "${folder}"/../dati/comune
mkdir -p "${folder}"/../dati/sezione

mlr -S --icsv --ojsonl --from "${folder}"/../riferimenti/comuni_sezioni.csv put '$prov=sub($minint_elettorale,"^([0-9]{3})([0-9]{3})([0-9]{4})$","\2");$com=sub($minint_elettorale,"^([0-9]{3})([0-9]{3})([0-9]{4})$","\3");$sez=string(fmtnum(int($codice_sezione),"%04d"))' then cut -f prov,com,sez >"${folder}"/tmp/comuni_sezioni.jsonl

# leggi ogni linea del file comuni_sezioni.jsonl in while loop e stampa ogni riga
while IFS= read -r line; do
  echo "$line"
  PR=$(echo "$line" | jq -r '.prov')
  CM=$(echo "$line" | jq -r '.com')
  SZ=$(echo "$line" | jq -r '.sez')

  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/PR/$PR/CM/$CM/SZ/$SZ" \
    -H 'accept: application/json, text/plain, */*' \
    -H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
    -H 'origin: https://elezioni.interno.gov.it' \
    -H 'priority: u=1, i' \
    -H 'referer: https://elezioni.interno.gov.it/' \
    -H 'sec-ch-ua: "Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-site' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' >"${folder}"/../dati/sezione/scrutini_sezione_${PR}_${CM}_${SZ}.json
done <"${folder}"/tmp/comuni_sezioni.jsonl

exit 0

https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/PR/034/CM/0250/SZ/0001
