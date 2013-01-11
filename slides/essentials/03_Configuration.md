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

  Hash (#) can be used for comments.


# Configuration options

  To view all or a specific configuration setting:

    puppet config print all
    puppet config print modulepath

  Important options under **[main]** section:
    **vardir**: Path where Puppet stores dynamic data.
    **ssldir**: Path where SSL certifications are stored.

  Under **[agent]** section:
    **server**: Host name of the PuppetMaster. (Default: puppet)
    **certname**: Certificate name used by the client. (Default is the hostname)
    **runinterval**: Number of minutes between Puppet runs, when running as service. (Default: 30)
    **report**: If to send Puppet runs' reports to the **report_server. (Default: true)

  Under **[master]** section:
    **autosign**: If new clients certificates are automatically signed. (Default: false)
    **reports**: How to manage clients' reports (Default: store)
    **storeconfigs**: If to enable store configs to support exported resources. (Default: false)

  Full [configuration reference] (http://docs.puppetlabs.com/references/latest/configuration.html)


# Common command-line parameters

  All configuration options can be overriden by command-line options.

  Run puppet agent in foreground and verbose mode.
  A very common option used when you want to see immediately the effect of a Puppet run.
  It's actually the combination of: --onetime, --verbose, --ignorecache, --no-daemonize, --no-usecacheonfailure, --detailed-exit-codes, --no-splay, and --show_diff

    puppet agent --test

  Run puppet agent in foreground and debug mode

    puppet agent --test --debug

  Run puppet without making any change to the system

    puppet agent --test --noop

  Run puppet using an environment different from the default one

    puppet agent --environment testing

  Wait for certificate approval (by default 120 seconds) in the first Puppet Run
  Useful during automated first fime installation if PuppetMaster's autosign is false

    puppet agent --test --waitforcert 120


# Other configuration files:

  **auth.conf**
    Defines ACLs to access Puppet's REST interface. [Details](http://docs.puppetlabs.com/guides/rest_auth_conf.html)

  **fileserver.conf**
    Used to manage ACL on files served from sources different than modules [Details](http://docs.puppetlabs.com/guides/file_serving.html)

  **puppetdb.conf**
    Settings for connection to PuppetDB, if used. [Details](http://docs.puppetlabs.com/puppetdb/1/)

  **tagmail.conf** , **autosign.conf** , **device.conf** , **routes.yaml**
    These are other configuration files for specific functions. [Details](http://docs.puppetlabs.com/guides/configuring.html)
