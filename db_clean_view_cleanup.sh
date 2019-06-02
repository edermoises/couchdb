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
            sizeDB="$(curl -s "http://$USER:$PASS@$IPS:$PORT/$i" | jq .sizes.file)"
            compact=$(curl -s -X POST "http://$USER:$PASS@$IPS:$PORT/$i/_view_cleanup")
            echo "$compact"
            purge=$(curl -s -X POST "http://$USER:$PASS@$IPS:$PORT/$i/_view_cleanup")
            echo "$purge"
            delete=$(curl -s -X DELETE "http://$USER:$PASS@$IPS:$PORT/$i")
            succ=$(echo "$delete" | grep "\"ok\":true")
            if [ -z "$succ" ]; then
                echo "Banco deletado: $i"
                totalDbEmptyDeleted=$(($totalDbEmptyDeleted + 1));
                totalBytes=$(($totalBytes + $sizeDB));
            fi
     fi

done

echo "Total de bytes liberado:"
echo "Total de banco vazio: $totalDbEmpty"
echo "Total de banco vazio deletado: $totalDbEmpty"