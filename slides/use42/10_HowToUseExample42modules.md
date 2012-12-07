# Ten Design Choices for Example42 Puppet Modules

  1 - Provide alternatives for Data Separation

  2 - Provide choice on Configuration Files supply
  
  3 - Configure everything but provide OS defaults.

  4 - Allow management of general module's behavior
  
  5 - Allow Custom Options for endless parameters

  6 - Permit easy extension with custom classes

  7 - Offer easy removal of the module's resources

  8 - Limit cross-dependencies. Prerequisites as options.

  9 - Automatically monitor and firewall resources

 10 - Puppi integration: Puppet knowledge to the CLI


# DATA SEPARATION ALTERNATIVES

  - Set (Top Scope/External Node Classifier) variables and include classes:

        $::openssh_template = 'site/openssh/openssh.conf.erb'
        include openssh

  - Use Hiera:

        hiera('openssh_template')
        include openssh

  - Use Parametrized Classes:

        class { 'openssh':
          template => 'site/openssh/openssh.conf.erb',
        }

  - Happily mix different patterns:

        $::monitor = true
        $::monitor_tool = [ 'nagios' , 'munin' , 'puppi' ]
        class { 'openssh':
          template => 'site/openssh/openssh.conf.erb',
        }


# PARAMS_LOOKUP EVERYWHERE

  - Each parameter is processed by the params_lookup function
  
        class openssh (
        [...] # openssh module specific parameters ...
          $my_class            = params_lookup( 'my_class' ),
          $source              = params_lookup( 'source' ),
          $source_dir          = params_lookup( 'source_dir' ),
          $source_dir_purge    = params_lookup( 'source_dir_purge' ),
          $template            = params_lookup( 'template' ),
          $service_autorestart = params_lookup( 'service_autorestart' , 'global' ),
          $options             = params_lookup( 'options' ),
          $version             = params_lookup( 'version' ),
          $absent              = params_lookup( 'absent' ),
          $disable             = params_lookup( 'disable' ),
          $disableboot         = params_lookup( 'disableboot' ),
          $monitor             = params_lookup( 'monitor' , 'global' ),
          $monitor_tool        = params_lookup( 'monitor_tool' , 'global' ),
          $monitor_target      = params_lookup( 'monitor_target' , 'global' ),
        [...] ) inherits openssh::params {
        [...]
        }

  - Flexibility on booleans: they are sanitized by the any2bool function
    You set:

        $absent              => "yes" # (or "1", 'Y', "true", true ...)
  
    The module internally uses:

        $bool_absent = any2bool($absent)


# PARAMS LOOKUP ORDER

  - The function params_lookup is provided by the Puppi module

  - It allows data to be defined in different ways:
  
    - Via Hiera, if available
    - As Top Scope variable (as provided by External Node Classifiers)
    - Via defaults set in the module's params class

  - The "global" argument is used to define site_wide behavior
    If there's a direct param that's the value 

        class { 'openssh': 
          monitor => true
        }

  -  Otherwise, If Hiera is available: 

        hiera("monitor")         # If global lookup is set
        hiera("openssh_monitor") # A specific value overrides the global one

  -  If variable is still not evaluated, Top Scope is looked up:

        $::monitor         # If global lookup is set
        $::openssh_monitor # If present, overrides $::monitor

  -  Module's params are used as last option defaults:

        $openssh::params::monitor


# CUSTOMIZE: CONFIGURATION FILE

  - Provide Main Configuration as a static file ...

        class { 'openssh':
          source => 'puppet:///modules/site/ssh/sshd.conf'
        }

  - ... an array of files looked up on a first match logic ...

        class { 'openssh':
          source => [ "puppet:///modules/site/ssh/sshd.conf-${fqdn}",
                      "puppet:///modules/site/ssh/openssh.conf"],
        }

  - ... or an erb template:

        class { 'openssh':
          template => 'site/ssh/sshd.conf.erb',
        }

  - Config File Path is defined in params.pp (can be overriden):

        config_file => '/etc/ssh/sshd_config',


