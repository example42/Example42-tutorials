# Resource references
In Puppet any resource is uniquely identified by its type and its name.
You can't have 2 resources of the same type with the same name in a catalog.

We have seen that you declare resources with a syntax like:

    type { 'name':
      arguments => values,
    }

When you need to reference to them in your code the syntax is like:

    Type['name']
    
Some examples:

    file { 'motd': ... }
    apache::virtualhost { 'example42.com': .... }
    exec { 'download_myapp': .... }

are referenced, respectively, with

    File['motd']
    Apache::Virtualhost['example42.com']
    Exec['download_myapp']

# Nodes inheritance

# Class inheritance


# Run Stages

# Metaparameters

# Managing dependencies

# Conditionals


# Sample: Assign a variable value

#### Selector for variable's assignement 

     $package_name = $osfamily ? {
       'RedHat' => 'httpd',
       'Debian' => 'apache2',
       default  => undef,
     }

#### case

     case $::osfamily {
       'Debian': { $package_name = 'apache2' }
       'RedHat': { $package_name = 'httpd' }
       default: { notify { "Operating system $::operatingsystem not supported" } } 
     }
          
#### if elsif else

     if $::osfamily == 'Debian' {       $package_name = 'apache2'
     } elsif $::osfamily == 'RedHat' {       $package_name = 'httpd'
     } else {       notify { "Operating system $::operatingsystem not supported" }     }

# Comparing strings

#### Comparison operators

     if $::osfamily == 'Debian' { […] }

     if $::kernel != 'Linux' { […] }

     if $::uptime_days > 365 { […] }
     
     if $::operatingsystemrelease <= 6 { […] }

#### Expressions combination

     if ($::osfamily == 'RedHat') and ($::operatingsystemrelease == '5') { […] }

     if (operatingsystem == 'Ubuntu') or ($::operatingsystem == 'Mint') { […] }


#### in operator


# Exported resources

