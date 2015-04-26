# Resources reference - Overview

### Where to find docs about Puppet resources

### Main resources: package, service, file, user, exec

### Language Style


# Online documentation on types

#### Complete [Type Reference](http://docs.puppetlabs.com/references/latest/type.html)

This is the complete reference for Puppet types based on the latest version.

Check [here](http://docs.puppetlabs.com/references/index.html) for the reference on all the older versions.

Check the Puppet Core [Types Cheatsheet](http://docs.puppetlabs.com/puppet_core_types_cheatsheet.pdf) for an handy PDF with the essential reference.


# Inline documentation on types

#### Types reference documentation

We can check all the types documentation via the command line:

    puppet describe <type>

For a more compact output:

    puppet describe -s <type>

To show all the available resource types:

    puppet describe -l

#### Inspect existing resource types

To interactively inspect and modify our system's resources

    puppet resource <type> [name]

Remember we can use the same command to CHANGE our resources attibutes:

    puppet resource <type> <name> [attribute=value] [attribute2=value2]


# Managing packages

Installation of packages is managed by the **package** type.

The main arguments:

    package { 'apache':
      name      => 'httpd',  # (namevar)
      ensure    => 'present' # Values: 'absent', 'latest', '2.2.1'
      provider  => undef,    # Force an explicit provider
    }

# Managing services

Management of services is via the **service** type.

The main arguments:

    service { 'apache':
      name      => 'httpd',  # (namevar)
      ensure    => 'running' # Values: 'stopped', 'running'
      enable    => true,     # Define if to enable service at boot (true|false)
      hasstatus => true,     # Whether to use the init script' status to check
                             # if the service is running.
      pattern   => 'httpd',  # Name of the process to look for when hasstatus=false
    }

# Managing files

Files are the most configured resources on a system, we manage them with the **file** type:

    file { 'httpd.conf':
        # (namevar) The file path
        path      => '/etc/httpd/conf/httpd.conf',  
        # Define the file type and if it should exist:
        # 'present','absent','directory','link'
        ensure    => 'present',
        # Url from where to retrieve the file content
        source    => 'puppet://[puppetfileserver]/<share>/path',
        # Actual content of the file, alternative to source
        # Typically it contains a reference to the template function
        content   => 'My content',
        # Typical file's attributes
        owner     => 'root',
        group     => 'root',
        mode      => '0644',
        # The sylink target, when ensure => link
        target    => '/etc/httpd/httpd.conf',
        # Whether to recursively manage a directory (when ensure => directory)
        recurse   => true,
    }

# Executing commands

We can run plain commands using Puppet's **exec** type. Since Puppet applies it at every run, either the command can be safely run multiple times or we have to use one of the **creates**, **unless**, **onlyif**, **refreshonly** arguments to manage when to execute it.

    exec { 'get_my_file':
        # (namevar) The command to execute
        command   => "wget http://mysite/myfile.tar.gz -O /tmp/myfile.tar.gz',
        # The search path for the command. Must exist when command is not absolute
        # Often set in Exec resource defaults
        path      => '/sbin:/bin:/usr/sbin:/usr/bin',
        # A file created by the command. It if exists, the command is not executed
        creates   => '/tmp/myfile.tar.gz',
        # A command or an array of commands, if any of them returns an error
        # the command is not executed
        onlyif    => 'ls /tmp/myfile.tar.gz && false',
        # A command or an array of commands, if any of them returns an error
        # the command IS executed
        unless    => 'ls /tmp/myfile.tar.gz',
    }

# Managing users

Puppet has native types to manage users and groups, allowing easy addition, modification and removal. Here are the main arguments of the **user** type:

    user { 'joe':
        # (namevar) The user name
        name      => 'joe',  
        # The user's status: 'present','absent','role'
        ensure    => 'present',
        # The user's  id
        uid       => '1001',
        # The user's primary group id
        gid       => '1001',
        # Eventual user's secondary groups (use array for many)
        groups    => [ 'admins' , 'developers' ],
        # The user's password. As it appears in /etc/shadow
        # Use single quotes to avoid unanted evaluation of $* as variables
        password  => '$6$ZFS5JFFRZc$FFDSvPZSSFGVdXDlHe…',
        # Typical users' attributes
        shell     => '/bin/bash',
        home      => '/home/joe',
        mode      => '0644',
    }

# Puppet language style

Puppet language as an official [Style Guide](http://docs.puppetlabs.com/guides/style_guide.html) which defines recommended rules on how to write the code.

The standard de facto tool to check the code style is [puppet-lint](http://puppet-lint.com/).

Badly formatted example:

     file {
     "/etc/issue":
         content => "Welcome to $fqdn",
         ensure => present,
          mode => 644,
         group => "root",
         path => "${issue_file_path}",
         }

Corrected style:

    file { '/etc/issue':
      ensure  => present,
      content => "Welcome to ${fqdn}",
      mode    => 0644,
      group   => 'root',
      path    => $issue_file_path,
    }

# Resources reference - Practice

Create a manifest that contains all the explored resources: package, service, file, exec, user.

Use Pupppet Lint to verify its style.
