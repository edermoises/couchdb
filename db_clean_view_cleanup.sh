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
     if [ "$content" == 0 ]; then
            echo "$content"
             totalDbEmpty=$(($totalDbEmpty + 1));
            delete=$(curl -s -X DELETE "http://$USER:$PASS@$IPS:$PORT/$i")
            echo "Deletado: $delete"
     fi

      compact=$(curl -q -s -H "Content-Type: application/json" -X POST "http://$USER:$PASS@$IPS:$PORT/$i/_compact")
      echo "$compact"   
      purge=$(curl -s -X POST "http://$USER:$PASS@$IPS:$PORT/$i/_view_cleanup")
      echo "$purge"

done

echo "Total de banco vazio: $totalDbEmpty"
echo "Total de banco vazio deletado: $totalDbEmpty"