#!/bin/bash

RRDDIR="/var/lib/rrd"
img="/var/www/bind-img/"
rrdtool=/usr/bin/rrdtool
RRDDB="${RRDDIR}/dns.rrd"
#CURRENTTIME=`TZ='UTC' date |sed 's/\:/\\\:/g'`
CURRENTTIME=`date |sed 's/\:/\\\:/g'`

sleep $[ ( $RANDOM % 10 )  + 1 ]s

mkdir -p $RRDDIR
if [ ! -e $RRDDB ]; then 
    $rrdtool create $RRDDB --step 300 \
	DS:ns1u:COUNTER:600:0:100000 \
	DS:ns1t:COUNTER:600:0:100000 \
	DS:ns1s:COUNTER:600:0:100000 \
	DS:ns1x:COUNTER:600:0:100000 \
	DS:ns2u:COUNTER:600:0:100000 \
	DS:ns2t:COUNTER:600:0:100000 \
	DS:ns2s:COUNTER:600:0:100000 \
	DS:ns2x:COUNTER:600:0:100000 \
	DS:ns3u:COUNTER:600:0:100000 \
	DS:ns3t:COUNTER:600:0:100000 \
	DS:ns3s:COUNTER:600:0:100000 \
	DS:ns3x:COUNTER:600:0:100000 \
	DS:ns4u:COUNTER:600:0:100000 \
	DS:ns4t:COUNTER:600:0:100000 \
	DS:ns4s:COUNTER:600:0:100000 \
	DS:ns4x:COUNTER:600:0:100000 \
	DS:allu:COUNTER:600:0:100000 \
	DS:allt:COUNTER:600:0:100000 \
	DS:alls:COUNTER:600:0:100000 \
	DS:allx:COUNTER:600:0:100000 \
	DS:all:COUNTER:600:0:100000 \
	RRA:AVERAGE:0.5:1:600 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460 \
	RRA:AVERAGE:0.5:288:2920
fi

mkdir -p /tmp
#for HOST in ns1 ns2 ns3 ns4
for HOST in ns1 ns2 ns3
do
    curl -sL http://${HOST}.mattrude.com:8053/json > /tmp/${HOST}
done

NS1QUDP=`cat /tmp/ns1 |jq .nsstats.QryUDP`
NS1QTCP=`cat /tmp/ns1 |jq .nsstats.QryTCP`
NS1QSUC=`cat /tmp/ns1 |jq .nsstats.QrySuccess`
NS1QNXR=`cat /tmp/ns1 |jq .nsstats.QryNxrrset`
NS2QUDP=`cat /tmp/ns2 |jq .nsstats.QryUDP`
NS2QTCP=`cat /tmp/ns2 |jq .nsstats.QryTCP`
NS2QSUC=`cat /tmp/ns2 |jq .nsstats.QrySuccess`
NS2QNXR=`cat /tmp/ns2 |jq .nsstats.QryNxrrset`
NS3QUDP=`cat /tmp/ns3 |jq .nsstats.QryUDP`
NS3QTCP=`cat /tmp/ns3 |jq .nsstats.QryTCP`
NS3QSUC=`cat /tmp/ns3 |jq .nsstats.QrySuccess`
NS3QNXR=`cat /tmp/ns3 |jq .nsstats.QryNxrrset`
#NS4QUDP=`cat /tmp/ns4 |jq .nsstats.QryUDP`
#NS4QTCP=`cat /tmp/ns4 |jq .nsstats.QryTCP`
#NS4QSUC=`cat /tmp/ns4 |jq .nsstats.QrySuccess`
#NS4QNXR=`cat /tmp/ns4 |jq .nsstats.QryNxrrset`


