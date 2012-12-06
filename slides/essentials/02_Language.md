# Puppet Language

  - A **Declarative** Domain Specific Language (DSL)
  - Defines **STATES** (Not procedures)
  - Puppet code stays in **manifests** (files .pp)
  - Code contains **resources** (file, package...), grouped in **classes**, organized in **modules**
  - **Nodes** (clients) include/declare classes
  - **Variables** can be Facts or User defined
  
   
# Resource Types

  - Single units of configurations
  - A Resource is composed by:
    A **type** (package, service, file, user, mount, exec ...)
    A **title** (how is called and referred)
    One or more **arguments**

        type { 'title':
          argument  => value,
          other_arg => value,
        }
        
  - Example for a **file** resource type: 
        file { 'motd':
          ensure  => present,
          path    => '/etc/motd',
          content => 'Tomorrow is another day',
        }
        
  - Complete [Type Reference](http://docs.puppetlabs.com/references/3.0.0/type.html)

# Simple SampleS of ReSourceS
 
        package { 'openssh':
          ensure => present,
        }

        file { 'motd':
          path => '/etc/moth',
        }

        service { 'httpd':
          ensure => running,
          enable => true,
        }

# Some More Complex examples of resources

        package { 'apache':
          ensure => present,
          name   => $operatingsystem {
            /(?i:Ubuntu|Debian|Mint)/ => 'apache2',
            default                   => 'httpd',
          }
        }
      
        service { 'nginx':
          ensure     => $nginx::manage_service_ensure,
          name       => $nginx::service,
          enable     => $nginx::manage_service_enable,
          hasstatus  => $nginx::service_status,
          pattern    => $nginx::process,
          require    => Package['nginx'],
        }
      
        file { 'nginx.conf':
          ensure  => present,
          path    => '/etc/nginx/nginx.conf',
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          require => Package['nginx'],
          notify  => Service['nginx'],
          source  => [ "puppet:///modules/site/nginx/nginx.conf--${fqdn}",
                       "puppet:///modules/site/nginx/nginx.conf-${role}",
                       "puppet:///modules/site/nginx/nginx.conf" ],
          }
        }
                
# Classes

  - Normal 'old style' classes.
  - Usage:
  
        include mysql

  - Example of a class **definition**:
          
        class mysql {     
             
          package { 'mysql-server':     
            ensure => present,     
          }     
        
          service { 'mysql':     
            ensure    => running,     
            enable    => true,     
            require   => Package['mysql-server'],     
            subscribe => File['my.cnf'],     
           }     
        
         [...]   

        }

# Parametrized Classes

  - Classes that expose parameters (Since Puppet 2.6).
  
  - Usage (class **declaration**) with parameters:
  
        class { 'mysql':
          ensure => absent,
        }
        
  -  **Definition** of a parametrized class: 

        class mysql (
          ensure => 'present' 
          ) {     

        package { 'mysql': }
            ensure => $ensure,     
          }     

          [...]
        }

# Defines 

  - Similar to parametrized classes but can be used multi times, with different parameters
  Also called: **Defined resource types** or **defined types**
  
  - Usage example (**declaration**):
  
        apache::virtualhost { 'www.example42.com':
          template => 'site/apache/www.example42.com-erb'
        }

  - **Definition** example: 
  
        define apache::virtualhost (
          $template   = 'apache/virtualhost.conf.erb' ,
          [...]
          ensure => 'present' ) {
        
          file { "ApacheVirtualHost_${name}":
            ensure  => $ensure,
            content => template("${template}"),
          }

        }

# Variables
  You need them...
  
  - Can be provided by client nodes as **facts**
    **Facter** runs on clients and collects **facts** that the server can use as variables
  
        al$ **facter**
 
        architecture => x86_64
        fqdn => Macante.example42.com
        hostname => Macante
        interfaces => lo0,eth0
        ipaddress => 10.42.42.98
        ipaddress_eth0 => 10.42.42.98
        kernel => Linux
        macaddress => 20:c9:d0:44:61:57
        macaddress_eth0 => 20:c9:d0:44:61:57
        memorytotal => 16.00 GB
        netmask => 255.255.255.0
        operatingsystem => Centos
        operatingsystemrelease => 6.3
        osfamily => RedHat
        virtual => physical
 
  - Or can be defined by users
  
  
# User Variables

  - You can define custom variables in different ways:
  
  - In Puppet manifests:

        $role = 'mail'
        
        $package = $operatingsystem ? {
          /(?i:Ubuntu|Debian|Mint)/ => 'apache2',
          default                   => 'httpd',
        }
        
  - In an External Node Classifier (Puppet DashBoard, the Foreman, Puppet Enterprise)
  
  - Or retrieved from an Hiera backend
  
        $syslog_server = hiera(syslog_server)
        
# Nodes

  - A node is defined by hostname or certname
  
  -  When a client connects a PuppetMaster builds the catalog for its hostname or certname
  
  - The client