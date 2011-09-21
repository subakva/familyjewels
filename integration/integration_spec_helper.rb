$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'family_jewels'
require 'rspec'

Dir["#{File.dirname(__FILE__)}/../spec/support/shared/**/*.rb"].each {|f| require f}
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  include FamilyJewelsSpecHelper

  # config.after(:suite) do
  #   FileUtils.rm_rf('tmp/integration') if File.exists?('tmp/spec')
  # end
end
