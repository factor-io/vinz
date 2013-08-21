require_relative '../spec_helper'

describe 'Users' do

  let (:org) { FactoryGirl.create(:full_organization) }
  let(:admin) { org.users.admins.first }

  describe 'GET /users' do
    before { get '/users', nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

    it 'returns the list of users' do
      last_response.status.should == 200
      data = JSON.parse(last_response.body)
      data.count.should == org.users.count
    end
  end

  describe 'GET /users/:id' do
    it 'should be implemented'
  end

  describe 'POST /users' do
    it 'should be implemented'
  end

  describe 'PUT /users/:id' do
    it 'should be implemented'
  end

  describe 'DELETE /users/:id' do
    it 'should be implemented'
  end

end
