#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm -r "$folder"/rawdata/*

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/rawdata/datiRegioni
mkdir -p "$folder"/processing

URL="https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  # scarica pagina tramite chrome headless
  google-chrome-stable --virtual-time-budget=30000 --run-all-compositor-stages-before-draw --headless --disable-gpu --dump-dom "$URL" >"$folder"/rawdata/pagina.html

  dataOraAggiornamento=$(scrape <"$folder"/rawdata/pagina.html -be '//div[@class="title"]' | xq -r '.html.body.div."#text"')

  # scarica microdati su regioni?
  scaricaR="sì"

  if [[ $scaricaR == "no" ]]; then
    while IFS=$'\t' read -r nome codice; do
      echo "$nome"
      curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
        -H 'Connection: keep-alive' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'RequestId: 91290740-2433-bf80-9c8e-356683d2a524' \
        -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
        -H 'Content-Type: application/json;charset=UTF-8' \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36' \
        -H 'Origin: https://app.powerbi.com' \
        -H 'Sec-Fetch-Site: cross-site' \
        -H 'Sec-Fetch-Mode: cors' \
        -H 'Sec-Fetch-Dest: empty' \
        -H 'Referer: https://app.powerbi.com/' \
        -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
        --data-binary $'{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"t","Entity":"TAB_MASTER_PIVOT","Type":0},{"Name":"t1","Entity":"TAB_REGIONI","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Valore"},"Name":"Sum(TAB_MASTER_PIVOT.Valore)"},{"Column":{"Expression":{"SourceRef":{"Source":"t1"}},"Property":"REGIONE"},"Name":"TAB_REGIONI.REGIONE"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Attributo"},"Name":"TAB_MASTER_PIVOT.Attributo"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"KEY"},"Name":"TAB_MASTER_PIVOT.KEY"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Categoria Attributo"},"Name":"TAB_MASTER_PIVOT.Categoria Attributo"}],"Where":[{"Condition":{"In":{"Expressions":[{"Column":{"Expression":{"SourceRef":{"Source":"t1"}},"Property":"REGIONE"}}],"Values":[[{"Literal":{"Value":"'"\'$nome\'"'"}}]]}}}],"GroupBy":[{"SourceRef":{"Source":"t"},"Name":"TAB_MASTER_PIVOT"}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2,3,4],"GroupBy":[0]}]},"DataReduction":{"Primary":{"Top":{"Count":1000}}},"Version":1}}}]},"QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' \
        --compressed >"$folder"/rawdata/datiRegioni/"$codice".json

    done <"$folder"/risorse/listaRegioni.tsv

    curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
      -H 'Connection: keep-alive' \
      -H 'Accept: application/json, text/plain, */*' \
      -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
      -H 'Content-Type: application/json;charset=UTF-8' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36' \
      -H 'Origin: https://app.powerbi.com' \
      -H 'Sec-Fetch-Site: cross-site' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Referer: https://app.powerbi.com/' \
      -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
      --data-binary $'{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"t","Entity":"TAB_MASTER_PIVOT","Type":0},{"Name":"t1","Entity":"TAB_REGIONI","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Valore"},"Name":"Sum(TAB_MASTER_PIVOT.Valore)"},{"Column":{"Expression":{"SourceRef":{"Source":"t1"}},"Property":"REGIONE"},"Name":"TAB_REGIONI.REGIONE"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Attributo"},"Name":"TAB_MASTER_PIVOT.Attributo"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"KEY"},"Name":"TAB_MASTER_PIVOT.KEY"},{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"Categoria Attributo"},"Name":"TAB_MASTER_PIVOT.Categoria Attributo"}],"Where":[{"Condition":{"In":{"Expressions":[{"Column":{"Expression":{"SourceRef":{"Source":"t1"}},"Property":"REGIONE"}}],"Values":[[{"Literal":{"Value":"\'Valle d\'\'Aosta\'"}}]]}}}],"GroupBy":[{"SourceRef":{"Source":"t"},"Name":"TAB_MASTER_PIVOT"}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2,3,4],"GroupBy":[0]}]},"DataReduction":{"Primary":{"Top":{"Count":1000}}},"Version":1}}}]},"QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' \
      --compressed >"$folder"/rawdata/datiRegioni/02.json

  fi

  curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:84.0) Gecko/20100101 Firefox/84.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -H 'Origin: https://app.powerbi.com' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' --data-raw '{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"t2","Entity":"TAB_REGIONI","Type":0},{"Name":"t","Entity":"TAB_MASTER","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"t2"}},"Property":"AREA"},"Name":"TAB_REGIONI.AREA"},{"Aggregation":{"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"TOT_SOMM"}},"Function":0},"Name":"Sum(TAB_MASTER.TOT_SOMM)"},{"Measure":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"TassoVaccinazione"},"Name":"TAB_MASTER.TassoVaccinazione"},{"Aggregation":{"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"DOSI_CONSEGNATE"}},"Function":4},"Name":"Sum(TAB_MASTER.DOSI_CONSEGNATE)"}],"OrderBy":[{"Direction":1,"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t2"}},"Property":"AREA"}}}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2,3]}]},"DataReduction":{"DataVolume":3,"Primary":{"Window":{"Count":500}}},"Version":1}}}]},"CacheKey":"{\"Commands\":[{\"SemanticQueryDataShapeCommand\":{\"Query\":{\"Version\":2,\"From\":[{\"Name\":\"t2\",\"Entity\":\"TAB_REGIONI\",\"Type\":0},{\"Name\":\"t\",\"Entity\":\"TAB_MASTER\",\"Type\":0}],\"Select\":[{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t2\"}},\"Property\":\"AREA\"},\"Name\":\"TAB_REGIONI.AREA\"},{\"Aggregation\":{\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t\"}},\"Property\":\"TOT_SOMM\"}},\"Function\":0},\"Name\":\"Sum(TAB_MASTER.TOT_SOMM)\"},{\"Measure\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t\"}},\"Property\":\"TassoVaccinazione\"},\"Name\":\"TAB_MASTER.TassoVaccinazione\"},{\"Aggregation\":{\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t\"}},\"Property\":\"DOSI_CONSEGNATE\"}},\"Function\":4},\"Name\":\"Sum(TAB_MASTER.DOSI_CONSEGNATE)\"}],\"OrderBy\":[{\"Direction\":1,\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t2\"}},\"Property\":\"AREA\"}}}]},\"Binding\":{\"Primary\":{\"Groupings\":[{\"Projections\":[0,1,2,3]}]},\"DataReduction\":{\"DataVolume\":3,\"Primary\":{\"Window\":{\"Count\":500}}},\"Version\":1}}}]}","QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' | jq . >"$folder"/rawdata/somministrazioni.json

  jq <"$folder"/rawdata/somministrazioni.json '.results[0].result.data.dsr.DS[0].PH[0].DM0[]' | mlr --j2c unsparsify then cut -r -f "C:" >"$folder"/rawdata/somministrazioni.csv

  curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:84.0) Gecko/20100101 Firefox/84.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -H 'Origin: https://app.powerbi.com' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' --data-raw '{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"t","Entity":"TAB_MASTER","Type":0},{"Name":"t1","Entity":"TAB_MASTER_PIVOT","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"TML_FASCIA_ETA"},"Name":"TAB_MASTER.TML_FASCIA_ETA"},{"Aggregation":{"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t1"}},"Property":"Valore"}},"Function":0},"Name":"Sum(TAB_MASTER_PIVOT.Valore)"}],"OrderBy":[{"Direction":1,"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t"}},"Property":"TML_FASCIA_ETA"}}}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1]}]},"DataReduction":{"DataVolume":4,"Primary":{"Window":{"Count":1000}}},"Version":1}}}]},"CacheKey":"{\"Commands\":[{\"SemanticQueryDataShapeCommand\":{\"Query\":{\"Version\":2,\"From\":[{\"Name\":\"t\",\"Entity\":\"TAB_MASTER\",\"Type\":0},{\"Name\":\"t1\",\"Entity\":\"TAB_MASTER_PIVOT\",\"Type\":0}],\"Select\":[{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t\"}},\"Property\":\"TML_FASCIA_ETA\"},\"Name\":\"TAB_MASTER.TML_FASCIA_ETA\"},{\"Aggregation\":{\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t1\"}},\"Property\":\"Valore\"}},\"Function\":0},\"Name\":\"Sum(TAB_MASTER_PIVOT.Valore)\"}],\"OrderBy\":[{\"Direction\":1,\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t\"}},\"Property\":\"TML_FASCIA_ETA\"}}}]},\"Binding\":{\"Primary\":{\"Groupings\":[{\"Projections\":[0,1]}]},\"DataReduction\":{\"DataVolume\":4,\"Primary\":{\"Window\":{\"Count\":1000}}},\"Version\":1}}}]}","QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' | jq . >"$folder"/rawdata/fasceEta.json

  jq <"$folder"/rawdata/fasceEta.json '.results[0].result.data.dsr.DS[0].PH[0].DM0[]' | mlr --j2c unsparsify then cut -r -f "C:" >"$folder"/rawdata/fasceEta.csv

  curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:84.0) Gecko/20100101 Firefox/84.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: it,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -H 'Origin: https://app.powerbi.com' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Referer: https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' --data-raw '{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"t2","Entity":"TAB_MASTER_PIVOT","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"t2"}},"Property":"Categoria Attributo"},"Name":"TAB_MASTER_PIVOT.Categoria Attributo"},{"Aggregation":{"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t2"}},"Property":"Valore"}},"Function":0},"Name":"Sum(TAB_MASTER_PIVOT.Valore)"}],"OrderBy":[{"Direction":1,"Expression":{"Column":{"Expression":{"SourceRef":{"Source":"t2"}},"Property":"Categoria Attributo"}}}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1]}]},"DataReduction":{"DataVolume":4,"Primary":{"Window":{"Count":1000}}},"Version":1}}}]},"CacheKey":"{\"Commands\":[{\"SemanticQueryDataShapeCommand\":{\"Query\":{\"Version\":2,\"From\":[{\"Name\":\"t2\",\"Entity\":\"TAB_MASTER_PIVOT\",\"Type\":0}],\"Select\":[{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t2\"}},\"Property\":\"Categoria Attributo\"},\"Name\":\"TAB_MASTER_PIVOT.Categoria Attributo\"},{\"Aggregation\":{\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t2\"}},\"Property\":\"Valore\"}},\"Function\":0},\"Name\":\"Sum(TAB_MASTER_PIVOT.Valore)\"}],\"OrderBy\":[{\"Direction\":1,\"Expression\":{\"Column\":{\"Expression\":{\"SourceRef\":{\"Source\":\"t2\"}},\"Property\":\"Categoria Attributo\"}}}]},\"Binding\":{\"Primary\":{\"Groupings\":[{\"Projections\":[0,1]}]},\"DataReduction\":{\"DataVolume\":4,\"Primary\":{\"Window\":{\"Count\":1000}}},\"Version\":1}}}]}","QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' | jq . >"$folder"/rawdata/categoria.json

  jq <"$folder"/rawdata/categoria.json '.results[0].result.data.dsr.DS[0].PH[0].DM0[]' | mlr --j2c unsparsify then cut -r -f "C:" >"$folder"/rawdata/categoria.csv

  # pulizia

  mlr --csv label regione,somministrazioni,percentuale,dosiConsegnate then put '$percentuale=($percentuale*100)' then put -S '$aggiornamento="'"$dataOraAggiornamento"'"' "$folder"/rawdata/somministrazioni.csv >"$folder"/processing/latest_somministrazioni.csv

  cat "$folder"/processing/latest_somministrazioni.csv >>"$folder"/processing/somministrazioni.csv
  mlr -I --csv uniq -a "$folder"/processing/somministrazioni.csv

  mlr --csv label fascia,vaccinazioni then put -S '$aggiornamento="'"$dataOraAggiornamento"'"' "$folder"/rawdata/fasceEta.csv >"$folder"/processing/latest_fasceEta.csv

  cat "$folder"/processing/latest_fasceEta.csv >>"$folder"/processing/fasceEta.csv
  mlr -I --csv uniq -a "$folder"/processing/fasceEta.csv

  mlr --csv label categoria,vaccinazioni then put -S '$aggiornamento="'"$dataOraAggiornamento"'"' "$folder"/rawdata/categoria.csv>"$folder"/processing/latest_categoria.csv

  cat "$folder"/processing/latest_categoria.csv >>"$folder"/processing/categoria.csv
  mlr -I --csv uniq -a "$folder"/processing/categoria.csv

  date=$(date '+%Y-%m-%d')

fi
