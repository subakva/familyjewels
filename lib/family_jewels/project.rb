require 'fileutils'

# Test Notes
#  	builder_name is not a valid directory name
# 	builder_name contains a directory separator

module FamilyJewels
	class Project

		DEFAULTS = {
			:remote_name  => 'origin',
			:branch_name  => 'master'
		}

		attr_accessor :clone_url, :branch_name, :project_name, :builder_name, :verbose, :remote_name

		# Create a new Project.
		#
		# * :clone_url 		- The URL to use to clone the git repository
		#   :remote_name  - The name of the git remote origin [default: origin]
		#   :branch_name 	- The name of the git branch to build [default: master]
		#   :project_name - The name of the project ( eg. srbase )
		#   :builder_name - The name for this build of the project ( eg. srbase-master )
		#   :verbose      - Enable verbose output
		#
		def initialize(attributes = nil)
			attributes ||= {}
			attributes = DEFAULTS.merge(attributes)

			raise ArgumentError.new(":clone_url is a required attribute.") unless attributes.has_key?(:clone_url)
			raise ArgumentError.new(":branch_name is a required attribute.") unless attributes.has_key?(:branch_name)

			self.verbose 		  = attributes[:verbose]
			self.clone_url 		= attributes[:clone_url]
			self.remote_name 	= attributes[:remote_name]
			self.branch_name 	= attributes[:branch_name]
			self.project_name = attributes[:project_name] || parse_project_name(clone_url)
			self.builder_name = attributes[:builder_name] || "#{self.project_name}-#{self.branch_name}"
		end

		def clone_dir
			File.join(Config.stage_dir, self.builder_name)
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

		# Returns true if the project has a Gemfile
		def has_gemfile?
			File.exists?(File.join(self.clone_dir, 'Gemfile'))
		end

		def has_install_task?
			false
		end

		# Processes the project, installing gems to be indexed as required.
		def build(options = nil)

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
					# "bundle install --path #{Config.gems_dir} 2>&1" ?
					run_command("bundle install --path #{Config.gems_dir}")
				end
			end

			if self.has_install_task? && options[:install_as_gem]
				puts "\n======================================================================"
				puts "=> Installing Gem"
				puts "======================================================================"

				FileUtils.cd(self.clone_dir) do
					# TODO: Change the environment so that the gem is intalled into Config.gems_dir
					run_command('rake install')
				end
			end

			return true
		end

		protected

		def print_attributes
			puts "=>  - verbose      : #{self.verbose}"
			puts "=>  - clone_url    : #{self.clone_url}"
			puts "=>  - remote_name	 : #{self.remote_name}"
			puts "=>  - branch_name	 : #{self.branch_name}"
			puts "=>  - project_name : #{self.project_name}"
			puts "=>  - builder_name : #{self.builder_name}"
		end

		def parse_project_name(git_url)
			git_url.match(/^.*\/(.*)\.git$/)[1]
		end

		def run_command(command, &block)
			if self.verbose
				puts "=> Running: #{command}"
				puts
			end

			output = `#{command}`
			successful = ($?.exitstatus == 0)

			if self.verbose
				puts
				puts "=> Success?: #{successful}"
			end

			yield(output) if block_given? && successful

			return successful
		end

		class << self
			# TODO: Move to Config
			def register(*args)
				@projects ||= []
				project = FamilyJewels::Project.new(*args)
				@projects << project
				puts " => Registered #{project.builder_name}" if project.verbose
				project
			end

			def all
				(@projects || []).dup
			end
		end
	end
end
