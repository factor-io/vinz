require_relative '../spec_helper'
 
describe 'Root Path' do
  describe 'GET /' do
    before { get '/' }
 
    it 'is successful' do
      last_response.status.should == 200
      last_response.body.should == 'test'
    end
  end
end
