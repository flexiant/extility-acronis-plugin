#!/usr/bin/perl

system("apt-get --yes --force-yes update");
system("apt-get --yes --force-yes install rpm gcc make libxml-xpath-perl");
system("wget -O linux_agent.bin 'https://bc-msptest2.acronis.com/api/links/linux_agent?language=en'");
system("chmod 755 linux_agent.bin");