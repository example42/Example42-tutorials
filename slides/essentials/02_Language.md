# Puppet Language

  - A **Declarative** Domain Specific Language (DSL)

  - Defines **STATES** (Not procedures)

  - Puppet code stays in **manifests** (files .pp)

  - Code contains **resources** that affects elements of the systme (file, package, service ...)

  - Resources are often grouped in **classes** which are generally organized in **modules**

  - **Nodes** (clients) include/declare resources or classes

  - **Variables** may be defined nodes and can be Facts (generated from the node) or User defined
  
   
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
 
  - Installation of OpenSSH package
  
        package { 'openssh':
          ensure => present,
        }

  - Creation of /etc/motd file
  
        file { 'motd':
          path => '/etc/moth',
        }

  - Start of httpd service
  
        service { 'httpd':
          ensure => running,
          enable => true,
        }


# More Complex examples of resources

  - Installation of Apache package with the correct name for different OS
 
        package { 'apache':
          ensure => present,
          name   => $operatingsystem {
            /(?i:Ubuntu|Debian|Mint)/ => 'apache2',
            default                   => 'httpd',
          }
        }
 
  - Management of nginx service with parameters defined in module's variables
  
        service { 'nginx':
          ensure     => $nginx::manage_service_ensure,
          name       => $nginx::service,
          enable     => $nginx::manage_service_enable,
          hasstatus  => $nginx::service_status,
          pattern    => $nginx::process,
          require    => Package['nginx'],
        }
      
  - Creation of /etc/nginx/nginx.conf with content retrived from different possible sources (first found is provided)

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

  - Classes are containers of different resources

  - Since Puppet 2.6 classes can have parameters
  
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

  - Usage of "old style" classes (without parameters):

    You can include the same class multiple times: it's applied only once.
      
        include mysql


# Parametrized Classes

  - Classes that expose parameters (Since Puppet 2.6).

  -  **Definition** of a parametrized class: 

        class mysql (
          ensure => 'present' 
          ) {     

        package { 'mysql': }
            ensure => $ensure,     
          }     

          [...]
        }
  
  - Usage (class **declaration**) with parameters:
  
        class { 'mysql':
          ensure => absent,
        }

  - You can declare a parametrized class only once.
  

# Defines 

  - Also called: **Defined resource types** or **defined types**

  - Similar to parametrized classes but can be used multi times, with different parameters
  
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

  - Usage example (**declaration**):
  
        apache::virtualhost { 'www.example42.com':
          template => 'site/apache/www.example42.com-erb'
        }



# Variables

  - You need them to provide different configurations for different kind of servers
  
  - Can be provided by client nodes as **facts**
  
    **Facter** runs on clients and collects **facts** that the server can use as variables
  
        al$ facter
 
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
  
  - In an Hiera backend
  
        $syslog_server = hiera(syslog_server)

        
# Nodes

  - A node is identified by the PuppetMaster by its **hostname** or **certname**
  
  - You can decide what resources, classes and variables to assign to a node in 2 ways:
  
    - Using Puppet language ( Starting from /etc/manifests/site.pp )  
    
        node 'web01' {
          include apache
        }
      
    - Using an External Node Classifier (DashBoard, Foreman or custom scripts)
  
  - When a client connects a PuppetMaster builds a **catalog** with all the resources to apply on the client

