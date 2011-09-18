require 'spec_helper'

describe FamilyJewels::Project do
  before(:each) do
    @config = build_config_for_spec
  end

  it "requires a config" do
    lambda {
      FamilyJewels::Project.new(nil)
    }.should raise_error(ArgumentError, "A configuration instance is required.")
  end
  it "requires a clone_url" do
    lambda {
      FamilyJewels::Project.new(@config)
    }.should raise_error(ArgumentError, ":clone_url is a required attribute.")
  end

  it "requires a branch_name" do
    lambda {
      FamilyJewels::Project.new(@config, :clone_url => 'git@github.com:subakva/familyjewels-test.git', :branch_name => nil)
    }.should raise_error(ArgumentError, ":branch_name is a required attribute.")
  end

  it "provides sensible defaults" do
    project = FamilyJewels::Project.new(@config, :clone_url => 'git@github.com:subakva/familyjewels-test.git')
    
    project.verbose.should be_false
    project.clone_url.should == 'git@github.com:subakva/familyjewels-test.git'
    project.remote_name.should == 'origin'
    project.branch_name.should == 'master'
    project.install_task.should == 'install'
    project.project_name.should == 'familyjewels-test'
    project.builder_name.should == 'familyjewels-test-master'
    project.config.should == @config
  end

  it "should expose the clone_dir built from the config" do
    project = FamilyJewels::Project.new(@config, :clone_url => 'git@github.com:subakva/familyjewels-test.git')
    project.clone_dir.should == File.join(ENV['PWD'], 'tmp/spec/stage_dir/familyjewels-test-master')
  end
end
