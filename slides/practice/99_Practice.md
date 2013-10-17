# Practice: Puppet Installation

1.  Install Puppet on a test system and review the content of the configuration files, the files provided by the puppet packegage and the vardir

2.  Install Puppet Server on a test system and review the installed files


# Answers: Puppet Installation

1.  Install Puppet on a test system and review the content of the configuration files, the files provided by the puppet package and the vardir (commands for RedHat 6 based systems)

        rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm # For Epel repo 
        
        rpm -Uvh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch # For PuppetLabs repo
    
        yum install puppet
    
        ls -l /etc/puppet
        
        rpm -ql puppet
        
        find /var/lib/puppet

2.  Install Puppet Server on a test system and review the installed files

        yum install puppet-server

        rpm -ql puppet-server