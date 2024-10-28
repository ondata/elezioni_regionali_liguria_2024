#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

declare -A urls=(
  ["a"]="https://eleapi.interno.gov.it/siel/PX/getentiR/DE/20241027/TE/07"
  ["b"]="https://eleapi.interno.gov.it/siel/PX/getentiRZ/DE/20241027/TE/07/RE/07"
  ["c"]="https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07"
)

for name in "${!urls[@]}"; do
  url="${urls[$name]}"
  filename="${folder}/tmp/${name}.json"
  curl -o "${filename}" "${url}" \
    -H 'accept: application/json, text/plain, */*' \
    -H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
    -H 'if-modified-since: Sun, 27 Oct 2024 18:30:03 GMT' \
    -H 'origin: https://elezioni.interno.gov.it' \
    -H 'priority: u=1, i' \
    -H 'referer: https://elezioni.interno.gov.it/' \
    -H 'sec-ch-ua: "Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-site' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
done

start="https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07"

#https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/CR/034

#https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/PR/034/CM/0560

# Directory per salvare i dati
mkdir -p "${folder}"/../dati/regione
mkdir -p "${folder}"/../dati/provincia
mkdir -p "${folder}"/../dati/comune

# Codice ISTAT per la Liguria
CODICE_REGIONE="07"

# 1. Scarica i dati a livello regionale
curl 'https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07"' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'Referer: https://elezioni.interno.gov.it/' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'sec-ch-ua: "Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' | jq . >"${folder}"/../dati/regione/scrutini_risultati_regionale.json

# Estrarre i codici delle province dal file regionale
PROVINCE=$(jq -r '.enti.enti_f[] | select(.tipo=="PROVINCIA") | .cod' "${folder}"/../dati/regione/affluenza_regionale.json | xargs -I {} printf "%03d\n" {})

# 2. Scarica i dati a livello provinciale
for COD_PROV in $PROVINCE; do
  curl "https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/CR/$COD_PROV" -H 'accept: application/json, text/plain, */*' -H 'accept-language: it,en-US;q=0.9,en;q=0.8' -H 'origin: https://elezioni.interno.gov.it' -H 'priority: u=1, i' -H 'referer: https://elezioni.interno.gov.it/' -H 'sec-ch-ua: "Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"' -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' >"${folder}"/../dati/provincia/scrutini_risultati_provincia_$COD_PROV.json

  # Estrai i codici dei comuni dal file provinciale
  COMUNI=$(jq -r '.enti.enti_f[] | select(.tipo=="COMUNE") | .cod' "${folder}"/../dati/provincia/affluenza_provincia_$COD_PROV.json)

  # 3. Scarica i dati a livello comunale
  for COD_COMUNE in $COMUNI; do
    # Padding a 4 cifre del codice comune
    COD_COMUNE_PADDED=$(printf "%04d" $COD_COMUNE)
    curl "https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/PR/$COD_PROV/CM/$COD_COMUNE_PADDED" \
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
      -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
      >"${folder}"/../dati/comune/scrutini_risultati_comune_${COD_PROV}_${COD_COMUNE_PADDED}.json

    curl "https://eleapi.interno.gov.it/siel/PX/getprefeR/DE/20241027/TE/07/RE/07/PR/$COD_PROV/CM/$COD_COMUNE_PADDED" \
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
      -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
      >"${folder}"/../dati/comune/scrutini_preferenze_comune_${COD_PROV}_${COD_COMUNE_PADDED}.json
  done

done

echo "Dati scrutini scaricati con successo."

exit 0

https://eleapi.interno.gov.it/siel/PX/scrutiniR/DE/20241027/TE/07/RE/07/PR/034/CM/0250/SZ/0001
