#!/bin/bash

RRDDIR="/var/lib/rrd"
img="/var/www/bind-img/"
rrdtool=/usr/bin/rrdtool
RRDDB="${RRDDIR}/dns.rrd"

mkdir -p $RRDDIR

if [ ! -e $RRDDB ]
then 
	$rrdtool create $RRDDB \
        --step 300 \
	DS:ns1u:COUNTER:600:0:1000000 \
	DS:ns1t:COUNTER:600:0:1000000 \
	DS:ns2u:COUNTER:600:0:1000000 \
	DS:ns2t:COUNTER:600:0:1000000 \
	DS:ns3u:COUNTER:600:0:1000000 \
	DS:ns3t:COUNTER:600:0:1000000 \
	DS:ns4u:COUNTER:600:0:1000000 \
	DS:ns4t:COUNTER:600:0:1000000 \
	DS:allu:COUNTER:600:0:1000000 \
	DS:allt:COUNTER:600:0:1000000 \
	DS:all:COUNTER:600:0:1000000 \
	RRA:AVERAGE:0.5:1:600 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460
fi


NS1QUDP=`curl -sL http://ns1.mattrude.com:8053/json |jq .nsstats.QryUDP`
NS1QTCP=`curl -sL http://ns1.mattrude.com:8053/json |jq .nsstats.QryTCP`
NS2QUDP=`curl -sL http://ns2.mattrude.com:8053/json |jq .nsstats.QryUDP`
NS2QTCP=`curl -sL http://ns2.mattrude.com:8053/json |jq .nsstats.QryTCP`
NS3QUDP=`curl -sL http://ns3.mattrude.com:8053/json |jq .nsstats.QryUDP`
NS3QTCP=`curl -sL http://ns3.mattrude.com:8053/json |jq .nsstats.QryTCP`
NS4QUDP=`curl -sL http://ns4.mattrude.com:8053/json |jq .nsstats.QryUDP`
NS4QTCP=`curl -sL http://ns4.mattrude.com:8053/json |jq .nsstats.QryTCP`

if [ -z "${NS1QUDP}" ]; then NS1QUDP=0; fi
if [ -z "${NS1QTCP}" ]; then NS1QTCP=0; fi
if [ -z "${NS2QUDP}" ]; then NS2QUDP=0; fi
if [ -z "${NS2QTCP}" ]; then NS2QTCP=0; fi
if [ -z "${NS3QUDP}" ]; then NS3QUDP=0; fi
if [ -z "${NS3QTCP}" ]; then NS3QTCP=0; fi
if [ -z "${NS4QUDP}" ]; then NS4QUDP=0; fi
if [ -z "${NS4QTCP}" ]; then NS4QTCP=0; fi

if [ "${NS1QUDP}" ]; then NS1QUDP=0; fi
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
echo "$NS1QUDP $NS1QTCP $NS2QUDP $NS2QTCP $NS3QUDP $NS3QTCP $NS4QUDP $NS4QTCP $QUERYALLU $QUERYALLT $QUERYALL"

mkdir -p $RRDDIR
$rrdtool update $RRDDB -t ns1u:ns1t:ns2u:ns2t:ns3u:ns3t:ns4u:ns4t:allu:allt:all N:$NS1QUDP:$NS1QTCP:$NS2QUDP:$NS2QTCP:$NS3QUDP:$NS3QTCP:$NS4QUDP:$NS4QTCP:$QUERYALLU:$QUERYALLT:$QUERYALL

