require_relative '../spec_helper'

describe 'Access control' do
  describe 'when requires super_admin' do

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
        puts User.first.to_json
        last_response.status.should == 200
      end
    end

  end

  describe 'when requires consumer' do
  end

end
