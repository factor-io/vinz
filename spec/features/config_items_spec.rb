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
    let(:item_data) { FactoryGirl.build(:config_item) }

    describe 'when data is valid' do
      before do
        item_data.groups = [org.groups.first]
        post '/config_items', item_data.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key
      end

      it 'stores the item' do
        last_response.status.should == 201
        data = JSON.parse(last_response.body)
        expect { ConfigItem.find(data['id']) }.to_not raise_error
      end
    end

    describe 'when data is invalid' do
      before do
        item_data.groups = [org.groups.first]
        item_data.name = nil
        post '/config_items', item_data.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key
      end

      it 'rejects the request' do
        last_response.status.should == 400
      end
    end

  end

  describe 'PUT /config_items/:id' do
    it 'should be implemented'
  end

  describe 'DELETE /config_items/:id' do
    it 'should be implemented'
  end

end
