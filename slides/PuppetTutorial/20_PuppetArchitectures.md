# Puppet architectures - Overview

### The Components of a Puppet architecture

### Where to define classes

### Where to define parameters

### Where to place files

### Puppet security



# Components of a Puppet architecture

### Tasks we deal with

Definition of the **classes** to be included in each nodeDefinition of the **parameters** to use for each nodeDefinition of the configuration **files** provided to the nodes

### Components

**/etc/puppet/manifests/site.pp** - The default manifests loaded by the Master

**ENC** - The (optional) Enternal Node Classifier

**ldap** - (Optional) LDAP backend

**Hiera** - Data key-value backend

**Public modules** - Public shared modules

**Site modules** - Local custom modules

# Where to define classes

The classes to include in each node can be defined on:

**/etc/puppet/manifests/site.pp** - Top or Node scope variables

**ENC** - Under the classes key in the provided YAML

**ldap** - puppetClass attribute

**Hiera** - Via the ```hiera_include()``` function

**Site modules** - In roles and profiles or other grouping classes


# Where to define parameters

The classes to include in each node can be defined on:

**/etc/puppet/manifests/site.pp** - Under the node statement

**ENC** - Following the ENC logic

**ldap** - puppetVar attribute

**Hiera** - Via the ```hiera()```, ```hiera_hash()```, ```hiera_array()``` functions of Puppet 3 Data Bindings

**Shared  modules** - OS related settings

**Site modules** - Custom and logical settings

**Facts** - Facts calculated on the client


# Where to define files

**Shared  modules** - Default templates populated via module's params

**Site modules** - All custom static files and templates

**Hiera** - Via the **hiera-file** plugin

**Fileserver** custom mount points




# Code workflow management

  Puppet code should stay under a SCM (Git, Subversion, Mercurial... whatever )

  We must be able to test the code before committing to production

  Testing Puppet code syntax is easy, testing its effects is not

  Different testing methods for different purposes

  Different code workflow options

  Recommended: Couple Puppet environments with code branches [More info](http://puppetlabs.com/blog/git-workflow-and-puppet-environments/)




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
