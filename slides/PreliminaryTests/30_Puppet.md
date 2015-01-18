# Puppet

1- What is Puppet?
1) An automation framework
2) A Domain Specific Language
3) A monitoring software
4) A CMCB

2- What is Facter?
1) An orchestration framework
2) A tool always shipped with Puppet
3) A software that gathers info on the system
4) A building framework

3- What is PuppetDB?
1) A software that manages Puppet generated data
2) A NoSQL database which works well with Puppet
3) An automation framework
4) A backend for Puppet's stored configurations

4- What of the following statements is true?
1) Puppet provides a layer that abstracts the system resource
2) Puppet is a declarative language
3) Puppet is a Nagios plugin geared towards systems automation
4) Puppet is open source but has a commercial version called Puppet Enterprise

5- These are valid Puppet resource types:
1) Package
2) Service
3) Mount
4) Nagios_host

6- What does the following excerpt of Puppet code?
service { 'httpd':
  ensure => running,
  enable => true,
}
1) Installs the httpd package a start its service
2) Ensures that the httpd service is running on the system
3) Ensures that the httpd service is started at boot
4) Adds httpd to the list of services managed by systemd

7- What of the following directories are common in a Puppet module?
1) manifests
2) puppet
3) files
4) templates

8- What of the following Puppet elements can be extended by users?
1) functions
2) facts
3) types
4) providers

9- What of the following are configuration management tools?
1) Puppet
2) Chef
3) Salt
4) Sensu

10- What does the Puppet Master?
1) Compiles the catalog for Puppet clients
2) Generates facts which are passed to clients
3) Interprets our Puppet code and genrats a catalog
4) Applies our Puppet code to the system
