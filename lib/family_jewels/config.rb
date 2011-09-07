module FamilyJewels
	class Config
		class << self
			def stage_dir(create_if_missing = true)
				dir = File.join(ENV['PWD'], 'stage')
				FileUtils.mkdir(dir) if create_if_missing && !File.exists?(dir)
				dir
			end
		end
	end
end
