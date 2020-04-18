#!/bin/bash
shopt -u extglob; set +H
[ -z "$1" ] && echo "Usage: $(basename $0) startrow (always 8 rows)" && exit 1
cd /Users/michaelmellouk/rav/nachweis
START=$1
ENDE=$(($START+7))
InFile=linkedIn.jobs-with-contact-col.csv
cat linkedIn.jobs-with-contact-col.csv| tr ' ' '_'| tr -d '"'| tr -d '/'| tr -d '%'  > ${InFile}.underscored
InFile=linkedIn.jobs-with-contact-col.csv
#while IFS=, read -ra fields ; do
#    echo "${fields[2]}"
#done <"$InFile"

#for row in $(cat linkedIn.jobs-with-contact-col.csv| awk -F"," -v start=$START -v ende=$ENDE  'BEGIN { FS=","; OFS="," } NR>=start && NR<=ende  {gsub(/:/,"-"); print $1";"$3";"$4";"$6  }'); do
MONAT="$(printf '%02d' ${2:-$(date +%m)})"
JAHR="$(date +%Y)"
TMPF=$(mktemp)
mkdir -p ${MONAT}.${JAHR}
cp *.png *.jpg ${MONAT}.${JAHR}/
NACHWEISFILE=${MONAT}.${JAHR}/${MONAT}.${JAHR}.html
left=47
top=220
TAG=1
TAGEND=6
i=1
for row in $(cat ${InFile}.underscored| gawk -v start=$START -v ende=$ENDE  'BEGIN { FS=","; OFS="," } NR>=start && NR<=ende  { print $1";"$3";"$4";"$6 }'); do
    echo row=$row
    TAG="$(printf '%02d' $(shuf -i $TAG-$TAGEND -n 1))"
    URL=$(echo $row|cut -d";" -f1|tr '_' ' ')
    FIRMA=$(echo $row|cut -d";" -f2|tr '_' ' ')
    CONTACT=$(echo $row|cut -d";" -f3|tr '_' ' ')
    STELLE=$(echo $row|cut -d";" -f4|tr '_' ' ')
    cat row.tpl.html| sed -e "s/{{top}}/${top}/g"| sed -e "s/{{monat}}/${MONAT}/g"| sed -e "s/{{jahr}}/${JAHR}/g"| sed -e "s/{{tag}}/${TAG}/g" | sed -e "s/{{firma}}/${FIRMA}/g" | sed -e "s/{{contact}}/${URL}/g"  | sed -e "s/{{stelle}}/\"${STELLE}\"/g" | sed -e "s/{{rav}}/\"\"/g" | sed -e "s/{{absagegrund}}/\"\"/g"   >>$TMPF
    top=$(($top + 35))
    i=$((i+1))
    TAGEND=$((i*4))
    echo -e "\r\n" >>$TMPF
done
TABLE="$(cat ${TMPF}|tr -d '\n')"
#echo $TABLE
TS=$(date +%d%m%Y%m%H%s)
# cat ./nachweisFullTemplate.tpl.html|sed -e "s/{{rows}}/${TABLE}/g"
cat ./nachweisFullTemplate.tpl.html|sed -e "s/{{rows}}/${TABLE}/g" > $NACHWEISFILE.$TS.html
sed  -i -e "s/{{timestamp}}/"$(date +%d.%m.%Y)"/g"  $NACHWEISFILE.$TS.html
sed  -i -e "s/{{monat}}/${MONAT}/g"  $NACHWEISFILE.$TS.html
sed  -i -e "s/{{jahr}}/${JAHR}/g"  $NACHWEISFILE.$TS.html

