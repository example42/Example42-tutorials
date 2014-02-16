


# Anatomy of a Puppet Run - Part 1: Catalog compilation

  Execute Puppet on the client

    Client shell # puppet agent -t

  If pluginsync = true (default from Puppet 3.0) the client retrieves all extra plugins (facts, types and providers) present in modules on the server's $modulepath

    Client output # Info: Retrieving plugin

  The client runs facter and send its facts to the server

    Client output # Info: Loading facts in /var/lib/puppet/lib/facter/... [...]

  The server looks for the client's hostname (or certname, if different from the hostname) and looks into its nodes list

  The server compiles the catalog for the client using also client's facts

    Server's logs # Compiled catalog for <client> in environment production in 8.22 seconds

  If there are not syntax errors in the processed Puppet code, the server sends the catalog to the client, in PSON format.

# Anatomy of a Puppet Run - Part 2: Catalog application

    Client output # Info: Caching catalog for <client>

  The client receives the catalog and starts to apply it locally
  If there are dependency loops the catalog can't be applied and the whole tun fails.

    Client output # Info: Applying configuration version '1355353107'
    
  All changes to the system are shown here. If there are errors (in red or pink, according to Puppet versions) they are relevant to specific resources but do not block the application of the other resources (unless they depend on the failed ones).

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
