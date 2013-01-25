# Puppet Playground

  where is easy to learn and test Puppet code
  
  You need:
  
  **VirtualBox** and **Vagrant** with **Puppet**  integration
  
  You have:
  
  A multi OS default playground P (Default Vagrantile provides multiple OS with Puppet apply integration)
    
    the **play** command to control and populate the playground
    
    Appliances toasters based on **Librarian-Puppet**


# Installation

Clone directly from GitHub to a new directory (here puppet-playground): 

    git clone https://github.com/example42/puppet-playground.git puppet-playground
    
Move into the newly created directory, from this point all commands are relative to this path:

    cd puppet-playground

What you have is a normal Vagrant multi VM environment:

    vagrant status

# Play with Puppet

Once you see that Vagrant is doing its job, you can start to play with Puppet code: edit the default Puppet manifest applied on the boxes:

    vi manifests/init.pp

This is your test playground: add resources, use modules, declare classes…
You can place simple resources like:

    file { 'motd':
      path    => '/etc/motd',
      content => 'Hi there',
    }

Or use modules you’ve previously placed in the modules/ dir.

    class { 'wordpress':
    }


# Install modules from Puppet Forge

  List the current module list

    ./play forge list
    
  Search for modules on Puppet Forge
  
    ./play forge search apt

  Install a module from the Forge:

    ./play forge install puppetlabs-apache

  which is a short cut for:

    puppet module install puppetlabs-apache  --modulepath modules/


# Use example42

  Play with a NextGen Example42 modules environment:
 
    ./play setup example42

   This initializes the modules dir with the Example42 NextGen modules, directly cloned from GitHub.


# Toasters

    gem install librarian-puppet

    ./play list

    ./play install <toaster>
  
  

Or whatever Puppet code you might want to apply.

If you need to provide custom files, the sanest approach is to place them in the templates directory of a custom “site” module (call it ‘site’ or however you want) and refer to it using the content parameter:

    file { 'motd':
      path    => '/etc/motd',
      content => template('site/motd'),
    }

This will populate /etc/motd with the template placed in **puppet-playground/modules/site/templates/motd**.


# Testing methods

To test your code’s changes on a single node, you have two alternatives:

From your host, in the puppet-playground directory:

    vagrant provision Test_Centos6_64

From the VM you have created:

    vagrant ssh Test_Centos6_64

Once you’ve logged in the VM, get the superpowers and run Puppet:

    vm# sudo -s
    vm# puppet apply -v --modulepath '/tmp/vagrant-puppet/modules-0' --pluginsync /tmp/vagrant-puppet/manifests/init.pp

You can also edit the manifests file both from your host or inside a VM:

From your host (having your cwd in puppet-playground directory):

    vi manifests/init.pp

From the VM (once connected via ssh):

    vm# sudo -s
    vm# cd /tmp/vagrant-puppet/
    vm# vi manifests/init.pp

If you have more VMs active you can test your changes on all of them with a simple:

    vagrant provision


# The play command

  It manages the Puppet Playground:

  the **Vagrantfile**,
  the **Puppetfile** for librarian-puppet
  the content of the **manifests/**
  and of **modules/** directories.

To show the status of the playground

    ./play status

To show the available toasters for ./play install:

    ./play list

To install a toaster: :

    ./play install example42-tomcat

To run the current playground (same as vagrant provision)

    ./play run


# Cleaning Up the playground

To cleanup the whole playground (Beware all the existing changes will be wiped off)

    ./play clean



To run puppi commands on all the active boxes (note: Puppi must included in the playground)

    ./play puppi check
    ./play puppi info packages

Basically **./play puppi $*** does a **puppi $*** on all the running VMs


To reinstall the default Vagrantfile (might be overrided by toasters imported or installed, if they provide it):

    ./play setup default

To wipe off and inizialize the modules/ directory with NextGen Example42 modules

    ./play setup example42


# Write you own toaster

A toaster is just a **directory** that contains these files:

 1 - The **manifests** directory with the Puppet code that is needed for your appliance setup.
 By default the provided Vagrantfile uses manifests/init.pp as main manifest, but you can use a different name, al long as it's coherent with your Vagrantfile's puppet.manifest_file (if possibile keep init.pp, for easier cross testing with different Vagrant environments)

    manifests/

 2 - A [Librarian Puppet](http://librarian-puppet.com/) formatted **Puppetfile**

    Puppetfile

 3 - An **optional** custom **Vagrantfile** (with tested VMs and custom settings)

    Vagrantfile

To import your toaster in the Playground just type

    ./play import /path/to/my/acme-mailscanner/

But if you think that it can be useful to others, please add it to the [toasters directory](https://github.com/example42/puppet-playground/blob/master/toasters/) and make a pull request: your toaster will be available to everybody out of the box with a simple:

    ./play install acme-mailscanner


# Example42 integrations

The Puppet Playground has started as a Vagrant environment where to test [Example42](http://www.example42.com) modules, as you can see, you can actually use it to test whatever kind of Puppet code and modules. Still the are some "extras" that you can have, when using Example42 modules.

As seen, you can populate the modules dir with the [Example42 NextGen](https://github.com/example42/puppet-modules-nextgen) modules with

    ./play setup example42

You can also test a more restricted set of modules with the provided Example42 toasters

    ./play install example42-jboss

And you can play with puppi and automatic monitoring if you use Example42 modules or toasters.

In the manifest/init.pp be sure to have these topscope variables (you can pass the same values as class parameters):

    $puppi        = true
    $monitor      = true
    $monitor_tool = [ 'puppi' ]

Note that on RedHat and derivatives you also need the EPEL repository installed.
You can provided it with Example42's yum module:

    include yum

Once you've run puppet on the active boxes you can do interesting things with puppi, like verifying if the services provided by Puppet are actually up and running:

    ./play puppi check

or, deploy a custom application (configured with puppi in your manifests/init.pp) on all the running Vagrant boxes:

    ./play puppi deploy my_app

or view from them realtime infos like:

    ./play puppi info network



# Modules directory

The cohexistence of different ways to manage the modules directory (with puppet module tool, with the Example42 NextGen git repo, with custom modules r via librarian-puppet) may create inconsistent status, if you mix these methods.

Start from an empty modules dir to have a clean setup good for every use.


# Vagrantfile

Currently a default Vagrantfile is provided but can be overrided by a different one provided by a toaster.

The idea is to keep the default one multi-purpose, multi-os and well tested and leave the option to provide alternative Vagrantfiles via toasters.

If you install or import a toaster that provides a custom Vagrantfile your running VMs will "disappear" from the playground and the new one(s) of the toaster will show up.

Note that the active "old" VMs are still running and you can manage them via vagrant only reinstallling the relevant Vagrantfile on the Playground.

To reinstall on the Playground the default Vagrantfile (note that this command does not change the content of modules/ Puppetfile and manifests/):

    ./play setup default
 
To (re)install on the Playground a Vagrantfile from a toaster (this will override also the Puppet configurations)

    ./play install toaster_name


# Support and Bugs

Please submit bug filings, pull requests and suggestions via GitHub.

This Puppet Playground might become more and more useful if:

  - More Working vagrant Boxes are provided for different OS. You can add them to [Vagrantfile](https://github.com/example42/puppet-playground/blob/master/Vagrantfile)

  - New toasters are provided that use different modules sets with librarian-puppet. Added them to [toasters] directory (https://github.com/example42/puppet-playground/blob/master/toasters/)

  - New ideas and integrations are delivered (ie: Travis, Jenkins for automatic checks of deployed toasters)

Any contribution is very welcomed: the Playground is funnier if there are more kids around ;-)