if [ -z "${NS1QUDP}" ]; then NS1QUDP=0; fi
if [ -z "${NS1QTCP}" ]; then NS1QTCP=0; fi
if [ -z "${NS1QSUC}" ]; then NS1QSUC=0; fi
if [ -z "${NS1QNXR}" ]; then NS1QNXR=0; fi
if [ -z "${NS2QUDP}" ]; then NS2QUDP=0; fi
if [ -z "${NS2QTCP}" ]; then NS2QTCP=0; fi
if [ -z "${NS2QSUC}" ]; then NS2QSUC=0; fi
if [ -z "${NS2QNXR}" ]; then NS2QNXR=0; fi
if [ -z "${NS3QUDP}" ]; then NS3QUDP=0; fi
if [ -z "${NS3QTCP}" ]; then NS3QTCP=0; fi
if [ -z "${NS3QSUC}" ]; then NS3QSUC=0; fi
if [ -z "${NS3QNXR}" ]; then NS3QNXR=0; fi
if [ -z "${NS4QUDP}" ]; then NS4QUDP=0; fi
if [ -z "${NS4QTCP}" ]; then NS4QTCP=0; fi
if [ -z "${NS4QSUC}" ]; then NS4QSUC=0; fi
if [ -z "${NS4QNXR}" ]; then NS4QNXR=0; fi


if [ "${NS1QUDP}" == "null" ]; then NS1QUDP=0; fi
if [ "${NS1QTCP}" == "null" ]; then NS1QTCP=0; fi
if [ "${NS1QSUC}" == "null" ]; then NS1QSUC=0; fi
if [ "${NS1QNXR}" == "null" ]; then NS1QNXR=0; fi
if [ "${NS2QUDP}" == "null" ]; then NS2QUDP=0; fi
if [ "${NS2QTCP}" == "null" ]; then NS2QTCP=0; fi
if [ "${NS2QSUC}" == "null" ]; then NS2QSUC=0; fi
if [ "${NS2QNXR}" == "null" ]; then NS2QNXR=0; fi
if [ "${NS3QUDP}" == "null" ]; then NS3QUDP=0; fi
if [ "${NS3QTCP}" == "null" ]; then NS3QTCP=0; fi
if [ "${NS3QSUC}" == "null" ]; then NS3QSUC=0; fi
if [ "${NS3QNXR}" == "null" ]; then NS3QNXR=0; fi
if [ "${NS4QUDP}" == "null" ]; then NS4QUDP=0; fi
if [ "${NS4QTCP}" == "null" ]; then NS4QTCP=0; fi
if [ "${NS4QSUC}" == "null" ]; then NS4QSUC=0; fi
if [ "${NS4QNXR}" == "null" ]; then NS4QNXR=0; fi


QUERYALL="$(($NS1QUDP+$NS1QTCP+$NS2QUDP+$NS2QTCP+$NS3QUDP+$NS3QTCP+$NS4QUDP+$NS4QTCP))"
QUERYALLU="$(($NS1QUDP+$NS2QUDP+$NS3QUDP+$NS4QUDP))"
QUERYALLT="$(($NS1QTCP+$NS2QTCP+$NS3QTCP+$NS4QTCP))"
QUERYALLS="$(($NS1QSUC+$NS2QSUC+$NS3QSUC+$NS4QSUC))"
QUERYALLX="$(($NS1QNXR+$NS2QNXR+$NS3QNXR+$NS4QNXR))"

mkdir -p $RRDDIR
$rrdtool update $RRDDB -t ns1u:ns1t:ns1s:ns1x:ns2u:ns2t:ns3u:ns3t:ns4u:ns4t:allu:allt:alls:allx:all N:$NS1QUDP:$NS1QTCP:$NS1QSUC:$NS1QNXR:$NS2QUDP:$NS2QTCP:$NS3QUDP:$NS3QTCP:$NS4QUDP:$NS4QTCP:$QUERYALLU:$QUERYALLT:$QUERYALLS:$QUERYALLX:$QUERYALL

/root/bind-status-site/bind-rrd-rrtype-updater.sh ns1
/root/bind-status-site/bind-rrd-rrtype-updater.sh ns2
/root/bind-status-site/bind-rrd-rrtype-updater.sh ns3

