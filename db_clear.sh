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
totalBytes=0;
totalDbEmpty=0;
totalDbEmptyDeleted=0;
for i in $allDbs; do
    content="$(curl -s "http://$USER:$PASS@$IPS:$PORT/$i/_all_docs" | jq -r '.total_rows')"

    echo $content
     if [ "$content" == 0 ]; then
            totalDbEmpty=$(($totalDbEmpty + 1));
            delete=$(curl -s -X DELETE "http://$USER:$PASS@$IPS:$PORT/$i")
            succ=$(echo "$delete" | grep "\"ok\":true")
            if [ -z "$succ" ]; then
                echo "Banco deletado: $i"
                totalDbEmptyDeleted=$(($totalDbEmptyDeleted + 1));
                totalBytes=$(($totalBytes + $sizeDB));
            fi
     fi

    compactar=$(curl -s -X POST "http://$USER:$PASS@$IPS:$PORT/$i/_compact")
    resultado=$(echo "compactar" | grep "\"ok\":true")
    if [ -z "$resultado" ]; then
        echo "Banco compactado: $i"
    fi

    limite=$(curl  -s -X PUT -d "15" "http://$USER:$PASS@$IPS:$PORT/$i/_revs_limit")
    retorno=$(echo "$limite" | grep "\"ok\":true")
    if [ -z "$retorno" ]; then
        echo "Banco alterado o limite para 15: $i"
    fi
done

echo "Total de banco vazio: $totalDbEmpty"
echo "Total de banco vazio deletado: $totalDbEmpty"