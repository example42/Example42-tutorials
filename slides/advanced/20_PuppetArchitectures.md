# Masterless setup

  Puppet manifests are deployed directly on nodes and applied locally:

    puppet apply --modulepath /my/modules/path /my/manifest/file.pp

  More fine grained control on what goes in production for what nodes

  Ability to trigger multiple truly parallel Puppet runs

  No single point of failure, no Master performance issues

  Need to define a fitting deployment workflow. Hints: [Rump](https://github.com/railsmachine/rump) - [supply_drop](https://github.com/pitluga/supply_drop)

  With Puppet > 2.6 you can use file sources urls like:

    puppet:///modules/example42/apache/vhost.conf

    # they point to
    $modulepath/example42/apache/vhost.conf

  StoreConfigs usage requires a common Mysql (or Puppet DB) backend... Write permissions must be granted to all nodes


# Master Slave Setup

  A Puppet server (running as 'puppet') listening on 8140 on the PuppetMaster

  A Puppet client (running as 'root') on each managed node

  Client can be run as a service (default), via cron (with random delays), manually or via MCollective

  Client and Server have to share SSL certificates. New client certificates must be signed by the Master CA

  It's possible to enable automatic clients certificates signing on the Master (may involve security issues)

    # On puppet.conf [master]
    autosign = true # Default = false


# Certificates management

  On the Master you can use puppet cert to manage certificates

    puppet cert --list       # List the (client) certificates to sign
    puppet cert --list --all # List all certificates: signed (+), revoked (-), to sign ( )
    puppet cert --sign <certname> # Sign the certificate of the client

  By default the first Puppet run on a client fails:

    client # puppet agent -t    # "Exiting; no certificate found and waitforcert is disabled"
    # An optional --waitforcert 60 parameter makes client wait 60 seconds before giving up

    server # puppet cert --list # The client hostname or certname appears

    server # puppet cert --sign <client> # The client's certificate is signed, now it's trusted

    client # puppet agent -t    # The client fetch its catalog now
        
  Server accepts only one certificate for hostname, if a server is destroyed and recreated with the same hostnae the old certificate has to be removed

    server # puppet cert --clean <client> # The old cert is removed, a new signing is required

  Client stores its certificates and the server's public one in **$vardir/ssl** (/var/lib/puppet/ssl on Puppet OpenSource)
  If you have issues with certificates, this directory can be deleted, it's recreated at puppet run (the relevant cert must be cleaned on the master too)

  Server stores clients public certificates and in **$vardir/ssl/ca** (/var/lib/puppet/ssl/ca). DO NOT remove this directory.


# Anatomy of a Puppet Run

  Execute Puppet on the client

    Client shell # puppet agent -t

  If pluginsync = true (default from Puppet 3.0) the client retrieves all extra plugins (facts, types and providers) from the server

    Client output # Info: Retrieving plugin

  The client runs facter and send its facts to the server

    Client output # Info: Loading facts in /var/lib/puppet/lib/facter/... [...]

  The server looks for the client's hostname (or certname, if different from the hostname) and looks into its nodes list

  The server compiles the catalog for the client using also client's facts

    Server's logs # Compiled catalog for <client> in environment production in 8.22 seconds

  If there are not syntax errors in the processed Puppet code, the server sends the catalog to the client, in PSON format.

    Client output # Info: Caching catalog for <client>

  The client receives the catalog and starts to apply it locally

    Client output # Info: Applying configuration version '1355353107'
    [...] All changes to the system are shown here. If there are errors they are relevant to specific resources

  At the end ot the Puppet run the client sends to the server a report of what has been changed

    Client output # Finished catalog run in 13.78 seconds

  The server eventually sends the report to a Report Collector


# Code workflow management

  Puppet code should stay under a SCM (Git, Subversion, Mercurial... whatever )

  You must be able to test the code before committing to production

  Testing Puppet code syntax is easy, testing its effects is not

  Different testing methods for different purposes

  Different code workflow options

  Recommended: Couple Puppet environments with code branches [More info](http://puppetlabs.com/blog/git-workflow-and-puppet-environments/)


# Testing Puppet code

  Testing can be done at different levels:

  Syntax checks are easy and can be automated
  Review [here](http://projects.puppetlabs.com/projects/1/wiki/Puppet_Version_Control) for hints on how to hook code checks when committing the code

    puppet parser validate mysql/manifests/init.pp

  Checks on the code style with puppet-lint
  Not required, but useful for a coherent code style layout according to PuppetLabs guidelines

    gem install puppet-lint
    puppet-lint mysql/manifests/init.pp

  Checks on the code logic and the expected catalog
  Tools like Rpec-Puppet or Cucumber-Puppet can verify code effects after catalog compilation

  Check on the impact of a Puppet run on a system
  The most important, and difficult to cover.

    Canary nodes

    Early fail notification

    Split environments


# Puppet Security considerations

  Client / Server communications are encrypted with SSL x509 certificates
  By default the CA on the PuppetMaster requires manual signing of certificate requests

    # In puppet.conf under [master] section:
    autosign = false

  On the Puppet Master (as unprivileged user) runs a service that must be reached by every node (port 8140 TCP)

  On the Client Puppet runs a root but does not expose a public service

  Sensitive data might be present in the catalog and in reports

  Sensitive data might be present in the puppet code (Propagated under a SCM)

  [Security advisories](http://www.puppetlas.com/security)