mkdir -p $img
for period in 6h 1day 1week 1month 1year 2year
do
        time="`echo ${period} |sed 's/1//g' |sed 's/6h/6 hours/g' |sed 's/2year/2 years/g'`"
        period1=`echo -n '-'; echo ${period}`
        period2=`echo ${period} |sed 's/1//g'`
	$rrdtool graph $img/dnsall-${period2}.png -s ${period1} \
	-t "ALL DNS Service traffic for the last ${time}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 690 -l 0 -a PNG -v "Requests/minute" \
	DEF:allus=$RRDDB:allu:AVERAGE \
	DEF:allts=$RRDDB:allt:AVERAGE \
        CDEF:allu=allus,60,* \
        CDEF:allt=allts,60,* \
        VDEF:minallu=allu,MINIMUM \
        VDEF:minallt=allt,MINIMUM \
        VDEF:maxallu=allu,MAXIMUM \
        VDEF:maxallt=allt,MAXIMUM \
        VDEF:avgallu=allu,AVERAGE \
        VDEF:avgallt=allt,AVERAGE \
        VDEF:lstallu=allu,LAST \
        VDEF:lstallt=allt,LAST \
        "COMMENT: \l" \
        "COMMENT:                    " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:allu#1A7200:UDP Queries  " \
        "LINE1:allu#1A7200" \
        "GPRINT:lstallu:%5.1lf %s   " \
        "GPRINT:avgallu:%5.1lf %s   " \
        "GPRINT:minallu:%5.1lf %s   " \
        "GPRINT:maxallu:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE2:allt#000099:TCP Queries  " \
        "GPRINT:lstallt:%5.1lf %s   " \
        "GPRINT:avgallt:%5.1lf %s   " \
        "GPRINT:minallt:%5.1lf %s   " \
        "GPRINT:maxallt:%5.1lf %s   \l" \
        "COMMENT: \l" \
        "COMMENT:                                                            Last Updated\: $CURRENTTIME \l" > /dev/null


	$rrdtool graph $img/network-${period2}.png -s -1${period1} \
	-t "DNS Service traffic for the last ${time}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 690 -l 0 -a PNG -v "Requests/second" \
	DEF:ns1us=$RRDDB:ns1u:AVERAGE \
	DEF:ns2us=$RRDDB:ns2u:AVERAGE \
	DEF:ns3us=$RRDDB:ns3u:AVERAGE \
	DEF:ns4us=$RRDDB:ns4u:AVERAGE \
	DEF:allus=$RRDDB:allu:AVERAGE \
        CDEF:ns1u=ns1us,60,* \
        CDEF:ns2u=ns2us,60,* \
        CDEF:ns3u=ns3us,60,* \
        CDEF:ns4u=ns4us,60,* \
        CDEF:allu=allus,60,* \
	VDEF:minns1u=ns1u,MINIMUM \
	VDEF:minns2u=ns2u,MINIMUM \
	VDEF:minns3u=ns3u,MINIMUM \
	VDEF:minns4u=ns4u,MINIMUM \
	VDEF:minallu=allu,MINIMUM \
	VDEF:maxns1u=ns1u,MAXIMUM \
	VDEF:maxns2u=ns2u,MAXIMUM \
	VDEF:maxns3u=ns3u,MAXIMUM \
	VDEF:maxns4u=ns4u,MAXIMUM \
	VDEF:maxallu=allu,MAXIMUM \
	VDEF:avgns1u=ns1u,AVERAGE \
	VDEF:avgns2u=ns2u,AVERAGE \
	VDEF:avgns3u=ns3u,AVERAGE \
	VDEF:avgns4u=ns4u,AVERAGE \
	VDEF:avgallu=allu,AVERAGE \
	VDEF:lstns1u=ns1u,LAST \
	VDEF:lstns2u=ns2u,LAST \
	VDEF:lstns3u=ns3u,LAST \
	VDEF:lstns4u=ns4u,LAST \
	VDEF:lstallu=allu,LAST \
	VDEF:totns1u=ns1u,TOTAL \
	VDEF:totns2u=ns2u,TOTAL \
	VDEF:totns3u=ns3u,TOTAL \
	VDEF:totns4u=ns4u,TOTAL \
	VDEF:totallu=allu,TOTAL \
	"COMMENT: \l" \
	"COMMENT:            " \
	"COMMENT:Current   " \
	"COMMENT:Average   " \
	"COMMENT:Minimum   " \
	"COMMENT:Maximum   " \
	"COMMENT:Total     \l" \
	"COMMENT:   " \
	"AREA:ns1u#0000FF:NS1  :STACK" \
	"GPRINT:lstns1u:%5.1lf %s   " \
	"GPRINT:avgns1u:%5.1lf %s   " \
	"GPRINT:minns1u:%5.1lf %s   " \
	"GPRINT:maxns1u:%5.1lf %s   " \
	"GPRINT:totns1u:%5.1lf %s   \l" \
	"COMMENT:   " \
        "AREA:ns2u#FF0000:NS2  :STACK" \
        "GPRINT:lstns2u:%5.1lf %s   " \
        "GPRINT:avgns2u:%5.1lf %s   " \
        "GPRINT:minns2u:%5.1lf %s   " \
        "GPRINT:maxns2u:%5.1lf %s   " \
        "GPRINT:totns2u:%5.1lf %s   \l" \
        "COMMENT:   " \
	"AREA:ns3u#2AB352:NS3  :STACK" \
	"GPRINT:lstns3u:%5.1lf %s   " \
	"GPRINT:avgns3u:%5.1lf %s   " \
	"GPRINT:minns3u:%5.1lf %s   " \
	"GPRINT:maxns3u:%5.1lf %s   " \
	"GPRINT:totns3u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:ns4u#ff9900:NS4  :STACK" \
        "GPRINT:lstns4u:%5.1lf %s   " \
        "GPRINT:avgns4u:%5.1lf %s   " \
        "GPRINT:minns4u:%5.1lf %s   " \
        "GPRINT:maxns4u:%5.1lf %s   " \
        "GPRINT:totns4u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:allu#999999:ALL  " \
        "GPRINT:lstallu:%5.1lf %s   " \
        "GPRINT:avgallu:%5.1lf %s   " \
        "GPRINT:minallu:%5.1lf %s   " \
        "GPRINT:maxallu:%5.1lf %s   " \
        "GPRINT:totallu:%5.1lf %s   \l" \
        "COMMENT: \l" \
        "COMMENT:                                                            Last Updated\: $CURRENTTIME \l" > /dev/null
