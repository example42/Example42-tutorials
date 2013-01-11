# Optimize code for performance

  Reduce the number of resources per node
  For each resource Puppet has to serialize, deserialize, apply, report...
  Avoid use of resources for too many entities (Do manage hundreds of users with the User type)
  Limit overhead of containing classes
  (A module with the openssh::package, openssh::service, openssh::configuration subclasses pattern is uselessly filled with extra resources)

  Do not use the file type to deliver too large files or binaries:
  For each file Puppet has to make a checksum to verify if it has changed
  With source => , the content of the file is retrieved with a new connection to the PuppetMaster
  With content => template() , the content is placed inside the catalog.
  Avoid too many elements in a source array for file retrieval:

    source => [ "site/openssh/sshd.conf---$::hostname ,
                "site/openssh/sshd.conf--$environemnt-$role ,
                "site/openssh/sshd.conf-$role ,
                "site/openssh/sshd.conf ],

  This checks 3 files (and eventually gets 3 404 errors from server) before getting the default ones.


# Reduce PuppetMaster(s) load

  Run Puppet less frequently (default 30 mins)

  Evaluate centrally managed, on-demand, Puppet Runs (ie: via MCollective)

  Evaluate Master-less setups

  Use a [setup with Passenger](http://docs.puppetlabs.com/guides/passenger.html) to have multiple PuppetMasters childs on different CPUs

  Disable Store Configs if you don't use them

    storeconfigs = false

  Alternatively enable Thin Store Configs and Mysql backend

    storeconfigs = true
    thin_storeconfigs = true
    dbadapter = mysql
    dbname = puppet
    dbserver = mysql.example42.com
    dbuser = puppet
    dbpassword = <%= scope.lookupvar('secret::puppet_db_password') %>

  Evaluate PuppetDB as backend (faster)

    storeconfigs = true
    storeconfigs_backend = puppetdb
