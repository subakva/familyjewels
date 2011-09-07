require 'fileutils'

# Test Notes
#  	builder_name is not a valid directory name
# 	builder_name contains a directory separator

module FamilyJewels
	class Project

		DEFAULTS = {
			:branch_name  => 'master'
		}

		attr_accessor :clone_url, :branch_name, :project_name, :builder_name, :verbose

		# Create a new Project.
		#
		# * :clone_url 		- The URL to use to clone the git repository
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
			self.branch_name 	= attributes[:branch_name]
			self.project_name = attributes[:project_name] || parse_project_name(clone_url)
			self.builder_name = attributes[:builder_name] || "#{self.project_name}-#{self.branch_name}"

			if self.verbose
				puts
				puts "Created Project:"
				puts " - verbose      : #{self.verbose}"
				puts " - clone_url    : #{self.clone_url}"
				puts " - branch_name	: #{self.branch_name}"
				puts " - project_name : #{self.project_name}"
				puts " - builder_name : #{self.builder_name}"
				puts
			end
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
			run_command("git clone #{self.clone_url} #{clone_dir}")
		end

		# Fetches the latest changes from the remote repository.
		# Returns true if the project has changed
		def fetch!
			false
		end

		# Resets the local branch to match the remote version.
		def reset_branch!
			false
		end

		# Returns true if the project has a Gemfile
		def has_gemfile?
			false
		end

		def has_install_task?
			false
		end

		# Processes the project, installing gems to be indexed as required.
		def build(options = nil)
			options ||= {}
			options = {
				:install_dependencies => true,
				:install_as_gem       => true
			}.merge(options)

			if self.cloned?
				if self.fetch!
					self.reset_branch!
				else
					# No remote changes.
					return false
				end
			else
				self.clone!
			end

			run_command('bundle install') if self.has_gemfile? && option[:install_dependencies]
			run_command('rake install') 	if self.has_install_task? && option[:install_as_gem]

			return true
		end

		protected

		def run_command(command)
			puts " => Running: #{command}" if self.verbose
			`#{command}`
			successful = ($?.exitstatus == 0)
			puts " => Success?: #{successful}" if self.verbose
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
