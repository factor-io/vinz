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
    describe 'when user exists' do
      describe 'when admin is in same org' do
        before { get "/users/#{org.users.first.id}", nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

        it 'returns the user data' do
          last_response.status.should == 200
          data = JSON.parse(last_response.body)
          data['id'].should == org.users.first.id
          data['username'].should == org.users.first.username
          data['password'].should == nil
        end
      end

      describe 'when admin is in different org' do
        before { get "/users/#{org.users.first.id}", nil, 'HTTP_X_AUTH_TOKEN' => FactoryGirl.create(:admin).api_key.key }

        it 'rejects the request' do
          last_response.status.should == 401
        end
      end
    end

    describe 'when user does not exists' do
      before { get "/users/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

      it 'returns a 404' do
        last_response.status.should == 404
      end
    end
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
