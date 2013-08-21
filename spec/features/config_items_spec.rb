require_relative '../spec_helper'

describe 'Config Items' do

  let(:org) { FactoryGirl.create(:full_organization) }

  describe 'GET /config_items' do
    describe 'when consumer belongs to groups with items' do
      before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.first.token }

      it 'returns all config items consumer has access to' do
        last_response.status.should == 200
        data = JSON.parse(last_response.body)
        data.count.should == org.consumers.first.config_items.count
      end
    end

    describe 'when consumer does not have belong to groups with items' do
      before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.last.token }

      it 'returns an empty array' do
        last_response.status.should == 200
        data = JSON.parse(last_response.body)
        data.count.should == 0
      end
    end
  end

  describe 'GET /config_items/:id' do
    describe 'when item exists' do
      let(:item) { org.config_items.first }

      describe 'when consumer has access' do
        before { get "/config_items/#{item.id}", nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.first.token }

        it 'returns the item data' do
          last_response.status.should == 200
          data = JSON.parse(last_response.body)
          data['name'].should == item.name
          data['id'].should == item.id
        end
      end

      describe 'when consumer does not have access' do
        before { get "/config_items/#{item.id}", nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.last.token }

        it 'rejects the request' do
          last_response.status.should == 401
        end
      end
    end

    describe 'when item does not exist' do
      before { get "/config_items/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.last.token }

      it 'returns a 404' do
        last_response.status.should == 404
      end
    end
  end

  describe 'POST /config_items' do
    it 'should be implemented'
  end

  describe 'PUT /config_items/:id' do
    it 'should be implemented'
  end

  describe 'DELETE /config_items/:id' do
    it 'should be implemented'
  end

end
