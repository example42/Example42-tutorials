# Hiera - Overview

### Principles behind Hiera

### Configuring hierarchies

### Hiera plugins

### Using Hiera from Puppet and the CLI



# Introduction to Hiera

Hiera is the **key/value lookup tool** of reference where to store Puppet user data.

It provides an highly customizable way to lookup for parameters values based on a custom hierarchy using many different backends for data storage.

It provides a command line tool ```hiera``` that we can use to interrogate direclty the Hiera data and functions to be used inside Puppet manifests: ```hiera()``` , ```hiera_array()``` , ```hiera_hash()``` , ```hiera_include()```

Hiera is installed by default with Puppet version 3 and is available as separated download on earlier version ([Installation instructions](http://docs.puppetlabs.com/hiera/1/installing.html)).

We need Hiera only on the PuppetMaster (or on any node, if we have a masterless setup).

Currently version 1 is available, here is its [official documentation](http://docs.puppetlabs.com/hiera/1/).

# Hiera configuration: hiera.yaml

Hiera's configuration file is in yaml format and is called **hiera.yaml** here we define the hierarchy we want to use and the backends where data is placed, with backend specific settings.

Hiera's configuration file path is different according to how it's invoked:

### From the Command Line and Ruby code

Default path: ```/etc/hiera.yaml```

### From Puppet

Default path for Puppet OpenSource: ```/etc/puppet/hiera.yaml```

Default path for Puppet Enterprise: ```/etc/puppetlabs/puppet/hiera.yaml```

It's good practice the symlink these alternative configuration files in order to avoid inconsistencies when using Hiera from the shell line or within Puppet manifests:

    ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml

## Default configuration
By default Hiera does not provide a configuration file. The default settings are equivalent to this:

    ---
    :backends: yaml
    :yaml:
      :datadir: /var/lib/hiera
    :hierarchy: common
    :logger: console


# Hiera Backends

One powerful feature of Hiera is that the actual key-value data can be retrieved from different backends.

With the ```:backends``` global configuration we define which backends to use, then, for each used backend we can specify backend specific settings.

### Build it backends:

**yaml** - Data is stored in yaml files (in the ```:datadir``` directory)

**json** - Data is stored in json files (in the ```:datadir``` directory)

**puppet** - Data is defined in Puppet (in the ```:datasouce``` class)

### Extra backends:
Many additional backends are available, the most interesting ones are:

[**gpg**](https://github.com/crayfishx/hiera-gpg) - Data is stored in GPG encripted yaml files

[**http**](https://github.com/crayfishx/hiera-http) - Data is retrieved from a REST service

[**mysql**](https://github.com/crayfishx/hiera-mysql) - Data is retrieved from a Mysql database

[**redis**](https://github.com/reliantsecurity/hiera-redis) - Data is retrieved from a Redis database

### Custom backends
It's relatively easy to write custom backends for Hiera. Here are some [development instructions](http://docs.puppetlabs.com/hiera/1/custom_backends.html)

# Hierarchies

With the ```:hierarchy``` global setting we can define a string or an array of data sources which are checked in order, from top to bottom.

When the same key is present on different data sources by default is chosen the top one. We can override this setting with the ```:merge_behavior``` global configuration. Check [this page](http://docs.puppetlabs.com/hiera/1/lookup_types.html#deep-merging-in-hiera--120) for details.

In hierarchies we can interpolate variables with the %{} notation (variables interpolation is possible also in other parts of hiera.yaml and in the same data sources).

This is an example Hierarchy:

        ---
        :hierarchy:
          - "nodes/%{::clientcert}"
          - "roles/%{::role}"
          - "%{::osfamily}"
          - "%{::environment}"
          - common

Note that the referenced variables should be expressed with their fully qualified name. They are generally facts or Puppet's top scope variables (in the above example, **$::role** is not a standard fact, but is generally useful to have it (or a similar variable that identifies the kind of server) in our hierarchy).

If we have more backends, for each backend is evaluated the full hierarchy.

We can find some real world hierarchies samples in this [Puppet Users Group post](https://groups.google.com/forum/?hl=it#!topic/puppet-users/cCfimbolUio)

More information on hierarchies [here](http://docs.puppetlabs.com/hiera/1/hierarchy.html).

# Using Hiera in Puppet
The data stored in Hiera can be retrieved by the PuppetMaster while compiling the catalog using the hiera() function.

In our manifests we can have something like this:

        $my_dns_servers = hiera("dns_servers")

Which assigns to the variable ***$my_dns_servers*** (can have any name) the top value retrieved by Hiera for the key ***dns_servers***

We may prefer, in some cases, to retrieve all the values retrieved in the hierarchy's data sources of a given key and not the first use, use hiera_array() for that.

        $my_dns_servers = hiera_array("dns_servers")

If we expect an hash as value for a given key we can use the hiera() function to retrieve the top value found or hiera_hash to merge all the found values in a single hash:

        $openssh_settings = hiera_hash("openssh_settings")

### Extra parameters
All these hiera functions may receive additional parameters:

Second argument: **default** value if no one is found

Third argument: **override** with a custom data source added at the top of the configured hierarchy

        $my_dns_servers = hiera("dns_servers","8.8.8.8","$country")

# Puppet 3 data bindings
With Puppet 3 Hiera is shipped directly with Puppet and an automatic hiera lookup is done for each class' parameter using the key **$class::$argument**: this functionality is called data bindings or automatic parameter lookup.

For example in a class definition like:

      class openssh (
        template = undef,
      ) { . . . }

Puppet 3 automatically looks for the Hiera key openssh::template if no value is explitely set when declaring the class.

To emulate a similar behaviour on pre Puppet 3 we should write something like:

      class openssh (
        template = hiera("openssh::template"),
      ) { . . . }

If a default value is set for an argument that value is used only when user has not explicitly declared value for that argument and Hiera automatic lookup for that argument doesn't return any value.


# Using hiera from the command line

Hiera can be invoken via the command line to interrogate the given key's value:

        hiera dns_servers

This will return the default value as no node's specific information is provided. More useful is to provide the whole facts' yaml of a node, so that the returned value can be based on the dynamic values of the hierarchy.
On the Pupppet Masters the facts of all the managed clients are collected in $vardir/yaml/facts so this is the best place to see how Hiera evaluates keys for different clients:

        hiera dns_servers --yaml /var/lib/puppet/yaml/facts/<node>.yaml

We can also pass variables useful to test the hierarchy, directly from the command line:

        hiera ntp_servers operatingsystem=Centos
        hiera ntp_servers operatingsystem=Centos hostname=jenkins

To have a deeper insight of Hiera operations use the debug (-d) option:

        hiera dns_servers -d

To make an hiera array lookup (equivalent to hiera_array()):

        hiera dns_servers -a

To make an hiera hash lookup (equivalent to hiera_hash()):

        hiera openssh::settings -h