done

for period in 6h 1day 1week 1month 1year 2year
do
    for server in ns1 ns2 ns3 ns4
    do
        period1=`echo -n '-'; echo ${period}`
        period2=`echo ${period} |sed 's/1//g'`
        time="`echo ${period} |sed 's/1//g' |sed 's/6h/6 hours/g' |sed 's/2year/2 years/g'`"
        $rrdtool graph $img/dns${server}-${period2}.png -s ${period1} \
            -t "${server}.mattrude.com DNS traffic for the last ${time}" -z \
            -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
            -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
            -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
            -h 200 -w 690 -l 0 -a PNG -v "Requests/minute" \
            DEF:ns1us=$RRDDB:${server}u:AVERAGE \
            DEF:ns1ts=$RRDDB:${server}t:AVERAGE \
            CDEF:ns1u=ns1us,60,* \
            CDEF:ns1t=ns1ts,60,* \
            VDEF:minns1u=ns1u,MINIMUM \
            VDEF:minns1t=ns1t,MINIMUM \
            VDEF:maxns1u=ns1u,MAXIMUM \
            VDEF:maxns1t=ns1t,MAXIMUM \
            VDEF:avgns1u=ns1u,AVERAGE \
            VDEF:avgns1t=ns1t,AVERAGE \
            VDEF:lstns1u=ns1u,LAST \
            VDEF:lstns1t=ns1t,LAST \
            "COMMENT:  \l" \
            "COMMENT:                      " \
            "COMMENT:Current   " \
            "COMMENT:Average   " \
            "COMMENT:Minimum   " \
            "COMMENT:Maximum   \l" \
            "COMMENT:   " \
            "AREA:ns1u#1A7200:UDP Queries " \
            "LINE1:ns1u#1A7200" \
            "GPRINT:lstns1u:%5.1lf %s   " \
            "GPRINT:avgns1u:%5.1lf %s   " \
            "GPRINT:minns1u:%5.1lf %s   " \
            "GPRINT:maxns1u:%5.1lf %s   \l" \
            "COMMENT:   " \
            "LINE2:ns1t#000099:TCP Queries " \
            "LINE1:ns1t#000099" \
            "GPRINT:lstns1t:%5.1lf %s   " \
            "GPRINT:avgns1t:%5.1lf %s   " \
            "GPRINT:minns1t:%5.1lf %s   " \
            "GPRINT:maxns1t:%5.1lf %s   \l" \
            "COMMENT: \l" \
            "COMMENT:                                                            Last Updated\: $CURRENTTIME \l" > /dev/null
    done
