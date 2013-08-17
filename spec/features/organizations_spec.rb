require_relative '../spec_helper'

describe 'Organizations' do

  before do
    @super_admin = FactoryGirl.create :super_admin
  end

  describe 'when valid data is provided' do
    before do
      @org = FactoryGirl.build(:organization)
      post '/organizations', @org.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
    end

    it 'should save the org in the db' do
      last_response.status.should == 201
    end
  end

  describe 'when invalid data is provided' do
    before do
      @org = FactoryGirl.build(:organization)
      @org.name = ''
      post '/organizations', @org_.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
    end

    it 'should not save the org in the db' do
      last_response.status.should == 400
    end
  end

end
