# Dati elezioni regionali in Liguria 2024

## Affluenza

I dati sull'affluenza sono raccolti nel file [`affluenza_comuni.csv`](dati/affluenza_comuni.csv)

La tabella è composta dai seguenti campi:

| **nome_campo** | **descrizione_campo** | **tipo_campo** | **esempio** |
| --- | --- | --- | --- |
| minint_elettorale | Identificativo elettorale del Comune | integer | 1070370010 |
| comune | Nome del comune | string | AIROLE |
| comune_codice | Codice del comune in Eligendo | integer | 10 |
| codice_sezione | Codice della sezione in Eligendo | integer | 1 |
| elettori_totali | Numero totale degli elettori | integer | 262 |
| elettori_maschi | Numero degli elettori maschi | integer | 147 |
| elettori_femmine | Numero delle elettrici femmine | integer | 115 |
| orario | Timestamp della conta dei voti | Data/ora | 20241027120000 |
| votanti | Numero dei votanti | integer | 45 |
| votanti_maschi | Numero dei votanti maschi | integer | 20 |
| votanti_femmine | Numero delle votanti femmine | integer | 25 |
| percentuale_votanti | Percentuale di affluenza alle urne | float | 17.18 |
| percentuale_tornata_precedente | Percentuale di affluenza alle urne nel turno precedente (al momento non presente) | float |  |
| file | Nome del file dei dati (nota interna onData) | string | affluenza_comune_037_0010 |
| com_istat_code | Codice ISTAT del Comune | string | 008001 |