done

for server in 1 2 3 4
do

    $rrdtool graph $img/dnsns${server}-small.png -s -6h -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 100 -w 300 -l 0 -a PNG \
        DEF:nsus=$RRDDB:ns${server}u:AVERAGE \
        DEF:nsts=$RRDDB:ns${server}t:AVERAGE \
        CDEF:nsu=nsus,60,* \
        CDEF:nst=nsts,60,* \
        "AREA:nsu#1A7200" \
        "LINE2:nst#000099" > /dev/null
done

$rrdtool graph $img/dnsall-small.png -s -6h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 150 -w 690 -l 0 -a PNG \
    DEF:allus=$RRDDB:allu:AVERAGE \
    DEF:allts=$RRDDB:allt:AVERAGE \
    CDEF:allu=allus,60,* \
    CDEF:allt=allts,60,* \
    "AREA:allu#1A7200" \
    "LINE2:allt#000099" \
    "COMMENT:                                                                Last Updated\: $CURRENTTIME \l" > /dev/null

$rrdtool graph $img/queries-small.png -s -6h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 150 -w 690 -l 0 -a PNG \
    DEF:ns1sm=$RRDDB:ns1u:AVERAGE \
    DEF:ns2sm=$RRDDB:ns2u:AVERAGE \
    DEF:ns3sm=$RRDDB:ns3u:AVERAGE \
    DEF:ns4sm=$RRDDB:ns4u:AVERAGE \
    DEF:allsm=$RRDDB:all:AVERAGE \
    CDEF:ns1=ns1sm,60,* \
    CDEF:ns2=ns2sm,60,* \
    CDEF:ns3=ns3sm,60,* \
    CDEF:ns4=ns4sm,60,* \
    CDEF:all=allsm,60,* \
    "LINE1:ns1#000099" \
    "LINE1:ns2#FF0000" \
    "LINE1:ns3#2AB352" \
    "LINE1:ns4#ff9900" \
    "LINE1:all#000000" \
    "COMMENT:                                                                Last Updated\: $CURRENTTIME \l" > /dev/null


