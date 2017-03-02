---
layout: default
lang: en
title: Contact Me
permalink: /contact/
---

This site is maintained by [Matt Rude](https://mattrude.com). If you would like to report any problems or bugs, please send a email or XMPP messsage to the address `matt@mattrude.com`.

### My Public PGP Key Information

**My Default RSA Key:**

    uid = Matt Rude
    pub = rsa2048/95B0761F 2015-03-02
    sub = rsa2048/BC158061 2015-03-02
    fingerprint = 71FD 20E3 2815 8C32 2133  FBBE C490 9EE4 95B0 761F

**My Elliptic Curve Cryptography (ECC) Key:**

    uid = Matt Rude
    pub = nistp256/03305F35 2015-02-15
    fingerprint = 77F1 D65B 5FF0 54DC 9286  6078 0314 CD85 0330 5F35

* You may validate my keys using one of my [DANE](https://keyserver.mattrude.com/guides/dns-dane-cert-records/) or [PKA](https://keyserver.mattrude.com/guides/public-key-association/) DNS records.

### Signed Contact Information

A signed copy of this infromation, using my [RSA key](https://keyserver.mattrude.com/k/0xc4909ee495b0761f) may be found [here](https://mattrude.com/contact.txt), or using my [ECC key](https://mattrude.com/keys/0x03305F35.asc), may be found [here](https://mattrude.com/contact-ecc.txt). You may validate these files by running the below commands:

<pre><code><small>curl -s https://mattrude.com/contact.txt |gpg --keyserver-options auto-key-retrieve --auto-key-locate pka --verify
curl -s https://mattrude.com/contact-ecc.txt |gpg2 --keyserver-options auto-key-retrieve --auto-key-locate pka --verify</small></code></pre>
