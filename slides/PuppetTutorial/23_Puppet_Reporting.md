# Puppet reporting - Overview

### Reporting overview

### Understanding puppet run output


# Reporting

  In reports Puppet stores information of what has changed on the system after a Puppet run

  Reports are sent from the client to the Master, if report is enabled

    # On client's puppet.conf [agent]
    report = true

  On the Master different report processors may be enabled

    # On server's puppet.conf [master]
    reports = log,tagmail,store,https
    reporturl = http://localhost:3000/reports

# Understanding Puppet runs output

  Puppet is very informative about what it does on the functions

    /Stage[main]/Example42::CommonSetup/File[/etc/motd]/content:
    --- /etc/motd	2012-12-13 10:37:29.000000000 +0100
    +++ /tmp/puppet-file20121213-19295-qe4wv2-0	2012-12-13 10:38:19.000000000 +0100
    @@ -4,4 +4,4 @@
    -Last Puppet Run: Thu Dec 13 10:36:58 CET 2012
    +Last Puppet Run: Thu Dec 13 10:38:00 CET 2012
    Info: /Stage[main]/Example42::CommonSetup/File[/etc/motd]: Filebucketed /etc/motd to main with sum 623bcd5f8785251e2cd00a88438d6d08
    /Stage[main]/Example42::CommonSetup/File[/etc/motd]/content: content changed '{md5}623bcd5f8785251e2cd00a88438d6d08' to '{md5}91855575e2252c38ce01efedf1f48cd3'

  The above lines refer to a change made by Puppet on /etc/motd
  The File[/etc/motd] resource is defined in the class example42::commonsetup
  A diff is shown of what has changed (the diff appears when running puppet agent -t in interactive mode)
  The original file has been filebucketed (saved) with checksum 623bcd5f8785251e2cd00a88438d6d08
  We can retrieve the original file in /var/lib/puppet/clientbucket/6/2/3/b/c/d/5/f/623bcd5f8785251e2cd00a88438d6d08/contents
  We can search for all the old versions of /etc/motd with

    grep -R '/etc/motd' /var/lib/puppet/clientbucket/*