# CUSTOMIZE: CONFIGURATION DIR

  - You can manage the whole Configuration Directory:

        class { 'openssh':
          source_dir => 'puppet:///modules/site/ssh/sshd/',
        }

  - This copies all the files in lab42/files/ssh/sshd/* to local config_dir

  - You can purge any existing file on the destination config_dir which are not present on the source_dir path:

        class { 'openssh':
          source_dir       => 'puppet:///modules/site/ssh/sshd/',
          source_dir_purge => true, # default is false
        }

    WARNING: Use with care

  - Config Dir Path is defined in params.pp (can be overriden):

        config_dir => '/etc/ssh',


# CUSTOMIZE: PATHS AND NAMES

  - Customize Application Parameters. An example:
    Use the puppet module to manage pe-puppet!

        class { 'puppet':
          template           => 'lab42/pe-puppet/puppet.conf.erb',
          package            => 'pe-puppet',
          service            => 'pe-puppet',
          service_status     => true,
          config_file        => '/etc/puppetlabs/puppet/puppet.conf',
          config_file_owner  => 'root',
          config_file_group  => 'root',
          config_file_init   => '/etc/sysconfig/pe-puppet',
          process            => 'ruby',
          process_args       => 'puppet',
          process_user       => 'root',
          config_dir         => '/etc/puppetlabs/puppet/',
          pid_file           => '/var/run/pe-puppet/agent.pid',
          log_file           => '/var/log/pe-puppet/puppet.log',
          log_dir            => '/var/log/pe-puppet',
        }


# DEFAULTS IN PARAMS.PP

  - Each module has a params class with defaults for different OS

        class openssh::params {
          ### Application related parameters
          $package = $::operatingsystem ? {
            default => 'openssh-server',
          }
          $service = $::operatingsystem ? {
            /(?i:Debian|Ubuntu|Mint)/ => 'ssh',
            default                   => 'sshd',
          }
          $process = $::operatingsystem ? {
            default => 'sshd',
          }
          [...]
          $port = '22'
          $protocol = 'tcp'
        
          # General Settings
          $my_class = ''
          $source = ''
          $source_dir = ''
          $source_dir_purge = ''
          [...]
        
          ### General module variables that can have a site or per module default
          $monitor = false
          $monitor_tool = ''
          $monitor_target = $::ipaddress
          $firewall = false
          $firewall_tool = ''
          $firewall_src = '0.0.0.0/0'
          [...]


# MANAGE BEHAVIOR

  - Enable Auditing:

        class { 'openssh':
          audit_only => true, # Default: false
        }

    No changes to configuration files are actually made and potential changes are audited

  - Manage Service Autorestart:

        class { 'openssh':
          service_autorestart => false, # Default: true
        }

    No automatic service restart when a configuration file / dir changes

  - Manage Software Version:

        class { 'foo':
          version => '1.2.0', # Default: unset
        }

    Specify the package version you want to be installed.
    Set => 'latest' to force installation of latest version 


# CUSTOM OPTIONS

  -  With templates you can provide an hash of custom options:

        class { 'openssh':
          template => 'site/ssh/sshd.conf.erb',
          options  => {
            'LogLevel' => 'INFO',
            'UsePAM'   => 'yes',
          },
        }

  - The Hash values can be used in your custom templates with the **options_lookup** function
    (Use the option value or set a default)

        UsePAM <%= scope.function_options_lookup(['UsePAM','no']) %>
        LogLevel <%= scope.function_options_lookup(['LogLevel','INFO']) %>

  - This allows management of any kind of configuration parameter:
  
    Provide endless configuration values without adding new parameters



# CUSTOMIZE: CUSTOM CLASS

  - Provide added resources in a Custom Class:

        class { 'openssh':
          my_class => 'site/my_openssh',
        }

    This autoloads: site/manifests/my_openssh.pp 

  - Custom class can stay in your site module:

        class site::my_openssh {
          file { 'motd':
            path    => '/etc/motd',
            content => template('site/openssh/motd.erb'),
          }
        }

    You hardly need to inherit openssh: there are parameters for everything
    Do not call your class site::openssh, naming collisions could happen. 


# EASY DECOMMISSIONING

  - Disable openssh service:

        class { 'openssh':
          disable => true
        }

  - Deactivate openssh service only at boot time:

        class { 'openssh':
          disableboot => true
        }

    Useful when a service is managed by another tool (ie: a cluster suite)

  - Remove openssh (package and files):

        class { 'openssh':
          absent => true
        }

  - Monitoring and firewalling resources removal is automatically managed


# CROSS-MODULE INTEGRATIONS

  - Integration with other modules sets and conflicts management is not easy.

  - Provide the option to use the module's prerequisite resources:

        class { 'logstash':
          install_prerequisites => false, # Default true
        }

    The prerequisites resources for this module are installed automatically BUT can be  managed by third-party modules

  - Play well with others: Use if ! defined when defining common resources

        if ! defined(Package['git']) {
          package { 'git': ensure => installed } 
        }

    Not a definitive solution, but better than nothing.

  - Always define in Modulefile the module's dependencies

        dependency 'example42/puppi', '>= 2.0.0'

  -  Never assume your resource defaults are set for others

        Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }


# EXTEND: MONITOR

  - Manage Abstract Automatic Monitoring:

        class { 'openssh':
          monitor      => true,
          monitor_tool => [ 'nagios','puppi','monit' ],
          monitor_target => $::ip_address # Default
        }

    Monitoring is based on these parameters defined in params.pp:

          port         => '22',
          protocol     => 'tcp',
          service      => 'ssh[d]',  # According to OS 
          process      => 'sshd', 
          process_args => '',
          process_user => 'root',
          pid_file     => '/var/run/sshd.pid',

  - Abstraction is managed in the Example42 monitor module
    Here "connectors" for different monitoring tools are defined and can be added (also using 3rd party modules).


# EXTEND: FIREWALL

  - Manage Automatic Firewalling (host based):

        class { 'openssh':
          firewall      => true,
          firewall_tool => 'iptables',
          firewall_src  => '10.0.0.0/8',
          firewall_dst  => $::ipaddress_eth1, # Default is $::ipaddress
        }

  - Firewalling is based on these parameters defined in params.pp:

          port         => '22',
          protocol     => 'tcp',


  - Abstraction is managed in the Example42 firewall module
    Currently only the "iptables" firewall_tool is defined, it uses Example42 iptables module to manage local iptables rules


# EXTEND PUPPI

  - Manage Puppi Integration:

        class { 'openssh':
          puppi        => true,       # Default: false
          puppi_helper => 'standard', # Default
        }

   - The Puppi module is a prerequisite for all Example42 modules
     Is required because it provides common libs, widely used in the modules
     BUT the actual puppi integration is optional (and disabled by default)

  -  Puppi integration allows CLI enrichment commands like:

        puppi info openssh
        puppi log openssh
        puppi check openssh

     Note: puppi support for info/log commands for NextGen modules is under development

  - Puppi helpers allow you to customize Puppi behavior 


# How to make a NextGen module

  - Get from GitHub the Next-Gen modules set:

        git clone -r http://github.com/example42/puppet-modules-nextgen
        cd puppet-modules-nextgen

  - Create a module (name will be prompted) based on the template in Example42-templates/standard42:

        Example42-tools/module_clone.sh -t standard42

  - Create a module cloned from the existing module mysql:

        Example42-tools/module_clone.sh -m mysql

  - Create a module called vim based on Example42-templates/minimal42:

        Example42-tools/module_clone.sh -t minimal42 -n vim
