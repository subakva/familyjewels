desc "Installs and builds all configured gems"
task :update do
  require 'yaml'
  raise RuntimeError.new('') unless File.exists?('config/jewels.yml')
  config = YAML.load(File.read('config/jewels.yml'))

  gems_to_install = config['gems_to_install']
  gems_to_install.each do |gem_command|
    # TODO: check that the gem is not already installed
    system("bin/install_gem #{gem_command}")
  end

  gems_to_build = config['gems_to_build']
  gems_to_build.each do |name, builder_config|
    puts "\n----------\nBuilding #{name}\n----------\n\n"
    
    repo    = builder_config['repo']
    branch  = builder_config['branch']
    branch ||= 'master'
    raise ArgumentError.new("Missing repo argument for #{name}") unless repo

    system("bin/build_gem #{builder_config['repo']} #{name} #{branch}")
    break
  end
end

desc "Destroy all gems!"
task :destroy do
  require 'fileutils'
  FileUtils.rm_rf('gems')
  FileUtils.rm_rf('builder')
end