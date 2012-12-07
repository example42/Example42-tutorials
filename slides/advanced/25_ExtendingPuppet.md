# Extending Puppet Code with Ruby

# Developing Facts

  - Facts are generated on the client before the evaluation of the Puppet code on the server.

  - Facts provide variables that can be used in Puppet code and templates.

  - A simple custom type that just executes a shell command:

        require 'facter'
        Facter.add("last_run") do
          setcode do
            Facter::Util::Resolution.exec('date')
          end
        end

  This file should be placed in <modulename>/lib/facter/acpi_available.rb

# Developing Types

  - Resource types can be defined in Puppet language or in Ruby as plugins.

  - Ruby types require one or more **providers** whichmanage low-lovel interaction with the underlining OS to provide the more abstact resource defined in Types.
  
  - An example of a type with many providers is package, which has more than 20 providers that manage packages on different OS.

  - An example vcsrepo type (Code (C) by PuppetLabs):
  This file should be placed in vcsrepo/lib/puppet/type/vcsrepo.rb

        require 'pathname'
        
        Puppet::Type.newtype(:vcsrepo) do
          desc "A local version control repository"
        
          feature :gzip_compression,
                  "The provider supports explicit GZip compression levels"
        
          feature :bare_repositories,
                  "The provider differentiates between bare repositories
                  and those with working copies",
                  :methods => [:bare_exists?, :working_copy_exists?]
        
          feature :filesystem_types,
                  "The provider supports different filesystem types"
        
          feature :reference_tracking,
                  "The provider supports tracking revision references that can change
                   over time (eg, some VCS tags and branch names)"
          
          ensurable do
        
            newvalue :present do
              provider.create
            end
        
            newvalue :bare, :required_features => [:bare_repositories] do
              provider.create
            end
        
            newvalue :absent do
              provider.destroy
            end
        
            newvalue :latest, :required_features => [:reference_tracking] do
              if provider.exists?
                if provider.respond_to?(:update_references)
                  provider.update_references
                end
                reference = resource.value(:revision) || provider.revision
                notice "Updating to latest '#{reference}' revision"
                provider.revision = reference
              else
                provider.create
              end
            end
        
            def retrieve
              prov = @resource.provider
              if prov
                if prov.class.feature?(:bare_repositories)
                  if prov.working_copy_exists?
                    :present
                  elsif prov.bare_exists?
                    :bare
                  else
                    :absent
                  end
                else
                  prov.exists? ? :present : :absent
                end
              else
                raise Puppet::Error, "Could not find provider"
              end
            end
        
          end
        
          newparam(:path) do
            desc "Absolute path to repository"
            isnamevar
            validate do |value|
              path = Pathname.new(value)
              unless path.absolute?
                raise ArgumentError, "Path must be absolute: #{path}"
              end
            end
          end
        
          newparam(:source) do
            desc "The source URI for the repository"
          end
        
          newparam(:fstype, :required_features => [:filesystem_types]) do
            desc "Filesystem type"
          end
        
          newproperty(:revision) do
            desc "The revision of the repository"
            newvalue(/^\S+$/)
          end
        
          newparam :compression, :required_features => [:gzip_compression] do
            desc "Compression level"
            validate do |amount|
              unless Integer(amount).between?(0, 6)
                raise ArgumentError, "Unsupported compression level: #{amount} (expected 0-6)"
              end
            end
          end
        
        end

