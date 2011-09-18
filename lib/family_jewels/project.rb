require 'fileutils'

# Test Notes
#  	builder_name is not a valid directory name
# 	builder_name contains a directory separator

module FamilyJewels
	class Project

		DEFAULTS = {
			:remote_name  => 'origin',
			:branch_name  => 'master',
			:install_task => 'install'
		}

		attr_accessor :clone_url, :branch_name, :project_name, :builder_name, :verbose, :remote_name, :install_task, :config

		# Create a new Project.
		#
		# * :clone_url		- The URL to use to clone the git repository
		#   :remote_name	- The name of the git remote origin [default: origin]
		#   :branch_name	- The name of the git branch to build [default: master]
		#   :project_name	- The name of the project ( eg. srbase )
		#   :builder_name	- The name for this build of the project ( eg. srbase-master )
		#   :install_task	- The name of the rake task used to install the project as a gem
		#   :verbose      - Enable verbose output
		#
		def initialize(config, attributes = nil)
			attributes ||= {}
			attributes = DEFAULTS.merge(attributes)

			raise ArgumentError.new("A configuration instance is required.") unless config
			raise ArgumentError.new(":clone_url is a required attribute.") unless attributes[:clone_url]
			raise ArgumentError.new(":branch_name is a required attribute.") unless attributes[:branch_name]

			self.config       = config
			self.verbose      = attributes[:verbose]
			self.clone_url    = attributes[:clone_url]
			self.remote_name  = attributes[:remote_name]
			self.branch_name  = attributes[:branch_name]
			self.install_task = attributes[:install_task]
			self.project_name = attributes[:project_name] || parse_project_name(clone_url)
			self.builder_name = attributes[:builder_name] || "#{self.project_name}-#{self.branch_name}"
		end

		def clone_dir
			File.join(config.stage_dir, self.builder_name)
		end

		# Returns true if the project has already been cloned
		def cloned?
			File.exists?(self.clone_dir)
		end

		# Clones the project into the staging area
		def clone!
			puts "=> Cloning into #{self.clone_dir}" if self.verbose

			run_command("git clone #{self.clone_url} #{self.clone_dir}")
			FileUtils.cd(self.clone_dir) do
				run_command("git checkout #{self.branch_name}")
			end
		end

		# Fetches the latest changes from the remote repository.
		# Returns true if the project has changed
		def fetch!
			puts "=> Fetching remote changes: #{self.remote_name}" if self.verbose

			project_changed = false
			FileUtils.cd(self.clone_dir) do
				run_command("git fetch #{self.remote_name}")
				run_command("git status") do |output|
					project_changed = (output =~ /Your branch is behind/)
				end
			end
			project_changed
		end

		# Resets the local branch to match the remote version.
		def merge_branch!
			puts "=> Resetting branch: #{self.branch_name}" if self.verbose

			FileUtils.cd(self.clone_dir) do
				run_command("git merge #{self.remote_name}/#{self.branch_name}")
			end
			false
		end

		# Returns true if the project has a file with the specified name
		def has_file?(filename)
			File.exists?(File.join(self.clone_dir, filename))
		end

		# Returns true if the project has a Gemfile
		def has_gemfile?
			has_file?('Gemfile')
		end

		# Returns true if the project has a Rakefile
		def has_rakefile?
			has_file?('Rakefile')
		end

		def has_install_task?
			return false unless self.install_task && has_rakefile?
			has_task = false
			FileUtils.cd(self.clone_dir) do
				# run_command("#{rake_bin} -T #{self.install_task}") do |output|
				run_command("bundle exec rake -T #{self.install_task}") do |output|
					has_task = (output =~ Regexp.new("rake #{self.install_task}"))
				end
			end
			has_task
		end

		def rake_bin
			"#{config.gems_dir}/ruby/1.8/bin/rake"
		end

		# Processes the project, installing gems to be indexed as required.
		def build(options = nil)
			# TODO: Extract into Builder

			puts "\n======================================================================"
			puts "=> Building: #{self.builder_name}"
			self.print_attributes if self.verbose
			puts "======================================================================\n\n"

			options ||= {}
			options = {
				:install_dependencies => true,
				:install_as_gem       => true
			}.merge(options)

			if self.cloned?
				if self.fetch!
					self.merge_branch!
				else
					puts "\n======================================================================"
					puts "=> No remote changes."
					puts "======================================================================"
					return false
				end
			else
				self.clone!
			end

			if self.has_gemfile? && options[:install_dependencies]
				puts "\n======================================================================"
				puts "=> Installing Dependencies"
				puts "======================================================================"

				FileUtils.cd(self.clone_dir) do
					# TODO: Figure out why the output from the bundle command isn't showing
					# "bundle install --path #{config.gems_dir} 2>&1" ?
					run_command("bundle install --path #{config.gems_dir}")
				end
			end

			if self.has_install_task? && options[:install_as_gem]
				puts "\n======================================================================"
				puts "=> Installing Gem"
				puts "======================================================================"

				FileUtils.cd(self.clone_dir) do
					# TODO: Make this work with other versions of Ruby
					gem_home = "#{config.gems_dir}/ruby/1.8"
					gem_path = gem_home
					rake_path = "#{gem_home}/bin/rake"

					unless File.exists?(File.join(gem_home, 'bin', 'bundle'))
						run_command("GEM_HOME=#{gem_home} GEM_PATH=#{gem_path} gem install bundler")
					end
					run_command("GEM_HOME=#{gem_home} GEM_PATH=#{gem_path} #{rake_path} install")
				end
			end

			return true
		end

		protected

		def print_attributes
			puts "=>  - verbose      : #{self.verbose}"
			puts "=>  - clone_url    : #{self.clone_url}"
			puts "=>  - remote_name  : #{self.remote_name}"
			puts "=>  - branch_name  : #{self.branch_name}"
			puts "=>  - project_name : #{self.project_name}"
			puts "=>  - builder_name : #{self.builder_name}"
			puts "=>  - install_task : #{self.install_task}"
		end

		def parse_project_name(git_url)
			git_url.match(/^.*\/(.*)\.git$/)[1]
		end

		def run_command(command, &block)
			if self.verbose
				puts "=> Running: #{command}"
				puts
			end

			output = `#{command} 2>&1`
			# output = `#{command}`
			successful = ($?.exitstatus == 0)

			if self.verbose
				puts output
				puts
				puts "=> Success?: #{successful}"
			end

			yield(output) if block_given? && successful

			# TODO: What is the best way to handle errors? Skip the failed project and move on to the next?
			unless successful
				puts "=> Cammand Failed: #{command}"
				puts "=> #{$?.inspect}"
				unless self.verbose
					puts "=> Output:"
					puts
					puts output
					puts
				end
				raise "Command Failed: #{command}"
			end
			return successful
		end
	end
end
