$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'family_jewels'
require 'rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  include FamilyJewelsSpecHelper
  # config.after(:each) do
  #   FileUtils.rm_rf('tmp/spec') if File.exists?('tmp/spec')
  # end
end