for HOST in ns1 ns2 ns3
do
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
        DEF:rrqrya=${RRDDIR}/${HOST}.rrd:qrya:AVERAGE \
        DEF:rrqryaaaa=${RRDDIR}/${HOST}.rrd:qryaaaa:AVERAGE \
        DEF:rrqrycname=${RRDDIR}/${HOST}.rrd:qrycname:AVERAGE \
        DEF:rrqrydnskey=${RRDDIR}/${HOST}.rrd:qrydnskey:AVERAGE \
        DEF:rrqryds=${RRDDIR}/${HOST}.rrd:qryds:AVERAGE \
        DEF:rrqrymx=${RRDDIR}/${HOST}.rrd:qrymx:AVERAGE \
        DEF:rrqryns=${RRDDIR}/${HOST}.rrd:qryns:AVERAGE \
        DEF:rrqrysoa=${RRDDIR}/${HOST}.rrd:qrysoa:AVERAGE \
        DEF:rrqrysrv=${RRDDIR}/${HOST}.rrd:qrysrv:AVERAGE \
        DEF:rrqrytlsa=${RRDDIR}/${HOST}.rrd:qrytlsa:AVERAGE \
        DEF:rrqrytxt=${RRDDIR}/${HOST}.rrd:qrytxt:AVERAGE \
        CDEF:qrya=rrqrya,60,* \
        CDEF:qryaaaa=rrqryaaaa,60,* \
        CDEF:qrycname=rrqrycname,60,* \
        CDEF:qrydnskey=rrqrydnskey,60,* \
        CDEF:qryds=rrqryds,60,* \
        CDEF:qrymx=rrqrymx,60,* \
        CDEF:qryns=rrqryns,60,* \
        CDEF:qrysoa=rrqrysoa,60,* \
        CDEF:qrysrv=rrqrysrv,60,* \
        CDEF:qrytlsa=rrqrytlsa,60,* \
        CDEF:qrytxt=rrqrytxt,60,* \
        VDEF:minqrya=qrya,MINIMUM \
        VDEF:minqryaaaa=qryaaaa,MINIMUM \
        VDEF:minqrycname=qrycname,MINIMUM \
        VDEF:minqrydnskey=qrydnskey,MINIMUM \
        VDEF:minqryds=qryds,MINIMUM \
        VDEF:minqrymx=qrymx,MINIMUM \
        VDEF:minqryns=qryns,MINIMUM \
        VDEF:minqrysoa=qrysoa,MINIMUM \
        VDEF:minqrysrv=qrysrv,MINIMUM \
        VDEF:minqrytlsa=qrytlsa,MINIMUM \
        VDEF:minqrytxt=qrytxt,MINIMUM \
        VDEF:maxqrya=qrya,MAXIMUM \
        VDEF:maxqryaaaa=qryaaaa,MAXIMUM \
        VDEF:maxqrycname=qrycname,MAXIMUM \
        VDEF:maxqrydnskey=qrydnskey,MAXIMUM \
        VDEF:maxqryds=qryds,MAXIMUM \
        VDEF:maxqrymx=qrymx,MAXIMUM \
        VDEF:maxqryns=qryns,MAXIMUM \
        VDEF:maxqrysoa=qrysoa,MAXIMUM \
        VDEF:maxqrysrv=qrysrv,MAXIMUM \
        VDEF:maxqrytlsa=qrytlsa,MAXIMUM \
        VDEF:maxqrytxt=qrytxt,MAXIMUM \
        VDEF:avgqrya=qrya,AVERAGE \
        VDEF:avgqryaaaa=qryaaaa,AVERAGE \
        VDEF:avgqrycname=qrycname,AVERAGE \
        VDEF:avgqrydnskey=qrydnskey,AVERAGE \
        VDEF:avgqryds=qryds,AVERAGE \
        VDEF:avgqrymx=qrymx,AVERAGE \
        VDEF:avgqryns=qryns,AVERAGE \
        VDEF:avgqrysoa=qrysoa,AVERAGE \
        VDEF:avgqrysrv=qrysrv,AVERAGE \
        VDEF:avgqrytlsa=qrytlsa,AVERAGE \
        VDEF:avgqrytxt=qrytxt,AVERAGE \
        VDEF:lstqrya=qrya,LAST \
        VDEF:lstqryaaaa=qryaaaa,LAST \
        VDEF:lstqrycname=qrycname,LAST \
        VDEF:lstqrydnskey=qrydnskey,LAST \
        VDEF:lstqryds=qryds,LAST \
        VDEF:lstqrymx=qrymx,LAST \
        VDEF:lstqryns=qryns,LAST \
        VDEF:lstqrysoa=qrysoa,LAST \
        VDEF:lstqrysrv=qrysrv,LAST \
        VDEF:lstqrytlsa=qrytlsa,LAST \
        VDEF:lstqrytxt=qrytxt,LAST \
        "COMMENT: \l" \
        "COMMENT:                      " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:qrya#008000:     A Queries  :STACK" \
        "GPRINT:lstqrya:%5.1lf %s   " \
        "GPRINT:avgqrya:%5.1lf %s   " \
        "GPRINT:minqrya:%5.1lf %s   " \
        "GPRINT:maxqrya:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qryaaaa#008040:  AAAA Queries  :STACK" \
        "GPRINT:lstqryaaaa:%5.1lf %s   " \
        "GPRINT:avgqryaaaa:%5.1lf %s   " \
        "GPRINT:minqryaaaa:%5.1lf %s   " \
        "GPRINT:maxqryaaaa:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrycname#008080: CNAME Queries  :STACK" \
        "GPRINT:lstqrycname:%5.1lf %s   " \
        "GPRINT:avgqrycname:%5.1lf %s   " \
        "GPRINT:minqrycname:%5.1lf %s   " \
        "GPRINT:maxqrycname:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrydnskey#004080:DNSKEY Queries  :STACK" \
        "GPRINT:lstqrydnskey:%5.1lf %s   " \
        "GPRINT:avgqrydnskey:%5.1lf %s   " \
        "GPRINT:minqrydnskey:%5.1lf %s   " \
        "GPRINT:maxqrydnskey:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qryds#000080:    DS Queries  :STACK" \
        "GPRINT:lstqryds:%5.1lf %s   " \
        "GPRINT:avgqryds:%5.1lf %s   " \
        "GPRINT:minqryds:%5.1lf %s   " \
        "GPRINT:maxqryds:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrymx#400080:    MX Queries  :STACK" \
        "GPRINT:lstqrymx:%5.1lf %s   " \
        "GPRINT:avgqrymx:%5.1lf %s   " \
        "GPRINT:minqrymx:%5.1lf %s   " \
        "GPRINT:maxqrymx:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qryns#800080:    NS Queries  :STACK" \
        "GPRINT:lstqryns:%5.1lf %s   " \
        "GPRINT:avgqryns:%5.1lf %s   " \
        "GPRINT:minqryns:%5.1lf %s   " \
        "GPRINT:maxqryns:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrysoa#800040:   SOA Queries  :STACK" \
        "GPRINT:lstqrysoa:%5.1lf %s   " \
        "GPRINT:avgqrysoa:%5.1lf %s   " \
        "GPRINT:minqrysoa:%5.1lf %s   " \
        "GPRINT:maxqrysoa:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrysrv#800000:   SRV Queries  :STACK" \
        "GPRINT:lstqrysrv:%5.1lf %s   " \
        "GPRINT:avgqrysrv:%5.1lf %s   " \
        "GPRINT:minqrysrv:%5.1lf %s   " \
        "GPRINT:maxqrysrv:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrytlsa#804000:  TLSA Queries  :STACK" \
        "GPRINT:lstqrytlsa:%5.1lf %s   " \
        "GPRINT:avgqrytlsa:%5.1lf %s   " \
        "GPRINT:minqrytlsa:%5.1lf %s   " \
        "GPRINT:maxqrytlsa:%5.1lf %s   \l" \
        "COMMENT:   " \
        "AREA:qrytxt#808000:   TXT Queries  :STACK" \
        "GPRINT:lstqrytxt:%5.1lf %s   " \
        "GPRINT:avgqrytxt:%5.1lf %s   " \
        "GPRINT:minqrytxt:%5.1lf %s   " \
        "GPRINT:maxqrytxt:%5.1lf %s   \l" \
        "COMMENT: \l" \
        "COMMENT:                                                            Last Updated\: $CURRENTTIME \l" > /dev/null
    done
done


rm -f /tmp/ns1 /tmp/ns2 /tmp/ns3 /tmp/ns4