mkdir -p $img
for period in 6h day week month year
do
	$rrdtool graph $img/dnsall-${period}.png -s -1${period} \
	-t "ALL DNS Service traffic for the last ${period}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
	DEF:allu=$RRDDB:allu:AVERAGE \
	DEF:allt=$RRDDB:allt:AVERAGE \
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
        "LINE1:allt#0000FF:TCP Queries  " \
        "LINE1:allt#0000FF" \
        "GPRINT:lstallt:%5.1lf %s   " \
        "GPRINT:avgallt:%5.1lf %s   " \
        "GPRINT:minallt:%5.1lf %s   " \
        "GPRINT:maxallt:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns1-${period}.png -s -1${period} \
        -t "ns1.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns1u=$RRDDB:ns1u:AVERAGE \
        DEF:ns1t=$RRDDB:ns1t:AVERAGE \
        VDEF:minns1u=ns1u,MINIMUM \
        VDEF:minns1t=ns1t,MINIMUM \
        VDEF:maxns1u=ns1u,MAXIMUM \
        VDEF:maxns1t=ns1t,MAXIMUM \
        VDEF:avgns1u=ns1u,AVERAGE \
        VDEF:avgns1t=ns1t,AVERAGE \
        VDEF:lstns1u=ns1u,LAST \
        VDEF:lstns1t=ns1t,LAST \
        "COMMENT:  \l" \
        "COMMENT:                          " \
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
        "LINE1:ns1t#0000FF:TCP Queries " \
        "LINE1:ns1t#0000FF" \
        "GPRINT:lstns1t:%5.1lf %s   " \
        "GPRINT:avgns1t:%5.1lf %s   " \
        "GPRINT:minns1t:%5.1lf %s   " \
        "GPRINT:maxns1t:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns2-${period}.png -s -1${period} \
        -t "ns2.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns2u=$RRDDB:ns2u:AVERAGE \
        DEF:ns2t=$RRDDB:ns2t:AVERAGE \
        VDEF:minns2u=ns2u,MINIMUM \
        VDEF:minns2t=ns2t,MINIMUM \
        VDEF:maxns2u=ns2u,MAXIMUM \
        VDEF:maxns2t=ns2t,MAXIMUM \
        VDEF:avgns2u=ns2u,AVERAGE \
        VDEF:avgns2t=ns2t,AVERAGE \
        VDEF:lstns2u=ns2u,LAST \
        VDEF:lstns2t=ns2t,LAST \
        "COMMENT:  \l" \
        "COMMENT:                          " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns2u#1A7200:UDP Queries " \
        "LINE1:ns2u#1A7200" \
        "GPRINT:lstns2u:%5.1lf %s   " \
        "GPRINT:avgns2u:%5.1lf %s   " \
        "GPRINT:minns2u:%5.1lf %s   " \
        "GPRINT:maxns2u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:ns2t#0000FF:TCP Queries " \
        "LINE1:ns2t#0000FF" \
        "GPRINT:lstns2t:%5.1lf %s   " \
        "GPRINT:avgns2t:%5.1lf %s   " \
        "GPRINT:minns2t:%5.1lf %s   " \
        "GPRINT:maxns2t:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns3-${period}.png -s -1${period} \
        -t "ns3.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns3u=$RRDDB:ns3u:AVERAGE \
        DEF:ns3t=$RRDDB:ns3t:AVERAGE \
        VDEF:minns3u=ns3u,MINIMUM \
        VDEF:minns3t=ns3t,MINIMUM \
        VDEF:maxns3u=ns3u,MAXIMUM \
        VDEF:maxns3t=ns3t,MAXIMUM \
        VDEF:avgns3u=ns3u,AVERAGE \
        VDEF:avgns3t=ns3t,AVERAGE \
        VDEF:lstns3u=ns3u,LAST \
        VDEF:lstns3t=ns3t,LAST \
        "COMMENT:  \l" \
        "COMMENT:                          " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns3u#1A7200:UDP Queries " \
        "LINE1:ns3u#1A7200" \
        "GPRINT:lstns3u:%5.1lf %s   " \
        "GPRINT:avgns3u:%5.1lf %s   " \
        "GPRINT:minns3u:%5.1lf %s   " \
        "GPRINT:maxns3u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:ns3t#0000FF:TCP Queries " \
        "LINE1:ns3t#0000FF" \
        "GPRINT:lstns3t:%5.1lf %s   " \
        "GPRINT:avgns3t:%5.1lf %s   " \
        "GPRINT:minns3t:%5.1lf %s   " \
        "GPRINT:maxns3t:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns4-${period}.png -s -1${period} \
        -t "ns4.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns4u=$RRDDB:ns4u:AVERAGE \
        DEF:ns4t=$RRDDB:ns4t:AVERAGE \
        VDEF:minns4u=ns4u,MINIMUM \
        VDEF:minns4t=ns4t,MINIMUM \
        VDEF:maxns4u=ns4u,MAXIMUM \
        VDEF:maxns4t=ns4t,MAXIMUM \
        VDEF:avgns4u=ns4u,AVERAGE \
        VDEF:avgns4t=ns4t,AVERAGE \
        VDEF:lstns4u=ns4u,LAST \
        VDEF:lstns4t=ns4t,LAST \
        "COMMENT:  \l" \
        "COMMENT:                          " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns4u#1A7200:UDP Queries " \
        "LINE1:ns4u#1A7200" \
        "GPRINT:lstns4u:%5.1lf %s   " \
        "GPRINT:avgns4u:%5.1lf %s   " \
        "GPRINT:minns4u:%5.1lf %s   " \
        "GPRINT:maxns4u:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:ns4t#0000FF:TCP Queries " \
        "LINE1:ns4t#0000FF" \
        "GPRINT:lstns4t:%5.1lf %s   " \
        "GPRINT:avgns4t:%5.1lf %s   " \
        "GPRINT:minns4t:%5.1lf %s   " \
        "GPRINT:maxns4t:%5.1lf %s   \l" > /dev/null


	$rrdtool graph $img/network-${period}.png -s -1${period} \
	-t "DNS Service traffic for the last ${period}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
	DEF:ns1u=$RRDDB:ns1u:AVERAGE \
	DEF:ns2u=$RRDDB:ns2u:AVERAGE \
	DEF:ns3u=$RRDDB:ns3u:AVERAGE \
	DEF:ns4u=$RRDDB:ns4u:AVERAGE \
	DEF:all=$RRDDB:all:AVERAGE \
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
        "GPRINT:totall:%5.1lf %s   \l" > /dev/null
