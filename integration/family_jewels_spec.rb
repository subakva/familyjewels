require 'integration_spec_helper'

describe FamilyJewels do
  it "installs gems in the right place" do
    base_gems_path = 'tmp/integration/gems_dir/ruby/1.8/gems'

    Dir["#{base_gems_path}/*"].size.should == 8
    File.exists?("#{base_gems_path}/family-jewels-test-0.1.0").should be_true
    File.exists?("#{base_gems_path}/family-jewels-test-0.1.1").should be_true
    File.exists?("#{base_gems_path}/family-jewels-test-0.0.2").should be_true

    File.exists?("#{base_gems_path}/unidecode-1.0.0").should be_true
    File.exists?("#{base_gems_path}/bundler-1.0.18").should be_true
    File.exists?("#{base_gems_path}/git-1.2.5").should be_true
    File.exists?("#{base_gems_path}/jeweler-1.6.4").should be_true
    File.exists?("#{base_gems_path}/rake-0.9.2").should be_true
  end
end