# Developing Providers

  - The vcsrepo type seen before has 5 different providers for different source control tools.

  - Here is, as an example, the git provider for the vcsrepo type (Code (C) by PuppetLabs):
  This file should be placed in vcsrepo/lib/puppet/provide/vcsrepo/git.rb

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
          
          def revision
            fetch
            update_references
            current   = at_path { git('rev-parse', 'HEAD') }
            canonical = at_path { git('rev-parse', @resource.value(:revision)) }
            if current == canonical
              @resource.value(:revision)
            else
              current
            end
          end
        
          def revision=(desired)
            fetch
            update_references
            if local_branch_revision?(desired)
              at_path do
                git('checkout', desired)
                git('pull', 'origin')
              end
              update_submodules
            elsif remote_branch_revision?(desired)
              at_path do
                git('checkout',
                    '-b', @resource.value(:revision),
                    '--track', "origin/#{@resource.value(:revision)}")
              end
              update_submodules
            else
              reset(desired)
              if @resource.value(:ensure) != :bare
                update_submodules
              end
            end
          end
        
          def bare_exists?
            bare_git_config_exists? && !working_copy_exists?
          end
        
          def working_copy_exists?
            File.directory?(File.join(@resource.value(:path), '.git'))
          end
        
          def exists?
            working_copy_exists? || bare_exists?
          end
        
          def update_references
            at_path do
              git('fetch', '--tags', 'origin')
            end
          end
          
          private
        
          def path_exists?
            File.directory?(@resource.value(:path))
          end
        
          def bare_git_config_exists?
            File.exist?(File.join(@resource.value(:path), 'config'))
          end
          
          def clone_repository(source, path)
            args = ['clone']
            if @resource.value(:ensure) == :bare
              args << '--bare'
            end
            args.push(source, path)
            git(*args)
          end
        
          def fetch
            at_path do
              git('fetch', 'origin')
            end
          end
        
          def pull
            at_path do
              git('pull', 'origin')
            end
          end
          
          def init_repository(path)
            if @resource.value(:ensure) == :bare && working_copy_exists?
              convert_working_copy_to_bare
            elsif @resource.value(:ensure) == :present && bare_exists?
              convert_bare_to_working_copy
            elsif File.directory?(@resource.value(:path))
              raise Puppet::Error, "Could not create repository (non-repository at path)"
            else
              normal_init
            end
          end
        
          # Convert working copy to bare
          #
          # Moves:
          #   /.git
          # to:
          #   /
          def convert_working_copy_to_bare
            notice "Converting working copy repository to bare repository"
            FileUtils.mv(File.join(@resource.value(:path), '.git'), tempdir)
            FileUtils.rm_rf(@resource.value(:path))
            FileUtils.mv(tempdir, @resource.value(:path))
          end
        
          # Convert bare to working copy
          #
          # Moves:
          #   /
          # to:
          #   /.git
          def convert_bare_to_working_copy
            notice "Converting bare repository to working copy repository"
            FileUtils.mv(@resource.value(:path), tempdir)
            FileUtils.mkdir(@resource.value(:path))
            FileUtils.mv(tempdir, File.join(@resource.value(:path), '.git'))
            if commits_in?(File.join(@resource.value(:path), '.git'))
              reset('HEAD')
              git('checkout', '-f')
            end
          end
        
          def normal_init
            FileUtils.mkdir(@resource.value(:path))
            args = ['init']
            if @resource.value(:ensure) == :bare
              args << '--bare'
            end
            at_path do
              git(*args)
            end
          end
        
          def commits_in?(dot_git)
            Dir.glob(File.join(dot_git, 'objects/info/*'), File::FNM_DOTMATCH) do |e|
              return true unless %w(. ..).include?(File::basename(e))
            end
            false
          end
        
          def checkout_branch_or_reset
            if remote_branch_revision?
              at_path do
                git('checkout', '-b', @resource.value(:revision), '--track', "origin/#{@resource.value(:revision)}")
              end
            else
              reset(@resource.value(:revision))
            end
          end
        
          def reset(desired)
            at_path do
              git('reset', '--hard', desired)
            end
          end
        
          def update_submodules
            at_path do
              git('submodule', 'init')
              git('submodule', 'update')
            end
          end
        
          def remote_branch_revision?(revision = @resource.value(:revision))
            at_path do
              branches.include?("origin/#{revision}")
            end
          end
        
          def local_branch_revision?(revision = @resource.value(:revision))
            at_path do
              branches.include?(revision)
            end
          end
        
          def branches
            at_path { git('branch', '-a') }.gsub('*', ' ').split(/\n/).map { |line| line.strip }
          end
        
        end
        

# Developing Functions

  - Functions are Ruby code that is executed during compilation on the Puppet Master.

  - They are used to interface with external tools, provide debugging or interpolate strings.

  - Importants parts of the Puppet language like include and template are implemented as functions.

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
