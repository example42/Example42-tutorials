
# Reporting

# PuppetDB

# Exported Resources and Stored Configs



# MCollective

  - An orchestration framework that allows massively parallel actions on the infrastructure's server

  - Based on 3 components:

    - One or more central masters, from where commands can be issued

    - The infrastructure nodes, where an agnet receieves and executes the requested actions

    - A middleware message broker, that allows communication between master(s) and agents


  - Possible actions are based on plugins
    Common plugins are: service, package, puppetd, filemgr...

  - Simple RCPs allow easy definitions of new plugins or actions