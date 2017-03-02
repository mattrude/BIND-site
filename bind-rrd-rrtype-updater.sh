#!/bin/bash

HOST=${1}
RRDDIR="/var/lib/rrd"
img="/var/www/bind-img/"
rrdtool=/usr/bin/rrdtool
RRDDB="${RRDDIR}/${HOST}.rrd"
CURRENTTIME=`date |sed 's/\:/\\\:/g'`

rm -rf /tmp/QryType-${HOST}.txt

mkdir -p $RRDDIR
if [ ! -e $RRDDB ]; then 
    $rrdtool create $RRDDB --step 300 \
        DS:qrya:COUNTER:600:0:100000 \
        DS:qryaaaa:COUNTER:600:0:100000 \
        DS:qryany:COUNTER:600:0:100000 \
        DS:qryaxfr:COUNTER:600:0:100000 \
        DS:qrycname:COUNTER:600:0:100000 \
        DS:qrydnskey:COUNTER:600:0:100000 \
        DS:qryds:COUNTER:600:0:100000 \
        DS:qryhinfo:COUNTER:600:0:100000 \
        DS:qryixfr:COUNTER:600:0:100000 \
        DS:qryloc:COUNTER:600:0:100000 \
        DS:qrymx:COUNTER:600:0:100000 \
        DS:qrynaptr:COUNTER:600:0:100000 \
        DS:qryns:COUNTER:600:0:100000 \
        DS:qryptr:COUNTER:600:0:100000 \
        DS:qrysoa:COUNTER:600:0:100000 \
        DS:qryspf:COUNTER:600:0:100000 \
        DS:qrysrv:COUNTER:600:0:100000 \
        DS:qrytlsa:COUNTER:600:0:100000 \
        DS:qrytxt:COUNTER:600:0:100000 \
        RRA:AVERAGE:0.5:1:600 \
        RRA:AVERAGE:0.5:6:672 \
        RRA:AVERAGE:0.5:24:732 \
        RRA:AVERAGE:0.5:144:1460 \
        RRA:AVERAGE:0.5:288:2920
fi

mkdir -p /tmp
curl -sL http://${HOST}.mattrude.com:8053/json > /tmp/QryType-${HOST}.txt

