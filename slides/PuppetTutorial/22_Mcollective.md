# MCollective - Overview

### Essentials

### Installation and configuration

### The mco command


# MCollective essentials

An orchestration framework that allows massively parallel actions on the infrastructure's server

Based on 3 components:

  One or more central consoles, from where the **mco** command can be issued

  The infrastructure nodes, where an **agent** receives and executes the requested actions

  A middleware **message broker**, that allows communication between master(s) and agents


Possible actions are based on plugins
Common plugins are: **service**, **package**, **puppetd**, **filemgr**...

Simple RCPs allow easy definitions of new plugins or actions.

Security is handled at different layers: transport, authentication and authorization via different plugins. Here is a [Security Overview](http://docs.puppetlabs.com/mcollective/security.html)

# Installation

Some distros provide native mcollective packages but it's definitively recommended to use [PuppetLabs repositories](http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html) to have recent mcollective versions and packages for the needed dependencies.

  On the nodes to be managed just install the **mcollective** package, it's configuration file is **/etc/mcollective/server.cfg**

  On the administrative nodes, from where to control the infrastructure, install the **mcollective-client** package, it's configuration file is **/etc/mcollective/client.cfg**

  On both clients and servers we have to install the [agent plugins](http://docs.puppetlabs.com/mcollective/deploy/plugins.html)

  On the middleware server(s) install **activemq** or **rabbitmq**

# Configuration

Configuration files are similar for [server](http://docs.puppetlabs.com/mcollective/configure/server.html) and [client](http://docs.puppetlabs.com/mcollective/configure/client.html).

They are in a typical setting = value format and # are used for comments.

We have to define to connetion settings to the middleware, the settings for the chosen security plugins, the facts source and other general settings.

The setup of the whole infrastructure involves some parameters to be consistent on the mcollective config files and the message broker ones (credentials and eventually certificates).

There can be different setups, according to the security plugins used, the recommended one is well described in the [Standard Mcollective Deployment](http://docs.puppetlabs.com/mcollective/deploy/standard.html)


# Using the mco command

The **mco** command is installed on the Mcollective clients and can be used to perform actions on any node of the infrastructure.

General usage:

    mco [subcommand] [options] [filters]
    mco rpc [options] [filters] <agent> <action> [<key=val> <key=val>]

Most used subcommands are **ping** , **rpc** , **inventory**, **find**

Most used options are: **-batch SIZE** (send requests in batches), **-q** (quiet), **-j** (produce Json output),  **-v** (verbose)

Most used filters are: **-F <fact=val>** (Match hosts with the specified fact value), **-I <name>** (Match host with the given name).

Sample commands:

    mco help
    mco help rpc
    mco ping
    mco rpc service status service=mysqld
    mco ping -F datacenter=eu-1
