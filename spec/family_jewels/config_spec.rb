require 'spec_helper'

describe FamilyJewels::Config do

  context 'with the default config' do
    after(:each) do
      FileUtils.rm_rf('gems') if File.exists?('gems')
      FileUtils.rm_rf('stage') if File.exists?('stage')
    end
    
    it "creates the default directories in the working directory" do
      FamilyJewels::Config.new

      File.exists?('gems').should be_true
      File.directory?('gems').should be_true

      File.exists?('stage').should be_true
      File.directory?('stage').should be_true
    end

    it "is not verbose by default" do
      FamilyJewels::Config.new.verbose.should be_false
    end
  end

  it "creates the directories in a non-standard location" do
    FamilyJewels::Config.new(:gems_dir => 'tmp/spec/gems_dir', :stage_dir => 'tmp/spec/stage_dir')

    File.exists?('tmp/spec/gems_dir').should be_true
    File.directory?('tmp/spec/gems_dir').should be_true

    File.exists?('tmp/spec/stage_dir').should be_true
    File.directory?('tmp/spec/stage_dir').should be_true
  end

  it "creates and registers a project" do
    config = build_config_for_spec
    project = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git'
    )
    project.class.should == FamilyJewels::Project
    project.clone_url.should == 'git@github.com:subakva/familyjewels-test.git'
    project.verbose.should be_false
  end

  it "passes the config verbosity to the project" do
    config = build_config_for_spec
    config.verbose = true
    hide_stdout do
      project = config.register(
        :clone_url      => 'git@github.com:subakva/familyjewels-test.git'
      )
      project.verbose.should be_true
    end
  end

  it "can return a list of all projects" do
    config = build_config_for_spec
    project1 = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :project_name   => 'fjt'
    )
    project2 = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :branch_name    => 'experiment',
      :project_name   => 'fjt-experiment'
    )
    all_projects = config.all
    all_projects.length.should == 2
    all_projects.should include(project1)
    all_projects.should include(project2)
  end

  it "can return a filtered list of projects" do
    config = build_config_for_spec
    project1 = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :project_name   => 'fjt'
    )
    project2 = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :branch_name    => 'experiment',
      :project_name   => 'fjt-experiment'
    )
    matching_projects = config.filter do |project|
      project.project_name == 'fjt'
    end
    matching_projects.length.should == 1
    matching_projects.should include(project1)
  end

  it "can get a project by name" do
    config = build_config_for_spec
    project = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :project_name   => 'fjt'
    )

    config.get('fjt-master').should == project
  end

  it 'sets the config on the project' do
    config = build_config_for_spec

    project = config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
      :project_name   => 'fjt'
    )

    project.config.should == config
  end
end
