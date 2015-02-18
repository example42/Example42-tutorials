# Developing Puppet extensions - Overview

### Developing custom facts

### Developing custom types and provides

### Developing functions



# Developing Facts

  Facts are generated on the client before the evaluation of the Puppet code on the server.

  Facts provide variables that can be used in Puppet code and templates.

  A simple custom type that just executes a shell command:

    require 'facter'
    Facter.add("last_run") do
      setcode do
        Facter::Util::Resolution.exec('date')
      end
    end

  This file should be placed in <modulename>/lib/facter/acpi_available.rb


# Developing Types

  Resource types can be defined in Puppet language or in Ruby as plugins.

  Ruby types require one or more **providers** which manage low-lovel interaction with the underlining OS to provide the more abstact resource defined in Types.

  An example of a type with many providers is package, which has more than 20 providers that manage packages on different OS.

  A sample type structure (A type called vcsrepo, must have a path like **<module_name>/lib/puppet/type/vcsrepo.rb**

    require 'pathname'

    Puppet::Type.newtype(:vcsrepo) do
      desc "A local version control repository"

      feature :gzip_compression,
              "The provider supports explicit GZip compression levels"

      [...] List of the features

      ensurable do

        newvalue :present do
          provider.create
        end

      [...] List of the accepted values

      newparam(:source) do
        desc "The source URI for the repository"
      end

      [...] List of the accepted parameters

    end


# Developing Providers

  The vcsrepo type seen before has 5 different providers for different source control tools.

  Here is, as an example, the git provider for the vcsrepo type (Code (C) by PuppetLabs):
  This file should be placed **<module_name>/lib/puppet/provider/vcsrepo/git.rb**

    require File.join(File.dirname(__FILE__), '..', 'vcsrepo')

    Puppet::Type.type(:vcsrepo).provide(:git, :parent => Puppet::Provider::Vcsrepo) do
      desc "Supports Git repositories"

      commands :git => 'git'
      defaultfor :git => :exists
      has_features :bare_repositories, :reference_tracking

      def create
        if !@resource.value(:source)
          init_repository(@resource.value(:path))
        else
          clone_repository(@resource.value(:source), @resource.value(:path))
          if @resource.value(:revision)
            if @resource.value(:ensure) == :bare
              notice "Ignoring revision for bare repository"
            else
              checkout_branch_or_reset
            end
          end
          if @resource.value(:ensure) != :bare
            update_submodules
          end
        end
      end

      def destroy
        FileUtils.rm_rf(@resource.value(:path))
      end

      [...]

    end


# Developing Functions

  Functions are Ruby code that is executed during compilation on the Puppet Master.

  They are used to interface with external tools, provide debugging or interpolate strings.

  Importants parts of the Puppet language like include and template are implemented as functions.

    module Puppet::Parser::Functions
      newfunction(:get_magicvar, :type => :rvalue, :doc => <<-EOS
    This returns the value of the input variable. For example if you input role
    it returns the value of $role'.
        EOS
      ) do |arguments|

        raise(Puppet::ParseError, "get_magicvar(): Wrong number of arguments " +
          "given (#{arguments.size} for 1)") if arguments.size < 1

        my_var = arguments[0]
        result = lookupvar("#{my_var}")
        result = 'all' if ( result == :undefined || result == '' )
        return result
      end
    end

  This file is placed in puppi/lib/puppet/parser/functions/get_magicvar.rb.
