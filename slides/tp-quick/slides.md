# What's Tiny Puppet

- A Puppet module to manage any application

- A set of defines + application data

- Another abstraction layer

- A DSL on top of Puppet DSL?

# Tiny Puppet companions 

- The tp module
( https://github.com/example42/puppet-tp ) 

- The companion tinydata module
( https://github.com/example42/tinydata )

- The TP Vagrant Playground
( https://github.com/example42/tp-playground )


# Quick test tp in the playground

Dependencies: Vagrant, Virtual Box, r10k (optional)

    git clone git@github.com:example42/tp-playground.git
    cd tp-playground
    r10k puppetfile install

    vagrant status


# tp basic usage

TP provides defines to manage installation and configuration of applications:

    tp::install { 'nginx': }

    $nginx_options = hiera('nginx_options', {} )
    tp::conf { 'nginx':
      template => 'site/nginx/nginx.conf.erb',
      options  => $nginx_options,
    }

# tp defines

    tp::install ( tp::install4 )
    tp::conf ( tp::conf4 )
    tp::dir ( tp::dir4 )
    tp::repo
    tp::test

    tp::netinstall (WIP)
    tp::instance (WIP)

# Quick functional testing

### test define to manage a test/check script

    # To install and be able to test Apache
    tp::install { 'apache': }
    tp::test { 'apache': }


# Quick functional testing

### Test command

    # To test an application on all the VMs:
    bin/test.sh apache all

    # To test all the supported application on a specific VM:
    bin/test.sh all Centos7_P4

    # To save output of acceptance tests
    bin/test.sh apache all acceptance

# Usage cases

In local custom Puppet code. Where profiles are defined.

Can be used as alternative or complementary to component applicaction modules.

Handy when you know how to configure your application, and just need to provide a template with your data.


