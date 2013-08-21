require_relative '../spec_helper'

describe 'Groups' do

  let(:org) { FactoryGirl.create(:full_organization) }

  describe 'GET /groups' do
    before { get '/groups', nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

    it 'returns list of groups' do
      last_response.status.should == 200
      data = JSON.parse(last_response.body)
      data.count.should == org.groups.count
    end
  end

  describe 'GET /groups/:id' do
    let(:group) { org.groups.first }

    describe 'when group exists' do
      describe 'and user has access' do
        before { get "/groups/#{group.id}", nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

        it 'returns the group data' do
          last_response.status.should == 200
          data = JSON.parse(last_response.body)
          data['id'].should == group.id
          data['name'].should == group.name
        end
      end

      describe 'but user does not have access' do
        before { get "/groups/#{group.id}", nil, 'HTTP_X_AUTH_TOKEN' => FactoryGirl.create(:user).api_key }

        it 'rejects the request' do
          last_response.status.should == 401
        end
      end
    end

    describe 'when group does not exist' do
      before { get "/groups/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

      it 'returns 404' do
        last_response.status.should == 404
      end
    end
  end

  describe 'POST /groups' do
    it 'should be implemented'
  end

  describe 'PUT /groups/:id' do
    it 'should be implemented'
  end

  describe 'DELETE /groups/:id' do
    it 'should be implemented'
  end

end