QRYA=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.A`
QRYAAAA=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.AAAA`
QRYANY=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.ANY`
QRYCNAME=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.CNAME`
QRYDNSKEY=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.DNSKEY`
QRYDS=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.DS`
QRYIXFR=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.IXFR`
QRYLOC=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.LOC`
QRYMX=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.MX`
QRYNS=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.NS`
QRYPTR=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.PTR`
QRYSOA=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.SOA`
QRYSPF=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.SPF`
QRYSRV=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.SRV`
QRYTLSA=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.TLSA`
QRYTXT=`cat /tmp/QryType-${HOST}.txt |jq .qtypes.TXT`


if [ "${QRYA}" == "null" ]; then QRYA=0; fi
if [ "${QRYAAAA}" == "null" ]; then QRYAAAA=0; fi
if [ "${QRYANY}" == "null" ]; then QRYANY=0; fi
if [ "${QRYCNAME}" == "null" ]; then QRYCNAME=0; fi
if [ "${QRYDNSKEY}" == "null" ]; then QRYDNSKEY=0; fi
if [ "${QRYDS}" == "null" ]; then QRYDS=0; fi
if [ "${QRYIXFR}" == "null" ]; then QRYIXFR=0; fi
if [ "${QRYLOC}" == "null" ]; then QRYLOC=0; fi
if [ "${QRYMX}" == "null" ]; then QRYMX=0; fi
if [ "${QRYNS}" == "null" ]; then QRYNS=0; fi
if [ "${QRYPTR}" == "null" ]; then QRYPTR=0; fi
if [ "${QRYSOA}" == "null" ]; then QRYSOA=0; fi
if [ "${QRYSPF}" == "null" ]; then QRYSPF=0; fi
if [ "${QRYSRV}" == "null" ]; then QRYSRV=0; fi
if [ "${QRYTLSA}" == "null" ]; then QRYTLSA=0; fi
if [ "${QRYTXT}" == "null" ]; then QRYTXT=0; fi

$rrdtool update $RRDDB -t qrya:qryaaaa:qryany:qrycname:qrydnskey:qryds:qryixfr:qryloc:qrymx:qryns:qryptr:qrysoa:qryspf:qrysrv:qrytlsa:qrytxt N:$QRYA:$QRYAAAA:$QRYANY:$QRYCNAME:$QRYDNSKEY:$QRYDS:$QRYIXFR:$QRYLOC:$QRYMX:$QRYNS:$QRYPTR:$QRYSOA:$QRYSPF:$QRYSRV:$QRYTLSA:$QRYTXT
#echo "$rrdtool update $RRDDB -t qrya:qryaaaa:qryany:qrycname:qrydnskey:qryds:qryixfr:qryloc:qrymx:qryns:qryptr:qrysoa:qryspf:qrysrv:qrytlsa:qrytxt N:$QRYA:$QRYAAAA:$QRYANY:$QRYCNAME:$QRYDNSKEY:$QRYDS:$QRYIXFR:$QRYLOC:$QRYMX:$QRYNS:$QRYPTR:$QRYSOA:$QRYSPF:$QRYSRV:$QRYTLSA:$QRYTXT"

exit 0
mkdir -p $img
for period in 6h 1day 1week 1month 1year 2year
do
        time="`echo ${period} |sed 's/1//g' |sed 's/6h/6 hours/g' |sed 's/2year/2 years/g'`"
        period1=`echo -n '-'; echo ${period}`
        period2=`echo ${period} |sed 's/1//g'`
	$rrdtool graph $img/dnstype-${HOST}-${period2}.png -s ${period1} \
	-t "DNS Service traffic by Resource Record on host ${HOST}.mattrue.com for the last ${time}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 690 -l 0 -a PNG -v "Requests/minute" \
	DEF:rrqrya=$RRDDB:qrya:AVERAGE \
	DEF:rrqryaaaa=$RRDDB:qryaaaa:AVERAGE \
	DEF:rrqrycname=$RRDDB:qrycname:AVERAGE \
        CDEF:qrya=rrqrya,60,* \
        CDEF:qryaaaa=rrqryaaaa,60,* \
        CDEF:qrycname=rrqrycname,60,* \
        VDEF:minqrya=qrya,MINIMUM \
        VDEF:minqryaaaa=qryaaaa,MINIMUM \
        VDEF:minqrycname=qrycname,MINIMUM \
        VDEF:maxqrya=qrya,MAXIMUM \
        VDEF:maxqryaaaa=qryaaaa,MAXIMUM \
        VDEF:maxqrycname=qrycname,MAXIMUM \
        VDEF:avgqrya=qrya,AVERAGE \
        VDEF:avgqryaaaa=qryaaaa,AVERAGE \
        VDEF:avgqrycname=qrycname,AVERAGE \
        VDEF:lstqrya=qrya,LAST \
        VDEF:lstqryaaaa=qryaaaa,LAST \
        VDEF:lstqrycname=qrycname,LAST \
        "COMMENT: \l" \
        "COMMENT:                    " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:qrya#1A7200:    A Queries  :STACK" \
        "GPRINT:lstqrya:%5.1lf %s   " \
        "GPRINT:avgqrya:%5.1lf %s   " \
        "GPRINT:minqrya:%5.1lf %s   " \
        "GPRINT:maxqrya:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qryaaaa#4286f4: AAAA Queries  :STACK" \
        "GPRINT:lstqryaaaa:%5.1lf %s   " \
        "GPRINT:avgqryaaaa:%5.1lf %s   " \
        "GPRINT:minqryaaaa:%5.1lf %s   " \
        "GPRINT:maxqryaaaa:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrycname#f441bb:CNAME Queries  :STACK" \
        "GPRINT:lstqrycname:%5.1lf %s   " \
        "GPRINT:avgqrycname:%5.1lf %s   " \
        "GPRINT:minqrycname:%5.1lf %s   " \
        "GPRINT:maxqrycname:%5.1lf %s   \l" \
        "COMMENT: \l" \
        "COMMENT:                                                            Last Updated\: $CURRENTTIME \l" > /dev/null
done

exit 0
