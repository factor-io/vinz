require_relative '../spec_helper'

describe 'Access control' do
  describe 'when super_admin is required' do

    describe 'when api key is not supplied' do
      before { get '/organizations' }

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when not a super admin' do
      before do
        user = FactoryGirl.create :user
        headers = {'HTTP_X_AUTH_TOKEN' => user.api_key}
        get '/organizations', nil, headers
      end

      it 'should deny access' do
        last_response.status.should == 401
      end
    end

    describe 'when a super admin' do
      before do
        user = FactoryGirl.create :super_admin
        headers = {'HTTP_X_AUTH_TOKEN' => user.api_key}
        get '/organizations', nil, headers
      end

      it 'should allow access' do
        last_response.status.should == 200
      end
    end

  end

  describe 'when user is required' do

    before do
      @user = FactoryGirl.create :user
    end

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
      before { get '/consumers', nil, 'HTTP_X_AUTH_TOKEN' => @user.api_key }

      it 'should allow access' do
        last_response.status.should == 200
      end
    end

  end

  describe 'when consumer is required' do

    before { @consumer = FactoryGirl.create :consumer }

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
      before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => @consumer.token }

      it 'should allow access' do
        last_response.status.should == 200
      end
    end

  end

end
