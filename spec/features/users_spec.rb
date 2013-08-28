require_relative '../spec_helper'

describe 'Users' do

  let (:org) { FactoryGirl.create(:full_organization) }
  let(:admin) { org.users.admins.first }

  describe 'GET /users' do
    before { get '/users', nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

    it 'returns the list of users' do
      last_response.status.should == 200
      data = JSON.parse(last_response.body)['users']
      data.count.should == org.users.count
    end
  end

  describe 'GET /users/:id' do
    describe 'when user exists' do
      describe 'when admin is in same org' do
        before { get "/users/#{org.users.first.id}", nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

        it 'returns the user data' do
          last_response.status.should == 200
          data = JSON.parse(last_response.body)['user']
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
    let(:user_data) { FactoryGirl.build(:user) }
    let!(:num_users) { org.users.count }

    describe 'when data is valid' do
      before do
        user_data.organization = org
        post '/users', {user: user_data}.to_json, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key
      end

      it 'creates the user' do
        last_response.status.should == 201
        data = JSON.parse(last_response.body)['user']
        expect { User.find(data['id']) }.to_not raise_error
        org.reload.users.count.should == num_users + 1
      end
    end

    describe 'when data is invalid' do
      before do
        user_data.organization = nil
        user_data.username = nil
        post '/users', {user: user_data}.to_json, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key
      end

      it 'rejects the request' do
        last_response.status.should == 400
        org.reload.users.count.should == num_users
      end
    end
  end

  describe 'PUT /users/:id' do
    let(:user) { org.users.first }
    let(:new_name) { 'new_guy' }
    before { user.username = new_name }

    describe 'when user exists' do
      describe 'and data is valid' do
        before { put "/users/#{user.id}", {user: user}.to_json, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

        it 'updates the user' do
          last_response.status.should == 200
          user.reload.username.should == new_name
        end
      end

      describe 'but data is invalid' do
        before do
          user.username = ''
          put "/users/#{user.id}", {user: user}.to_json, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key
        end

        it 'rejects the request' do
          last_response.status.should == 400
          user.reload.username.should_not == new_name
        end
      end
    end

    describe 'when user does not exist' do
      before { put "/users/nonexistent", {user: user}.to_json, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

      it 'returns 404' do
        last_response.status.should == 404
        user.reload.username.should_not == new_name
      end
    end
  end

  describe 'DELETE /users/:id' do
    let(:user) { org.users.first }

    describe 'when user exists' do
      before { delete "/users/#{user.id}", nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

      it 'deletes the user' do
        last_response.status.should == 200
        expect { user.reload }.to raise_error
      end
    end

    describe 'when user does not exist' do
      before { delete "/users/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => admin.api_key.key }

      it 'rejects the request' do
        last_response.status.should == 404
        expect { user.reload }.to_not raise_error
      end
    end
  end

end
