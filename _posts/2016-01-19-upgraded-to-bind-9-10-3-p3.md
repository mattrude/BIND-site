---
layout: news
title: Upgraded to BIND 9.10.3-p3
date: 2016-01-19 22:00
category: ALL
---

Today BIND was updated from [9.10.3-p2](https://kb.isc.org/article/AA-01328/81/BIND-9.10.3-P2-Release-Notes.html) to [9.10.3-p3](https://kb.isc.org/article/AA-01346/81/BIND-9.10.3-P3-Release-Notes.html) on all hosts. This update has the following changes over 9.10.3-p2.

### Security Fixes

* Specific APL data could trigger an INSIST. This flaw was discovered by Brian Mitchell and is disclosed in [CVE-2015-8704](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-8704).
* Certain errors that could be encountered when printing out or logging an OPT record containing a CLIENT-SUBNET option could be mishandled, resulting in an assertion failure. This flaw was discovered by Brian Mitchell and is disclosed in [CVE-2015-8705](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-8705).
* Named is potentially vulnerable to the OpenSSL vulnerabilty described in [CVE-2015-3193](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-3193).
* Insufficient testing when parsing a message allowed records with an incorrect class to be be accepted, triggering a REQUIRE failure when those records were subsequently cached. This flaw is disclosed in [CVE-2015-8000](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-8000).
* Incorrect reference counting could result in an INSIST failure if a socket error occurred while performing a lookup. This flaw is disclosed in [CVE-2015-8461](https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2015-8461).
