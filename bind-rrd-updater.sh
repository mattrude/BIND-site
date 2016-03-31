#!/bin/bash

RRDDIR="/var/lib/rrd"
img="/var/www/bind-img/"
rrdtool=/usr/bin/rrdtool
RRDDB="${RRDDIR}/dns.rrd"
CURRENTTIME=`TZ='UTC' date |sed 's/\:/\\\:/g'`

sleep $[ ( $RANDOM % 10 )  + 1 ]s

mkdir -p $RRDDIR
if [ ! -e $RRDDB ]; then 
    $rrdtool create $RRDDB --step 300 \
	DS:ns1u:COUNTER:600:0:100000 \
	DS:ns1t:COUNTER:600:0:100000 \
	DS:ns2u:COUNTER:600:0:100000 \
	DS:ns2t:COUNTER:600:0:100000 \
	DS:ns3u:COUNTER:600:0:100000 \
	DS:ns3t:COUNTER:600:0:100000 \
	DS:ns4u:COUNTER:600:0:100000 \
	DS:ns4t:COUNTER:600:0:100000 \
	DS:allu:COUNTER:600:0:100000 \
	DS:allt:COUNTER:600:0:100000 \
	DS:all:COUNTER:600:0:100000 \
	RRA:AVERAGE:0.5:1:600 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460 \
	RRA:AVERAGE:0.5:288:2920
fi

mkdir -p /tmp
for HOST in ns1 ns2 ns3 ns4
do
    curl -sL http://${HOST}.mattrude.com:8053/json > /tmp/${HOST}
done

NS1QUDP=`cat /tmp/ns1 |jq .nsstats.QryUDP`
NS1QTCP=`cat /tmp/ns1 |jq .nsstats.QryTCP`
NS2QUDP=`cat /tmp/ns2 |jq .nsstats.QryUDP`
NS2QTCP=`cat /tmp/ns2 |jq .nsstats.QryTCP`
NS3QUDP=`cat /tmp/ns3 |jq .nsstats.QryUDP`
NS3QTCP=`cat /tmp/ns3 |jq .nsstats.QryTCP`
NS4QUDP=`cat /tmp/ns4 |jq .nsstats.QryUDP`
NS4QTCP=`cat /tmp/ns4 |jq .nsstats.QryTCP`

#rm -f /tmp/ns1 /tmp/ns2 /tmp/ns3 /tmp/ns4

if [ -z "${NS1QUDP}" ]; then NS1QUDP=0; fi
if [ -z "${NS1QTCP}" ]; then NS1QTCP=0; fi
if [ -z "${NS2QUDP}" ]; then NS2QUDP=0; fi
if [ -z "${NS2QTCP}" ]; then NS2QTCP=0; fi
if [ -z "${NS3QUDP}" ]; then NS3QUDP=0; fi
if [ -z "${NS3QTCP}" ]; then NS3QTCP=0; fi
if [ -z "${NS4QUDP}" ]; then NS4QUDP=0; fi
if [ -z "${NS4QTCP}" ]; then NS4QTCP=0; fi

if [ "${NS1QUDP}" == "null" ]; then NS1QUDP=0; fi
if [ "${NS1QTCP}" == "null" ]; then NS1QTCP=0; fi
if [ "${NS2QUDP}" == "null" ]; then NS2QUDP=0; fi
if [ "${NS2QTCP}" == "null" ]; then NS2QTCP=0; fi
if [ "${NS3QUDP}" == "null" ]; then NS3QUDP=0; fi
if [ "${NS3QTCP}" == "null" ]; then NS3QTCP=0; fi
if [ "${NS4QUDP}" == "null" ]; then NS4QUDP=0; fi
if [ "${NS4QTCP}" == "null" ]; then NS4QTCP=0; fi

QUERYALL="$(($NS1QUDP+$NS1QTCP+$NS2QUDP+$NS2QTCP+$NS3QUDP+$NS3QTCP+$NS4QUDP+$NS4QTCP))"
QUERYALLU="$(($NS1QUDP+$NS2QUDP+$NS3QUDP+$NS4QUDP))"
QUERYALLT="$(($NS1QTCP+$NS2QTCP+$NS3QTCP+$NS4QTCP))"
#echo "$NS1QUDP $NS1QTCP $NS2QUDP $NS2QTCP $NS3QUDP $NS3QTCP $NS4QUDP $NS4QTCP $QUERYALLU $QUERYALLT $QUERYALL"

