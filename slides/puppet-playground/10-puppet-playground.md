# Puppet Playground

  * A Puppet enabled Multi VM Vagrant **environment** with different OS
    
  * The **play** command to control and populate the playground
    
  * Toasters for appliances based on **Librarian-Puppet**

  * A quick and safe place where to play and test with Puppet....

  * ... and to distribute a development environment.

  * But most of all, the Puppet Playground ....
  
  * ... is **nothing new** or special (Just a little handy thing)
  

# Installation

  Clone directly from **GitHub** to a new directory (here puppet-playground): 

    git clone https://github.com/example42/puppet-playground.git puppet-playground
    
  Move into the newly created directory (from this point all commands are relative to this path):

    cd puppet-playground

  Use Vagrant, Puppet Playground or Librarian Puppet commands:
  
    vagrant [status]

    ./play [status]
    
    librarian-puppet [show]


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

  
  The **./play forge** is just a wrapper to **puppet module**:
  
    ./play forge <command> <arguments>
    puppet module <command> <arguments> --modulepath modules/


# Use Example42 Modules

  Download the latest Example42 NextGen modules set:
 
    ./play setup example42

  This initializes the modules dir with the Example42 NextGen modules set.
  
  Directly cloned from GitHub.

  Alternatively try some Example42 toasters:
  
    ./play list
    ./play install example42-baseservices


# Use your own modules

  Just place them in the **modules/** dir.
  
  Use git (or your SCM of choice):
  
    git clone <git-source-url> modules/<module_name>


# Testing Puppet code [From your Host]

  Testing workflow is simple.
  
  Edit your manifests:
  
    vi manifests/init.pp

  Run Puppet on all the running VM or the specified one:

    vagrant provision [Centos6_64]
    ./play run [Centos6_64]

  To start all or a specific VM:

    vagrant up [Centos6_64]
    ./play up [Centos6_64]
  
  

# Testing Puppet code [From a VM]

  Connect to a running VM:

    vagrant ssh Centos6_64

  Once you've logged in the VM, get the superpowers and run Puppet:

    vm$ sudo -s
    vm# puppet apply -v --modulepath '/tmp/vagrant-puppet/modules-0' --pluginsync /tmp/vagrant-puppet/manifests/init.pp

  You can edit the manifests directly from the folder shared on your VM:

    vm# cd /tmp/vagrant-puppet/
    vm# vi manifests/init.pp


# Play with Puppi

  Puppi is a CLI tool provided with the Example42 modules.
  
  To test it, install an Example42 toaster and run some VM:
  
    ./play install example42-baseservices
    ./play up [Centos6_64]
    
  You can check if the provided modules have correctly installed your services:
        
    ./play puppi check

  Or get info on specific topics:

    ./play puppi info packages


  The play puppi command runs puppi on all the running VMs:
    
    ./play puppi <command> <arguments>
    puppi <command> <arguments> # [Executed on the VMs]


# Toasters

  Toasters provide an out of the box Playground.
  
  They are composed of:
  
  **VagrantFile** (Optional) with custom Vagrant boxes
  
  **PuppetFile** , the librarian-puppet descriptor of the modules to install
  
  **manifests/** directory with the Puppet code

  Before using toasters you must install **librarian-puppet**:
  
    gem install librarian-puppet

  Show available toasters:
  
    ./play list

  Install the specified toaster in the Playground:
  
    ./play install <toaster>


# Write your own toaster

  A toaster is just a **directory**.
  
  (Containing the manifests/ dir, a Puppetfile and eventually a VagrantFile).
  
  You can import it from a local path with:
  
    ./play import /path/to/my/acme-mailscanner/

  To share it, make a Pull Request of your directory placed in **toasters/**

  Use toasters to:
  
  - Test your Puppet modules and code [on different OS]
  
  - Distribute Appliances
  
  - Distribute development environments and application stacks
  
  - Give your developers the same setups you have in production.


# Cleaning Up the playground

  To cleanup the whole playground (Beware all your existing changes will be wiped off)

    ./play clean

 To reinstall the default Vagrantfile:

    ./play setup default
    
    
# Demo

  
# Make the Playground better

  Bugs filings, pull requests and suggestions via GitHub are **welcomed**.

  Where to contibute:
  
  - More Working vagrant Boxes for different OS. [Vagrantfile](https://github.com/example42/puppet-playground/blob/master/Vagrantfile)

  - New toasters that show how to use your modules. [toasters] directory (https://github.com/example42/puppet-playground/blob/master/toasters/)


# Future

  - More OS where to test Puppet on
  
  - Rich and useful Toasters inventory
  
  - Integration with continuous integration tools
  
  - Keeping on having fun with Puppet
  

# Questions?

  Twitter: @alvagante
  
  Github: example42
  
  SlideShare: alvagante
  
  http://www.example42.com