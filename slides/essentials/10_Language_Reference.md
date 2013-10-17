# Resource references

# Nodes and class inheritance

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

