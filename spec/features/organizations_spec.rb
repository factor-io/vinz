require_relative '../spec_helper'

describe 'Organizations' do

  before do
    @super_admin = FactoryGirl.create :super_admin
  end

  describe 'GET /organizations' do
    before do
      @orgs = Organization.all
      get '/organizations', nil, {'HTTP_X_AUTH_TOKEN' => @super_admin.api_key}
    end

    it 'should return all organizations' do
      last_response.status.should == 200
      orgs_data = JSON.parse(last_response.body)
      orgs_data.count.should == @orgs.count
    end

  end

  describe 'GET /organizations/:id' do

    describe 'when organization exists' do
      before do
        @org = FactoryGirl.create :organization
        get "/organizations/#{@org.id}", nil, {'HTTP_X_AUTH_TOKEN' => @super_admin.api_key}
      end

      it 'should return the org data' do
        last_response.status.should == 200
        org_data = JSON.parse(last_response.body)
        org_data['name'].should == @org.name
      end
    end

    describe 'when organization does not exist' do
      it 'should return 404' do
      end
    end

  end

  describe 'POST /organizations' do

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

end
