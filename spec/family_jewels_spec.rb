require 'spec_helper'

describe FamilyJewels do
  before(:each) do
    pending 'This is an integration spec. It pulls, installs and builds gems into tmp/spec'
  end

  before(:each) do
    @config = build_config_for_spec
    @config.verbose = true
  end

  it "builds a project" do
    project = @config.register(
      :clone_url      => 'git@github.com:subakva/familyjewels-test.git'
    )
    project.build
  end
end
