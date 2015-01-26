# Modules

  Self Contained and Distributable *recipes* contained in a directory with a predefined structure

  Used to manage an application, system's resources, a local site or more complex structures

  Modules must be placed in the Puppet Master's modulepath

    puppet config print modulepath
    /etc/puppet/modules:/usr/share/puppet/modules

  Puppet module tool to interface with Puppet Modules Forge

    puppet help module
    [...]
    ACTIONS:
      build        Build a module release package.
      changes      Show modified files of an installed module.
      generate     Generate boilerplate for a new module.
      install      Install a module from the Puppet Forge or an archive.
      list         List installed modules
      search       Search the Puppet Forge for a module.
      uninstall    Uninstall a puppet module.
      upgrade      Upgrade a puppet module.

  GitHub, also, is full of Puppet modules


# Paths of a module

  Modules have a standard structure:

    mysql/            # Main module directory

    mysql/manifests/  # Manifests directory. Puppet code here. Required.
    mysql/lib/        # Plugins directory. Ruby code here
    mysql/templates/  # ERB Templates directory
    mysql/files/      # Static files directory
    mysql/spec/       # Puppet-rspec test directory
    mysql/tests/      # Tests / Usage examples directory

    mysql/Modulefile  # Module's metadata descriptor

  This layout enables useful conventions


# Modules paths conventions

  Classes and defines autoloading:

    include mysql
    # Main mysql class is placed in: $modulepath/mysql/manifests/init.pp

    include mysql::server
    # This class is defined in: $modulepath/mysql/manifests/server.pp

    mysql::conf { ...}
    # This define is defined in: $modulepath/mysql/manifests/conf.pp

    include mysql::server::ha
    # This class is defined in: $modulepath/mysql/manifests/server/ha.pp

  Provide files based on Erb Templates (Dynamic content)

    content => template('mysql/my.cnf.erb'),
    # Template is in: $modulepath/mysql/templates/my.cnf.erb

  Provide static files (Static content). Note you can use content OR source for the same file.

    source => 'puppet:///modules/mysql/my.cnf'
    # File is in: $modulepath/mysql/files/my.cnf


# Erb templates

  Files provisioned by Puppet can be Ruby ERB templates

  In a template all the Puppet variables (facts or user assigned) can be used :

    # File managed by Puppet on <%= @fqdn %>
    search <%= @domain %>

  But also more elaborated Ruby code

    <% @dns_servers.each do |ns| %>
    nameserver <%= ns %>
    <% end %>

  The computed template content is placed directly inside the catalog
  (Sourced files, instead, are retrieved from the puppetmaster during catalog application)


# Principes behind a Reusable Module

  Data Separation

    - Configuration data is defined outside the module (or even Puppet manifests)
    - Module behavior is managed via APIs
    - Allow module's extension and override via external data

  Reusability

    - Support different OS. Easily allow new additions.
    - Customize behavior without changing module code
    - Do not force author idea on how configurations should be provided

  Standardization

    - Follow PuppetLabs style guidelines (puppet-lint)
    - Have coherent, predictable and intuitive interfaces
    - Provide contextual documentation (puppet-doc)

  Interoperability

    - Limit cross-module dependencies
    - Allow easy modules cherry picking
    - Be self contained, do not interfere with other modules' resources
 
# Testing Modules
Puppet code testing can be done at different levels with different tools

**puppet parser validate <manifest.pp>** - Checks the syntax of a manifest

**puppet-lint <manifest.pp>** - A gem that checks the style of a manifest

**puppet-rspec** - A gem that runs rspec unit tests on a module (Based on compiled catalog)

**cucumber-puppet** - A gem that runs cucumber tests a module (Based on compiled catalog) OBSOLETE

**puppet-rspec-system** - A gem that creates Vagrant VM and check for the expected results of real Puppet runs

**Beaker** - A gem that runs acceptance tests on multiple Vagrant VM



# Modules documentation with Puppet Doc

  Puppetdoc generates documentation from manifests comments:

    $ puppet doc [--all] --mode rdoc [--outputdir ] [--debug|--verbose] [--trace]
      [--modulepath ] [--manifestdir ] [--config ]

  Comment classes as below:

    # Class: apache
    #
    # This module manages Apache
    #
    # Parameters:
    #
    # Actions:
    #
    # Requires:
    #
    # [Remember: No empty lines between comments and class definition]
    class apache {
      ...
    }