mkdir -p $RRDDIR
$rrdtool update $RRDDB -t ns1u:ns1t:ns2u:ns2t:ns3u:ns3t:ns4u:ns4t:allu:allt:all N:$NS1QUDP:$NS1QTCP:$NS2QUDP:$NS2QTCP:$NS3QUDP:$NS3QTCP:$NS4QUDP:$NS4QTCP:$QUERYALLU:$QUERYALLT:$QUERYALL

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
        "LINE1:allt#000099" \
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
	DEF:alls=$RRDDB:all:AVERAGE \
        CDEF:ns1u=ns1us,60,* \
        CDEF:ns2u=ns2us,60,* \
        CDEF:ns3u=ns3us,60,* \
        CDEF:ns4u=ns4us,60,* \
        CDEF:all=alls,60,* \
	VDEF:minns1u=ns1u,MINIMUM \
	VDEF:minns2u=ns2u,MINIMUM \
	VDEF:minns3u=ns3u,MINIMUM \
	VDEF:minns4u=ns4u,MINIMUM \
	VDEF:minall=all,MINIMUM \
	VDEF:maxns1u=ns1u,MAXIMUM \
	VDEF:maxns2u=ns2u,MAXIMUM \
	VDEF:maxns3u=ns3u,MAXIMUM \
	VDEF:maxns4u=ns4u,MAXIMUM \
	VDEF:maxall=all,MAXIMUM \
	VDEF:avgns1u=ns1u,AVERAGE \
	VDEF:avgns2u=ns2u,AVERAGE \
	VDEF:avgns3u=ns3u,AVERAGE \
	VDEF:avgns4u=ns4u,AVERAGE \
	VDEF:avgall=all,AVERAGE \
	VDEF:lstns1u=ns1u,LAST \
	VDEF:lstns2u=ns2u,LAST \
	VDEF:lstns3u=ns3u,LAST \
	VDEF:lstns4u=ns4u,LAST \
	VDEF:lstall=all,LAST \
	VDEF:totns1u=ns1u,TOTAL \
	VDEF:totns2u=ns2u,TOTAL \
	VDEF:totns3u=ns3u,TOTAL \
	VDEF:totns4u=ns4u,TOTAL \
	VDEF:totall=all,TOTAL \
	"COMMENT: \l" \
	"COMMENT:            " \
	"COMMENT:Current   " \
	"COMMENT:Average   " \
	"COMMENT:Minimum   " \
	"COMMENT:Maximum   " \
	"COMMENT:Total     \l" \
	"COMMENT:   " \
	"LINE1:ns1u#0000FF:NS1  " \
	"LINE1:ns1u#0000FF" \
	"GPRINT:lstns1u:%5.1lf %s   " \
	"GPRINT:avgns1u:%5.1lf %s   " \
	"GPRINT:minns1u:%5.1lf %s   " \
	"GPRINT:maxns1u:%5.1lf %s   " \
	"GPRINT:totns1u:%5.1lf %s   \l" \
	"COMMENT:   " \
        "LINE1:ns2u#FF0000:NS2  " \
        "LINE1:ns2u#FF0000" \
        "GPRINT:lstns2u:%5.1lf %s   " \
        "GPRINT:avgns2u:%5.1lf %s   " \
        "GPRINT:minns2u:%5.1lf %s   " \
        "GPRINT:maxns2u:%5.1lf %s   " \
        "GPRINT:totns2u:%5.1lf %s   \l" \
        "COMMENT:   " \
	"LINE1:ns3u#2AB352:NS3  " \
	"LINE1:ns3u#2AB352" \
	"GPRINT:lstns3u:%5.1lf %s   " \
	"GPRINT:avgns3u:%5.1lf %s   " \
	"GPRINT:minns3u:%5.1lf %s   " \
	"GPRINT:maxns3u:%5.1lf %s   " \
	"GPRINT:totns3u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:ns4u#ff9900:NS4  " \
        "LINE1:ns4u#ff9900" \
        "GPRINT:lstns4u:%5.1lf %s   " \
        "GPRINT:avgns4u:%5.1lf %s   " \
        "GPRINT:minns4u:%5.1lf %s   " \
        "GPRINT:maxns4u:%5.1lf %s   " \
        "GPRINT:totns4u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:all#000000:ALL  " \
        "LINE1:all#000000" \
        "GPRINT:lstall:%5.1lf %s   " \
        "GPRINT:avgall:%5.1lf %s   " \
        "GPRINT:minall:%5.1lf %s   " \
        "GPRINT:maxall:%5.1lf %s   " \
        "GPRINT:totall:%5.1lf %s   \l" \
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
    DEF:ns1s=$RRDDB:ns1u:AVERAGE \
    DEF:ns2s=$RRDDB:ns2u:AVERAGE \
    DEF:ns3s=$RRDDB:ns3u:AVERAGE \
    DEF:ns4s=$RRDDB:ns4u:AVERAGE \
    DEF:alls=$RRDDB:all:AVERAGE \
    CDEF:ns1=ns1s,60,* \
    CDEF:ns2=ns2s,60,* \
    CDEF:ns3=ns3s,60,* \
    CDEF:ns4=ns4s,60,* \
    CDEF:all=alls,60,* \
    "LINE1:ns1#000099" \
    "LINE1:ns2#FF0000" \
    "LINE1:ns3#2AB352" \
    "LINE1:ns4#ff9900" \
    "LINE1:all#000000" \
    "COMMENT:                                                                Last Updated\: $CURRENTTIME \l" > /dev/null

