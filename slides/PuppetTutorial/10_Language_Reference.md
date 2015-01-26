
# Resource references
When inside your Puppet code you have to reference an existing resource, you can do using this syntax:

    Type['title']

For example a resource like:

    file { 'motd':
      ensure => present,
    }
    
Is referenced with:

    File['motd']
    
Upper char is used also for subclasses/defines with :: separator:

    Apache::Virtualhost['example.com']
 

# Resource defaults
It's possible to set default argument values for a resource in order to reduce code duplication. The syntax is:

    Type {
      argument => value,
    }

Common examples:

    Exec {
      path => '/sbin:/bin:/usr/sbin:/usr/bin',
    }
    
    File {
      mode  => 0644,
      owner => 'root',
      group => 'root',
    }

Resource defaults can be overien when declaring a specific resource of the same type. 

Note that the "Area of Effect" of resource defaults might bring unexpected results. The general suggestion is:

Place **global** resource defaults in /etc/pupept/manifests/site.pp outside any node definition.

Place **local** resource defaults at the beginning of a class that uses them (mostly for clarity sake, as they are parse-order independent).

# Nodes inheritance

# Class inheritance
In Puppet classes are just containers of resources and have nothing to do with OOP classes. Therefore the meaning of class inheritance is somehow limited to few specific cases.

When using class inheritance, the main class ('puppet' in the sample below) is always evaluated first and all the variables and resource defaults it sets are available in the scope of the child class ('puppet::server').

Moreover the child class can override the arguments of a resource defined in the main class. Note the syntax used when referring to the existing resource File['/etc/puppet/puppet.conf']:

    class puppet {
      file { '/etc/puppet/puppet.conf':
        content => template('puppet/client/puppet.conf'),
      }
    }
    
    class puppet::server inherits puppet {
      File['/etc/puppet/puppet.conf'] {
        content => template('puppet/server/puppet.conf'),
      }
    }
    

# Run Stages

# Metaparameters

# Managing dependencies

# Conditionals
Puppet provides different constructs to manage conditionals inside manifests:

**Selectors** allows to set the value of a variable or an argument inside a resource declaration according to the value of another variable.
Selectors therefore just returns values and are not used to manage conditionally entire blocks of code.

**case statements** are used to execute different blocks of code according to the values of a variable. It's possible to have a default block for unmatched entries.
Case statements are NOT used inside resource declarations.

**if elsif else** conditionals, like case, are used to execute different blocks of code and can't be used inside resources declarations.
You can can use any of Puppet's comparison expressions and you can combine more than one for complex patterns matching. 

**unless** is somehow the opposite of **if**. It evaluates a boolean condition and if it's *false* it executes a block of code. It doesn't have elsif / else clauses.

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
Puppet supports some common comparison operators: ```==  !=   <  >  <=  >=  =~  !~``` and the somehow less common ```in```

     if $::osfamily == 'Debian' { [ ... ] }

     if $::kernel != 'Linux' { [ ... ] }

     if $::uptime_days > 365 { [ ... ] }
     
     if $::operatingsystemrelease <= 6 { [ ... ] }


#### in operator
The in operator checks if a string present in another string, an array or in the keys of an hash
 
     if '64' in $::architecture
 
     if $monitor_tool in [ 'nagios' , 'icinga' , 'sensu' ]

#### Expressions combinations
It's possible to combine multiple comparisons with **and** and **or** 

     if ($::osfamily == 'RedHat') and ($::operatingsystemrelease == '5') { [ ... ] }

     if (operatingsystem == 'Ubuntu') or ($::operatingsystem == 'Mint') { [ ...] }

# Exported resources

