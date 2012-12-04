# Modules

  - Self Contained and Distributable *recipes* for specific software or tasks
  
  - Used to manage with Puppet an application, system's resources, a local site or more complex structures
  
  - Modules must be placed in the Puppet Master modulepath
    
        puppet config print modulepath
        /etc/puppet/modules:/usr/share/puppet/modules
 
 
  - Puppet module tool to interface with Puppet Modules Forge
  
  
# How to Use

  - Mysql class is defined in $MODULE_PATH/mysql/manifests/init.pp

        class mysql (
          $required_param ,
          $optional_param = 'default' ,
          $lastparam      = 'default' 
          ) {

        # Comment
        # Here puppet code
        
          package { 'mysql': [...] }
 
          service { 'mysql': [...] }
        
          [...] Othet Puppet code to manage Mysql
        
        }
        
  - Once defined, a class can be included or declared        

        include mysql
        
        class { 'mysql':
          required_param  => 'my_value',
          $optional_parma => 'dont_like_defaults',
        }
        
   
# Paths of a module

        mysql/                     # Main module directory

        mysql/manifests/           # Manifests directory. Puppet Code here
        mysql/manifests/init.pp    # Main mysql class 
        mysql/manifests/module.pp  # A sample define: mysql::module

        mysql/lib/                 # Plugins directory. (Ruby code here) 
        
        mysql/templates/           # ERB Templates directory 
        
        mysql/files/               # Static files directory 

        mysql/spec/                # Puppet-rspec test 

        mysql/Modulefile           # Module's metadata descriptor


# Naming conventions





# Parametrized classes

# Erb templates

# Create a Good Module


