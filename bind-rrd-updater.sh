#!/bin/bash

RRDDIR="/var/lib/rrd/"
img="/var/www/bind-img/"
rrdtool=/usr/bin/rrdtool
RRDDB="${RRDDIR}/dns.rrd"


if [ ! -e $RRDDB ]
then 
	$rrdtool create $RRDDB \
        --step 300 \
	DS:ns1:COUNTER:600:0:1000000 \
	DS:ns2:COUNTER:600:0:1000000 \
	DS:ns3:COUNTER:600:0:1000000 \
	DS:all:COUNTER:600:0:1000000 \
	RRA:AVERAGE:0.5:1:600 \
	RRA:AVERAGE:0.5:6:672 \
	RRA:AVERAGE:0.5:24:732 \
	RRA:AVERAGE:0.5:144:1460
fi


NS1QUERY=`curl -sL http://ns1.mattrude.com:8053/json |jq .opcodes.QUERY`
NS2QUERY=`curl -sL http://ns2.mattrude.com:8053/json |jq .opcodes.QUERY`
NS3QUERY=`curl -sL http://ns3.mattrude.com:8053/json |jq .opcodes.QUERY`
QUERYALL="$(($NS1QUERY+$NS2QUERY+$NS3QUERY))"
#echo $NS1QUERY $NS2QUERY $NS3QUERY $QUERYALL

mkdir -p $RRDDIR
$rrdtool update $RRDDB -t ns1:ns2:ns3:all N:${NS1QUERY}:${NS2QUERY}:${NS3QUERY}:${QUERYALL}

mkdir -p $img
for period in 6h day week month year
do
	$rrdtool graph $img/dnsall-${period}.png -s -1${period} \
	-t "ALL DNS Service traffic for the last ${period}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
	DEF:all=$RRDDB:all:AVERAGE \
        VDEF:minall=all,MINIMUM \
        VDEF:maxall=all,MAXIMUM \
        VDEF:avgall=all,AVERAGE \
        VDEF:lstall=all,LAST \
        "COMMENT: \l" \
        "COMMENT:                " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:all#1A7200:Queries  " \
        "LINE1:all#1A7200" \
        "GPRINT:lstall:%5.1lf %s   " \
        "GPRINT:avgall:%5.1lf %s   " \
        "GPRINT:minall:%5.1lf %s   " \
        "GPRINT:maxall:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns1-${period}.png -s -1${period} \
        -t "ns1.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns1=$RRDDB:ns1:AVERAGE \
        VDEF:minns1=ns1,MINIMUM \
        VDEF:maxns1=ns1,MAXIMUM \
        VDEF:avgns1=ns1,AVERAGE \
        VDEF:lstns1=ns1,LAST \
        "COMMENT: \l" \
        "COMMENT:                " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns1#1A7200:Queries  " \
        "LINE1:ns1#1A7200" \
        "GPRINT:lstns1:%5.1lf %s   " \
        "GPRINT:avgns1:%5.1lf %s   " \
        "GPRINT:minns1:%5.1lf %s   " \
        "GPRINT:maxns1:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns2-${period}.png -s -1${period} \
        -t "ns2.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns2=$RRDDB:ns2:AVERAGE \
        VDEF:minns2=ns2,MINIMUM \
        VDEF:maxns2=ns2,MAXIMUM \
        VDEF:avgns2=ns2,AVERAGE \
        VDEF:lstns2=ns2,LAST \
        "COMMENT: \l" \
        "COMMENT:                " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns2#1A7200:Queries  " \
        "LINE1:ns2#1A7200" \
        "GPRINT:lstns2:%5.1lf %s   " \
        "GPRINT:avgns2:%5.1lf %s   " \
        "GPRINT:minns2:%5.1lf %s   " \
        "GPRINT:maxns2:%5.1lf %s   \l" > /dev/null

        $rrdtool graph $img/dnsns3-${period}.png -s -1${period} \
        -t "ns3.mattrude.com DNS traffic for the last ${period}" -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
        DEF:ns3=$RRDDB:ns3:AVERAGE \
        VDEF:minns3=ns3,MINIMUM \
        VDEF:maxns3=ns3,MAXIMUM \
        VDEF:avgns3=ns3,AVERAGE \
        VDEF:lstns3=ns3,LAST \
        "COMMENT: \l" \
        "COMMENT:                " \
        "COMMENT:Current   " \
        "COMMENT:Average   " \
        "COMMENT:Minimum   " \
        "COMMENT:Maximum   \l" \
        "COMMENT:   " \
        "AREA:ns3#1A7200:Queries  " \
        "LINE1:ns3#1A7200" \
        "GPRINT:lstns3:%5.1lf %s   " \
        "GPRINT:avgns3:%5.1lf %s   " \
        "GPRINT:minns3:%5.1lf %s   " \
        "GPRINT:maxns3:%5.1lf %s   \l" > /dev/null

	$rrdtool graph $img/network-${period}.png -s -1${period} \
	-t "DNS Service traffic for the last ${period}" -z \
	-c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
	-c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
	-c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 200 -w 650 -l 0 -a PNG -v "Requests/second" \
	DEF:ns1=$RRDDB:ns1:AVERAGE \
	DEF:ns2=$RRDDB:ns2:AVERAGE \
	DEF:ns3=$RRDDB:ns3:AVERAGE \
	DEF:all=$RRDDB:all:AVERAGE \
	VDEF:minns1=ns1,MINIMUM \
	VDEF:minns2=ns2,MINIMUM \
	VDEF:minns3=ns3,MINIMUM \
	VDEF:minall=all,MINIMUM \
	VDEF:maxns1=ns1,MAXIMUM \
	VDEF:maxns2=ns2,MAXIMUM \
	VDEF:maxns3=ns3,MAXIMUM \
	VDEF:maxall=all,MAXIMUM \
	VDEF:avgns1=ns1,AVERAGE \
	VDEF:avgns2=ns2,AVERAGE \
	VDEF:avgns3=ns3,AVERAGE \
	VDEF:avgall=all,AVERAGE \
	VDEF:lstns1=ns1,LAST \
	VDEF:lstns2=ns2,LAST \
	VDEF:lstns3=ns3,LAST \
	VDEF:lstall=all,LAST \
	VDEF:totns1=ns1,TOTAL \
	VDEF:totns2=ns2,TOTAL \
	VDEF:totns3=ns3,TOTAL \
	VDEF:totall=all,TOTAL \
	"COMMENT: \l" \
	"COMMENT:            " \
	"COMMENT:Current   " \
	"COMMENT:Average   " \
	"COMMENT:Minimum   " \
	"COMMENT:Maximum   " \
	"COMMENT:Total     \l" \
	"COMMENT:   " \
	"LINE1:ns1#0000FF:NS1  " \
	"LINE1:ns1#0000FF" \
	"GPRINT:lstns1:%5.1lf %s   " \
	"GPRINT:avgns1:%5.1lf %s   " \
	"GPRINT:minns1:%5.1lf %s   " \
	"GPRINT:maxns1:%5.1lf %s   " \
	"GPRINT:totns1:%5.1lf %s   \l" \
	"COMMENT:   " \
        "LINE1:ns2#FF0000:NS2  " \
        "LINE1:ns2#FF0000" \
        "GPRINT:lstns2:%5.1lf %s   " \
        "GPRINT:avgns2:%5.1lf %s   " \
        "GPRINT:minns2:%5.1lf %s   " \
        "GPRINT:maxns2:%5.1lf %s   " \
        "GPRINT:totns2:%5.1lf %s   \l" \
        "COMMENT:   " \
	"LINE1:ns3#2AB352:NS3  " \
	"LINE1:ns3#2AB352" \
	"GPRINT:lstns3:%5.1lf %s   " \
	"GPRINT:avgns3:%5.1lf %s   " \
	"GPRINT:minns3:%5.1lf %s   " \
	"GPRINT:maxns3:%5.1lf %s   " \
	"GPRINT:totns3:%5.1lf %s   \l" \
        "COMMENT:   " \
        "LINE1:all#000000:ALL  " \
        "LINE1:all#000000" \
        "GPRINT:lstall:%5.1lf %s   " \
        "GPRINT:avgall:%5.1lf %s   " \
        "GPRINT:minall:%5.1lf %s   " \
        "GPRINT:maxall:%5.1lf %s   " \
        "GPRINT:totall:%5.1lf %s   \l" > /dev/null
