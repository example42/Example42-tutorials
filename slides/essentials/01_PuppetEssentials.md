# Puppet

  A **Configuration Management** Tool

  A framework for **Systems Automation**

  A Declarative Domain Specific Language (**DSL**)

  An **OpenSource software** in written Ruby

  Works on Linux, Unix (Solaris, AIX, *BSD), MacOS, Windows

  Developed by **[Puppet Labs](http://puppetlabs.com)**

  Used by (http://puppetlabs.com/customers/companies/) ...

  ... and **many** others


# Configuration Management advantages

  **Infrastructure as Code**: Track, Test, Deploy, Reproduce, Scale

  Code commits log shows the **history of change** on the infrastructure

  **Reproducible setups**: Do once, repeat forever

  **Scale** quickly: Done for one, use on many

  **Coherent** and consistent server setups

  **Aligned Environments** for devel, test, qa, prod nodes


# References and Ecosystem

  [Puppet Labs](http://puppetlabs.com) - The Company behind Puppet

  [Puppet](http://puppetlabs.com/puppet/puppet-open-source/) - The OpenSource version

  [Puppet Enterprise](http://puppetlabs.com/puppet/puppet-enterprise/) - The commercial version

  [The Community](http://puppetlabs.com/community/overview/) - Active and vibrant

  [Puppet Documentation](http://docs.puppetlabs.com/) - Main and Official reference

  Puppet Modules on: [Module Forge](http://forge.puppetlabs.com) and [GitHub](https://github.com/search?q=puppet)

  Software related to Puppet:
    [MCollective](http://docs.puppetlabs.com/mcollective/) - Infrastructure Orchestration framework
    [Hiera](http://docs.puppetlabs.com/hiera/1/) - Key-value lookup tool where Puppet data can be placed
    [PuppetDB](http://docs.puppetlabs.com/puppetdb/1/) - An Inventory Service and StoredConfigs backend
    [Puppet DashBoard](http://docs.puppetlabs.com/dashboard/) - A Puppet *Web frontend* and External Node Classifier (ENC)
    [The Foreman](http://theforeman.org/) - A well-known third party provisioning tool and Puppet ENC
    [Geppetto](http://cloudsmith.github.com/geppetto) - A Puppet IDE based on Eclipse


# Installation

  Debian, Ubuntu
  Available by default

    # On clients (nodes):
    apt-get install puppet

    # On server (master):
    apt-get install puppetmaster

  RedHat, Centos, Fedora
  Add EPEL repository or RHN Extra channel

    # On clients (nodes):
    yum install puppet

    # On server (master):
    yum install puppet-server

  Use [PuppetLabs repositories](http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html) for latest updates

  [Installation Instructions](http://docs.puppetlabs.com/guides/installation.html) for different OS

