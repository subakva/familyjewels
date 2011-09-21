require 'integration_spec_helper'

describe FamilyJewels do
  before(:each) do
    pending 'This is an integration spec. It pulls, installs and builds gems into tmp/spec'
  end

  before(:each) do
    @config = build_config_for_spec
    @config.verbose = true
  end

  it "builds a project" do
    # Running this within rspec doesn't seem to work. Shell out instead.
    # project = @config.register(
    #   :clone_url      => 'git@github.com:subakva/familyjewels-test.git',
    #   :branch_name    => 'master'
    # )
    # project.build

    # TODO: Build a config, write it to a file, and run the fjb executable
    `./bin/test`

    Dir['tmp/spec/gems_dir/ruby/1.8/gems/*'].size.should == 5
    File.exists?('tmp/spec/gems_dir/ruby/1.8/gems/bundler-1.0.18').should be_true
    File.exists?('tmp/spec/gems_dir/ruby/1.8/gems/family-jewels-test-0.0.1').should be_true
    File.exists?('tmp/spec/gems_dir/ruby/1.8/gems/git-1.2.5').should be_true
    File.exists?('tmp/spec/gems_dir/ruby/1.8/gems/jeweler-1.6.4').should be_true
    File.exists?('tmp/spec/gems_dir/ruby/1.8/gems/rake-0.9.2').should be_true
  end
end
