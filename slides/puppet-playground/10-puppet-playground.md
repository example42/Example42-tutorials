# Puppet Playground

  where is easy to learn and test Puppet code
  
  You need:
  
  **VirtualBox** and **Vagrant** with **Puppet**  integration
  
  You have:
  
  A multi OS default playground (Default Vagrantile provides multiple OS with Puppet apply integration)
    
  The **play** command to control and populate the playground
    
  Appliances toasters based on **Librarian-Puppet**


# Installation

  Clone directly from GitHub to a new directory (here puppet-playground): 

    git clone https://github.com/example42/puppet-playground.git puppet-playground
    
  Move into the newly created directory, from this point all commands are relative to this path:

    cd puppet-playground

  What you have is a normal Vagrant multi VM environment (on steroids):

    vagrant status


# Play in the Puppet Playground

  Play with Puppet code in the **manifests** directory:

    vi manifests/init.pp

  Use modules in the **modules** directory:

    ls -l modules/

  View the **VagrantFile**

    cat VagrantFile

  
  Show the status of the playground

    ./play status



# Install modules from Puppet Forge

  List the current modules

    ./play forge list
    
  Search for modules on Puppet Forge
  
    ./play forge search apt

  Install a module from the Forge:

    ./play forge install puppetlabs-apache

  
  The play forge is just a wrapper to puppet module
  
    ./play forge <command> <arguments>
    
  just runs:

    puppet module <command> <arguments> --modulepath modules/


# Use Example42 Modules

  Download the latest Example42 NextGen modules set:
 
    ./play setup example42

  This initializes the modules dir with the Example42 NextGen modules, directly cloned from GitHub.


# Use your own modules

  Just place them in the **modules/** dir.
  
  Use git (or your SCM of choice):
  
    git clone <git-source-url> modules/<module_name>


# Toasters

  Toasters provide an out of the box Playground.
  
  They are composed of:
  
  **VagrantFile** (Optional) with custom Vagrant boxes
  
  **PuppetFile** , the librarian-puppet descriptor of the modules to install
  
  **manifests/** directory with the Puppet code

  Before using toasters you must install librarian-puppet:
  
    gem install librarian-puppet

  Show available toasters:
  
    ./play list

  Install the specified toaster in the Playground:
  
    ./play install <toaster>


# Testing Puppet code

  You can run Puppet on the active VMs in 2 ways:

  From your host:

    vagrant provision [vm]
    ./play run [vm]

  From the VM you have created:

    vagrant ssh Centos6_64

  Once you’ve logged in the VM, get the superpowers and run Puppet:

    vm$ sudo -s
    vm# puppet apply -v --modulepath '/tmp/vagrant-puppet/modules-0' --pluginsync /tmp/vagrant-puppet/manifests/init.pp

  You can also edit the manifests file both from your host or inside a VM:

  From your host:

    vi manifests/init.pp

  From the VM (once connected via ssh):

    vm$ sudo -s
    vm# cd /tmp/vagrant-puppet/
    vm# vi manifests/init.pp


# Cleaning Up the playground

  To cleanup the whole playground (Beware all the existing changes will be wiped off)

    ./play clean

 To reinstall the default Vagrantfile:

    ./play setup default


To run puppi commands on all the active boxes (note: Puppi must included in the playground)

    ./play puppi check
    ./play puppi info packages

Basically **./play puppi $*** does a **puppi $*** on all the running VMs


# Write you own toaster

  A toaster is just a **directory** that contains these files:

  * The **manifests** directory with the Puppet code that is needed for your appliance setup.

  * A [Librarian Puppet](http://librarian-puppet.com/) formatted **Puppetfile**

  * An **optional** custom **Vagrantfile** (with tested VMs and custom settings)

  To import your toaster in the Playground just type

    ./play import /path/to/my/acme-mailscanner/


# Example42 integrations

  As seen, you can populate the modules dir with the [Example42 NextGen](https://github.com/example42/puppet-modules-nextgen) modules with

    ./play setup example42

  You can also test a more restricted set of modules with the provided Example42 toasters

    ./play install example42-jboss

  And you can play with puppi and automatic monitoring if you use Example42 modules or toasters.

  In the manifest/init.pp be sure to have these topscope variables:

    $puppi        = true
    $monitor      = true
    $monitor_tool = [ 'puppi' ]

  Check if modules have been correctly installed on all the running boxes:
  
    ./play puppi check

  Deploy a custom application:

    ./play puppi deploy my_app

  View real time info about the system:

    ./play puppi info [topic]


# Demo


# Make the Playground better

  Bugs filings, pull requests and suggestions via GitHub are **welcomed**.

  Where to contibute:
  
  - More Working vagrant Boxes for different OS. [Vagrantfile](https://github.com/example42/puppet-playground/blob/master/Vagrantfile)

  - New toasters that show how to use your modules. [toasters] directory (https://github.com/example42/puppet-playground/blob/master/toasters/)