done

        $rrdtool graph $img/dnsall-small.png -s -16h \
        -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 150 -w 550 -l 0 -a PNG \
        DEF:all=$RRDDB:all:AVERAGE \
        "AREA:all#1A7200" > /dev/null

        $rrdtool graph $img/dnsns1-small.png -s -16h -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 100 -w 300 -l 0 -a PNG \
        DEF:ns1=$RRDDB:ns1:AVERAGE \
        "AREA:ns1#1A7200" > /dev/null

        $rrdtool graph $img/dnsns2-small.png -s -16h -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 100 -w 300 -l 0 -a PNG \
        DEF:ns2=$RRDDB:ns2:AVERAGE \
        "AREA:ns2#1A7200" > /dev/null

        $rrdtool graph $img/dnsns3-small.png -s -16h -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 100 -w 300 -l 0 -a PNG \
        DEF:ns3=$RRDDB:ns3:AVERAGE \
        "AREA:ns3#1A7200" > /dev/null

        $rrdtool graph $img/queries-small.png -s -16h \
        -z \
        -c "BACK#FFFFFF" -c "SHADEA#FFFFFF" -c "SHADEB#FFFFFF" \
        -c "MGRID#AAAAAA" -c "GRID#CCCCCC" -c "ARROW#333333" \
        -c "FONT#333333" -c "AXIS#333333" -c "FRAME#333333" \
        -h 100 -w 300 -l 0 -a PNG \
        DEF:ns1=$RRDDB:ns1:AVERAGE \
        DEF:ns2=$RRDDB:ns2:AVERAGE \
        DEF:ns3=$RRDDB:ns3:AVERAGE \
        DEF:all=$RRDDB:all:AVERAGE \
        "LINE1:ns1#0000FF" \
        "LINE1:ns2#FF0000" \
        "LINE1:ns3#2AB352" \
        "LINE1:all#000000" > /dev/null
