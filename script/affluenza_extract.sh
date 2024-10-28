#!/bin/bash

#set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

# estrai info anagrafiche comuni
<"${folder}"/../riferimenti/comuni_07.geojson jq -c '.features[].properties' >"${folder}"/../riferimenti/comuni_07.jsonl

# usa find e un while loop per stampare i nomi di tutti i file .json in "${folder}"/../dati/comune/

# se "${folder}"/../dati/affluenza_comuni.jsonl esiste, cancellalo. Usa la condizione if
if [ -f "${folder}"/../dati/affluenza_comuni.jsonl ]; then
  rm "${folder}"/../dati/affluenza_comuni.jsonl
fi

find "${folder}"/../dati/comune/ -name "affluenza_comune_*.json" | while read -r file; do
  filename=$(basename "$file" .json)
  jq -c '.enti as $enti |
       $enti.enti_f[] as $sezione |  # Itera su tutte le sezioni
       $sezione.com_vot[] as $votazione |
       {
          comune: $enti.ente_p.desc,
          comune_codice: $enti.ente_p.cod,
          codice_sezione: $sezione.cod,
          elettori_totali: $sezione.ele_t,
          elettori_maschi: $sezione.ele_m,
          elettori_femmine: $sezione.ele_f,
          orario: $votazione.dt_com,
          votanti: $votazione.vot_t,
          votanti_maschi: $votazione.vot_m,
          votanti_femmine: $votazione.vot_f,
          percentuale_votanti: $votazione.perc,
          percentuale_tornata_precedente: $votazione.perc_r,
          file: "'"$filename"'"
       }' "$file" >>"${folder}"/../dati/affluenza_comuni.jsonl
done

# aggiungi il campo minint_elettorale
mlr -I --jsonl put '$minint_elettorale=sub($file,"^.+_([0-9]{3})_([0-9]{4})$","107\1\2")' "${folder}"/../dati/affluenza_comuni.jsonl

# estrai solo i campi minint_elettorale e com_istat_code
mlr --jsonl cut -f minint_elettorale,com_istat_code "${folder}"/../riferimenti/comuni_07.jsonl >"${folder}"/tmp/comuni_07_minint.jsonl

# fai join per aggiungere com_istat_code
mlr --jsonl join --ul -j minint_elettorale -f "${folder}"/../dati/affluenza_comuni.jsonl then unsparsify then put '$percentuale_votanti=sub($percentuale_votanti,",",".");$percentuale_tornata_precedente=sub(string($percentuale_tornata_precedente),",",".")' "${folder}"/tmp/comuni_07_minint.jsonl >"${folder}"/tmp/affluenza_comuni.jsonl

sed -i -r 's/####+//g' "${folder}"/tmp/affluenza_comuni.jsonl

mlr -I --jsonl put '$percentuale_votanti=float($percentuale_votanti);' "${folder}"/tmp/affluenza_comuni.jsonl

mv "${folder}"/tmp/affluenza_comuni.jsonl "${folder}"/../dati/affluenza_comuni.jsonl

mlr --ijsonl --ocsv cat "${folder}"/../dati/affluenza_comuni.jsonl >"${folder}"/../dati/affluenza_comuni.csv
