ENV['RACK_ENV'] = 'test'

require 'debugger'

require_relative File.join('..', 'app')

RSpec.configure do |config|
  include Rack::Test::Methods
 
  FactoryGirl.find_definitions

  def app
    VinzAPI
  end
end
