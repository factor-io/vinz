require_relative '../spec_helper'

describe 'Config Items' do

  let(:org) { FactoryGirl.create(:full_organization) }

  describe 'GET /config_items' do
    before { get '/config_items', nil, 'HTTP_X_AUTH_TOKEN' => org.consumers.first.token }

    it 'returns all config items consumer has access to' do
      last_response.status.should == 200
      data = JSON.parse(last_response.body)
      data.count.should == org.config_items.count
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
        before { get "/config_items/#{item.id}", nil, 'HTTP_X_AUTH_TOKEN' => FactoryGirl.create(:consumer) }

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
    before { item_data.organization = org }

    describe 'when data is valid' do
      before do
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
        item_data.organization = nil
        item_data.name = nil
        post '/config_items', item_data.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key
      end

      it 'rejects the request' do
        last_response.status.should == 400
      end
    end

  end

  describe 'PUT /config_items/:id' do
    let(:item) { org.config_items.first }
    let(:new_value) { 'new value' }
    before { item.value = new_value }

    describe 'when item exists' do
      describe 'and user has access' do
        describe 'and data is valid' do
          before { put "/config_items/#{item.id}", item.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

          it 'updates the item and returns its attrs' do
            last_response.status.should == 200
            item.reload.value.should == new_value
            data = JSON.parse(last_response.body)
            data['id'].should == item.id
            data['value'].should == item.value
          end
        end

        describe 'but data is invalid' do
          before do
            item.name = nil
            put "/config_items/#{item.id}", item.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key
          end

          it 'rejects the request' do
            last_response.status.should == 400
            item.reload
            item.name.should_not == nil
            item.value.should_not == new_value
          end
        end
      end

      describe 'but user does not have access' do
        before { put "/config_items/#{item.id}", item.to_json, 'HTTP_X_AUTH_TOKEN' => FactoryGirl.create(:user).api_key }

        it 'rejects the request' do
          last_response.status.should == 401
          item.reload.value.should_not == new_value
        end
      end
    end

    describe 'when item does not exist' do
      before { put "/config_items/nonexistent", item.to_json, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

      it 'rejects the request' do
        last_response.status.should == 404
        item.reload.value.should_not == new_value
      end
    end
  end

  describe 'DELETE /config_items/:id' do
    let(:item) { org.config_items.first }

    describe 'when item exists' do
      describe 'and user has access' do
        before { delete "/config_items/#{item.id}", nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

        it 'deletes the item' do
          last_response.status.should == 200
          expect { item.reload }.to raise_error
        end
      end

      describe 'but user does not have access' do
        before { delete "/config_items/#{item.id}", nil, 'HTTP_X_AUTH_TOKEN' => FactoryGirl.create(:user).api_key }

        it 'rejects the request' do
          last_response.status.should == 401
          expect { item.reload }.to_not raise_error
        end
      end
    end

    describe 'when item does not exist' do
      before { delete "/config_items/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => org.users.first.api_key }

      it 'rejects the request' do
        last_response.status.should == 404
        expect { item.reload }.to_not raise_error
      end
    end
  end

end
