require_relative '../spec_helper'

describe 'Access control' do
  let(:org) { FactoryGirl.create(:full_organization) }
  let(:super_admin) { FactoryGirl.create(:super_admin) }

  describe 'when super_admin is required' do

    describe 'when api key is not supplied' do
      before { get '/organizations' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when not a super admin' do
      before do
        headers = {'HTTP_X_AUTH_TOKEN' => org.users.first.api_key.key}
        get '/organizations', nil, headers
      end

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when a super admin' do
      before do
        headers = {'HTTP_X_AUTH_TOKEN' => super_admin.api_key.key}
        org = FactoryGirl.build :organization
        post '/organizations', org.to_json, headers
      end

      it 'should allow access' do
        last_response.status.should == 201
      end
    end

  end

  describe 'when user is required' do

    describe 'when no key is supplied' do
      before { get '/consumers' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when invalid key is supplied' do
      before { get '/consumers', nil, 'HTTP_X_AUTH_TOKEN' => 'invalid_key' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when valid key is supplied' do
      before { get '/consumers', nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key.key }

      it 'should allow access' do
        last_response.status.should == 200
      end
    end

  end

  describe 'when consumer is required' do

    describe 'when no token is provided' do
      before { get '/config_items' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when invalid token is provided' do
      before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => 'invalid_token' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when valid token is provided' do
      before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.first.api_key.key }

      it 'should allow access' do
        last_response.status.should == 200
      end
    end

  end

end
