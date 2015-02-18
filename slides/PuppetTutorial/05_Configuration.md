# Puppet Configuration and basic usage - Overview

### Operational modes: apply / agent

### Configuration files and options

### Useful Paths

### Anatomy of a Puppet run



# Operational modes

## Masterless - puppet apply

Our Puppet code (written in manifests) is applied directly on the target system.

No need of a complete client-server infrastructure.

Have to distribute manifests and modules to the managed nodes.

Command used: ```puppet apply``` (generally as root)

## Master / Client - puppet agent

We have clients, our managed nodes, where Puppet client is installed.

And we have one or more Masters where Puppet server runs as a service

Client/Server communication is via https (**port 8140**)

Clients certificates have to be accepted (**signed**) on the Master

Command used on the client: ```puppet agent```  (generally as **root**)

Command used on the server: ```puppet master```  (generally as **puppet**)


# Masterless setup

  Puppet manifests are deployed directly on nodes and applied locally:

    puppet apply --modulepath /modules/ /manifests/file.pp

  More fine grained control on what goes in production for what nodes

  Ability to trigger multiple truly parallel Puppet runs

  No single point of failure, no Master performance issues

  Need to define a fitting deployment workflow. Hints: [Rump](https://github.com/railsmachine/rump) - [supply_drop](https://github.com/pitluga/supply_drop)

  With Puppet > 2.6 we can use file sources urls like:

    puppet:///modules/example42/apache/vhost.conf

    # they point to
    $modulepath/example42/apache/vhost.conf

  StoreConfigs usage require access to Puppet DB from every node

# Master / Client Setup

  A Puppet server (running as 'puppet') listening on 8140 on the Puppet Master (the server )

  A Puppet client (running as 'root') on each managed node

  Client can be run as a service (default), via cron (with random delays), manually or via MCollective

  Client and Server have to share SSL certificates. New client certificates must be signed by the Master CA

  It's possible to enable automatic clients certificates signing on the Master (be aware of security concerns)


# Certificates management

  On the Master we can use ```puppet cert``` to manage certificates

  List the (client) certificates to sign:

    puppet cert list

  List all certificates: signed (+), revoked (-), to sign ( ):

    puppet cert list --all

  Sign a client certificate:

    puppet cert sign <certname>

  Remove a client certificate:

    puppet cert clean <certname>

  Client stores its certificates and the server's public one in ```$vardir/ssl**``` (```/var/lib/puppet/ssl``` on Puppet OpenSource)

  Server stores clients public certificates and in ```$vardir/ssl/ca``` (```/var/lib/puppet/ssl/ca```). DO NOT remove this directory.

# Certificates management - First run

By default the first Puppet run on a client fails:

    client # puppet agent -t
           # "Exiting; no certificate found and waitforcert is disabled"

An optional ````--waitforcert 60``` parameter makes client wait 60 seconds before giving up.

The server has received the client's CSR which has to be manually signed:

    server # puppet cert sign <certname>

Once signed on the Master, the client can connect and receive its catalog:

    client # puppet agent -t


If we have issues with certificates (reinstalled client or other certs related problemes):

Be sure client and server times are synced

Clean up the client certificate. On the client remove it:

    client # mv /var/lib/puppet/ssl /var/lib/puppet/ssl.old

On the Master clean the old client certificate:

    server # puppet cert clean <certname>


# Puppet configuration: puppet.conf

It's Puppet main configuration file.
On opensource Puppet is generally in:

    /etc/puppet/puppet.conf

On Puppet Enterprise:

    /etc/puppetlabs/puppet/puppet.conf

When running as a normal user can be placed in the home directory:

    /home/user/.puppet/puppet.conf

Configurations are divided in [stanzas] for different Puppet sub commands

Common for all commands: **[main]**

For puppet agent (client): **[agent]** (Was [puppetd] in Puppet pre 2.6)

For puppet apply (client): **[user]** (Was [puppet])

For puppet master (server): **[master]** (Was [puppetmasterd] and [puppetca])

Hash sign (#) can be used for comments.


# Main configuration options

To view all or a specific configuration setting:

    puppet config print all
    puppet config print modulepath

### Important options under **[main]** section:

  **vardir**: Path where Puppet stores dynamic data.

  **ssldir**: Path where SSL certifications are stored.

### Under **[agent]** section:

  **server**: Host name of the PuppetMaster. (Default: puppet)

  **certname**: Certificate name used by the client. (Default is its fqdn)

  **runinterval**: Number of minutes between Puppet runs, when running as service. (Default: 30)

  **report**: If to send Puppet runs' reports to the **report_server. (Default: true)

### Under **[master]** section:

  **autosign**: If new clients certificates are automatically signed. (Default: false)

  **reports**: How to manage clients' reports (Default: store)

  **storeconfigs**: If to enable store configs to support exported resources. (Default: false)

Full [configuration reference](http://docs.puppetlabs.com/references/latest/configuration.html)  on the official site.


# Common command-line parameters

All configuration options can be overriden by command-line options.

A very common option used when we want to see immediately the effect of a Puppet run (it's actually the combination of: --onetime, --verbose, --ignorecache, --no-daemonize, --no-usecacheonfailure, --detailed-exit-codes, --no-splay, and --show_diff):

    puppet agent --test # Can be abbreviate to -t

Run puppet agent in foreground and debug mode:

    puppet agent --test --debug

Run a dry-run puppet without making any change to the system:

    puppet agent --test --noop

Run puppet using an environment different from the default one:

    puppet agent --test --environment testing

Wait for certificate approval (by default 120 seconds) in the first Puppet run (useful during automated first fime installation if PuppetMaster's autosign is false):

    puppet agent --test --waitforcert 120


# Useful paths

**/var/log/puppet** contains logs (but also on normal syslog files, with facility daemon), both for agents and master

**/var/lib/puppet** contains Puppet operational data (catalog, certs, backup of files...)

**/var/lib/puppet/ssl** contains SSL certificate

**/var/lib/puppet/clientbucket** contains backup copies of the files changed by Puppet

**/etc/puppet/manifests/site.pp** (On Master) The first manifest that the master parses when a client connects in order to produce the configuration to apply to it (Default on Puppet < 3.6 where are used **config-file environments**)

**/etc/puppet/environments/production/manifests/site.pp** (On Master) The first manifest that the master parses when using **directory environments** (recommended from Puppet 3.6 and default on Puppt >= 4)

**/etc/puppet/modules** and **/usr/share/puppet/modules** (On Master) The default directories where modules are searched

**/etc/puppet/environments/production/modules** (On Master) An extra place where modules are looked for when using **directory environments**


# Other configuration files:

####  **auth.conf**

Defines ACLs to access Puppet's REST interface. [Details](http://docs.puppetlabs.com/guides/rest_auth_conf.html)

#### **fileserver.conf**

Used to manage ACL on files served from sources different than modules [Details](http://docs.puppetlabs.com/guides/file_serving.html)

#### **puppetdb.conf**

Settings for connection to PuppetDB, if used. [Details](http://docs.puppetlabs.com/puppetdb/1/)

#### **tagmail.conf** , **autosign.conf** , **device.conf** , **routes.yaml**

These are other configuration files for specific functions. [Details](http://docs.puppetlabs.com/guides/configuring.html)

#### **/etc/puppet/environments/production/environment.conf**

Contains environment specific settings


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


# Puppet Configuration and basic usage - Practice

Use the command ```puppet config print``` to explore Puppet's configuration options.

Give a look to the various Puppet related directories and their contents:
```/etc/puppet```, ```/var/lib/puppet```, ```/var/log/puppet```

If the lab setup allows it, run Puppet on a new client and sign its certificate on the master.

Explore and describe the output of a Puppet run in apply and agent mode.