done

$rrdtool graph $img/dnsall-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 150 -w 550 -l 0 -a PNG \
    DEF:allu=$RRDDB:allu:AVERAGE \
    DEF:allt=$RRDDB:allt:AVERAGE \
    "AREA:allu#1A7200" \
    "LINE1:allt#0000FF" > /dev/null

$rrdtool graph $img/dnsns1-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 100 -w 300 -l 0 -a PNG \
    DEF:ns1u=$RRDDB:ns1u:AVERAGE \
    DEF:ns1t=$RRDDB:ns1t:AVERAGE \
    "AREA:ns1u#1A7200" \
    "LINE1:ns1t#0000FF" > /dev/null

$rrdtool graph $img/dnsns2-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 100 -w 300 -l 0 -a PNG \
    DEF:ns2u=$RRDDB:ns2u:AVERAGE \
    DEF:ns2t=$RRDDB:ns2t:AVERAGE \
    "AREA:ns2u#1A7200" \
    "LINE1:ns2t#0000FF" > /dev/null

$rrdtool graph $img/dnsns3-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 100 -w 300 -l 0 -a PNG \
    DEF:ns3u=$RRDDB:ns3u:AVERAGE \
    DEF:ns3t=$RRDDB:ns3t:AVERAGE \
    "AREA:ns3u#1A7200" \
    "LINE1:ns3t#0000FF" > /dev/null

$rrdtool graph $img/dnsns4-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 100 -w 300 -l 0 -a PNG \
    DEF:ns4u=$RRDDB:ns4u:AVERAGE \
    DEF:ns4t=$RRDDB:ns4t:AVERAGE \
    "AREA:ns4u#1A7200" \
    "LINE1:ns4t#0000FF" > /dev/null

$rrdtool graph $img/queries-small.png -s -16h -z \
    -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
    -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
    -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
    -h 150 -w 550 -l 0 -a PNG \
    DEF:ns1=$RRDDB:ns1u:AVERAGE \
    DEF:ns2=$RRDDB:ns2u:AVERAGE \
    DEF:ns3=$RRDDB:ns3u:AVERAGE \
    DEF:ns4=$RRDDB:ns4u:AVERAGE \
    DEF:all=$RRDDB:all:AVERAGE \
    "LINE1:ns1#0000FF" \
    "LINE1:ns2#FF0000" \
    "LINE1:ns3#2AB352" \
    "LINE1:ns4#ff9900" \
    "LINE1:all#000000" > /dev/null
