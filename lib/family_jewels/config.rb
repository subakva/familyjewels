require 'fileutils'

module FamilyJewels
	class Config
		attr_accessor :gems_dir, :stage_dir, :verbose

		def initialize(options = nil)
			options ||= {}

			self.gems_dir 	= initialize_working_dir(options[:gems_dir], 'gems')
			self.stage_dir 	= initialize_working_dir(options[:stage_dir], 'stage')
			self.verbose    = options[:verbose].nil? ? false : options[:verbose]
		end

		def register(project_attributes)
			project_attributes ||= {}
			project_attributes[:verbose] = self.verbose if project_attributes[:verbose].nil?

			project = FamilyJewels::Project.new(self, project_attributes)

			@projects ||= {}
			@projects[project.project_name] = project
			puts " => Registered #{project.builder_name}" if self.verbose
			project
		end

		def get(project_name)
			@projects ||= {}
			@projects[project_name]
		end

		def filter(&block)
			@projects.values.select(&block)
		end

		def all
			@projects ||= {}
			@projects.values
		end

		protected

		def initialize_working_dir(provided_name, default_name)
			dir_name = provided_name || File.join(ENV['PWD'], default_name)
			FileUtils.mkdir_p(dir_name) if !File.exists?(dir_name)
			dir_name
		end
	end
end
