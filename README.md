# BIND Website Source


### Refresh all hosts

The below command will delete and rebuild the website on all hosts

    rm -rf /var/www/bind/*; ssh ns2.mattrude.com rm -rf /var/www/bind/*; ssh ns3.mattrude.com rm -rf /var/www/bind/*; \
    cd /root/bind-status-site; jekyll build; \
    sed 's/ns1/ns2/g' _config.yml > ns2.yml; jekyll build -c ns2.yml -d /root/ns2; scp -r /root/ns2/* ns2.mattrude.com:/var/www/bind; rm ns2.yml; \
    sed 's/ns1/ns3/g' _config.yml > ns3.yml; jekyll build -c ns3.yml -d /root/ns3; scp -r /root/ns3/* ns3.mattrude.com:/var/www/bind; rm ns3.yml; \
    rm -rf /root/ns2 /root/ns3

### Remove all hosts site

The below is part of the above command, but will only remove the data and not refresh it.

    rm -rf /var/www/bind/*; ssh ns2.mattrude.com rm -rf /var/www/bind/*; ssh ns3.mattrude.com rm -rf /var/www/bind/*

### Remove RRD on all hosts

This will remove the dns.rrd file from all hosts.

    rm -f /var/lib/rrd/dns.rrd; ssh ns2.mattrude.com rm -f /var/lib/rrd/dns.rrd; ssh ns3.mattrude.com rm -f /var/lib/rrd/dns.rrd

### Remove all Graph Images

This will remove all png files from all hosts.

    rm -f /var/www/bind-img/*; ssh ns2.mattrude.com rm -f /var/www/bind-img/*; ssh ns3.mattrude.com rm -f /var/www/bind-img/*;

### Update bind-rrd.udpater.sh

Update the `bind-rrd-updater.sh` on all hosts.

    cd /root/bind-status-site
    scp bind-rrd-updater.sh ns2.mattrude.com:/usr/local/sbin/; scp bind-rrd-updater.sh ns3.mattrude.com:/usr/local/sbin/

