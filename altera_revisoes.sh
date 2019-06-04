#!/bin/bash
while getopts u:s:p:i: option
do
case "${option}"
in
u) USER=${OPTARG};;
s) PASS=${OPTARG};;
p) PORT=${OPTARG};;
i) IPS=${OPTARG};;
esac
done

allDbs=$(curl -s http://$USER:$PASS@$IPS:$PORT/_all_dbs | jq -r '.[]')
totalDbEmpty=0;
totalDbEmptyDeleted=0;
for i in $allDbs; do
    content="$(curl -s "http://$USER:$PASS@$IPS:$PORT/$i/_all_docs" | jq -r '.total_rows')"

    purgelimit=$(curl -s -X PUT -d "15"  "http://$USER:$PASS@$IPS:$PORT/$i/_purged_infos_limit")

    limite=$(curl  -s -X PUT -d "15" "http://$USER:$PASS@$IPS:$PORT/$i/_revs_limit")
    retorno=$(echo "$limite" | grep "\"ok\":true")
    if [ -z "$retorno" ]; then
        echo "Banco alterado o limite para 15: $i"
    fi
done

echo "Finalizado"