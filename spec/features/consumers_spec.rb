require_relative '../spec_helper'

describe 'Consumers' do

  let(:org) { FactoryGirl.create(:full_organization) }
  let(:user) { org.users.first }
  let(:consumer) { org.consumers.first }

  describe 'GET /consumers' do
    before { get '/consumers', nil, {'HTTP_X_AUTH_TOKEN' => user.api_key} }

    it 'returns all the organizations consumers' do
      last_response.status.should == 200
      consumer_data = JSON.parse(last_response.body)
      consumer_data.count.should == org.consumers.count
    end
  end

  describe 'GET /consumers/:id' do
    describe 'when consumer exists' do

      describe 'and user has access' do
        before { get "/consumers/#{consumer.id}", nil, 'HTTP_X_AUTH_TOKEN' => user.api_key }

        it 'returns the consumer data' do
          last_response.status.should == 200
          consumer_data = JSON.parse(last_response.body)
          consumer_data['name'].should == consumer.name
          consumer_data['id'].should == consumer.id
        end
      end

      describe 'but user does not have access' do
        let(:new_consumer) { FactoryGirl.create :consumer }

        before do
          get "/consumers/#{new_consumer.id}", nil, 'HTTP_X_AUTH_TOKEN' => user.api_key
        end

        it 'denies access' do
          last_response.status.should == 401
        end
      end

    end

    describe 'when consumer does not exist' do
      before { get '/consumers/nonexistent', nil, 'HTTP_X_AUTH_TOKEN' => user.api_key }

      it 'should return 404' do
        last_response.status.should == 404
      end
    end
  end

  describe 'POST /consumers' do
    let(:consumer_data) { FactoryGirl.build(:consumer) }

    describe 'when valid data is sent' do
      before do
        consumer_data.organization = org
        post '/consumers', consumer_data.to_json, 'HTTP_X_AUTH_TOKEN' => user.api_key
      end

      it 'stores the data in the DB' do
        last_response.status.should == 201
        data = JSON.parse(last_response.body)
        c = Consumer.find(data['id'])
        c.name.should == consumer_data.name
      end
    end

    describe 'when invalid data is sent' do
      let(:num_consumers) { Consumer.count }
      before do
        consumer_data.organization = FactoryGirl.create :organization
        post '/consumers', consumer_data.to_json, 'HTTP_X_AUTH_TOKEN' => user.api_key
      end

      it 'rejects the request' do
        last_response.status.should == 401
        Consumer.count.should == num_consumers
      end
    end
  end

  describe 'PUT /consumers/:id' do
    let(:new_name) { 'New Name' }

    describe 'when data is valid' do
      before do
        consumer.name = new_name
        put "/consumers/#{consumer.id}", consumer.to_json, 'HTTP_X_AUTH_TOKEN' => user.api_key
      end

      it 'updates the consumer' do
        last_response.status.should == 200
        consumer.reload.name.should == new_name
      end
    end

    describe 'when data is invalid' do
      before do
        consumer.name = nil
        put "/consumers/#{consumer.id}", consumer.to_json, 'HTTP_X_AUTH_TOKEN' => user.api_key
      end

      it 'rejects the request' do
        last_response.status.should == 400
        consumer.reload.name.should_not == nil
      end
    end

    describe 'when user does not have access' do
      before do
        consumer.organization = FactoryGirl.create(:organization)
        put "/consumers/#{consumer.id}", consumer.to_json, 'HTTP_X_AUTH_TOKEN' => user.api_key
      end

      it 'rejects the request' do
        last_response.status.should == 401
        consumer.reload.organization.id.should == org.id
      end
    end
  end

  describe 'DELETE /consumers/:id' do
    describe 'when consumer exists' do
      describe 'when user has access' do
        before { delete "/consumers/#{consumer.id}", nil, 'HTTP_X_AUTH_TOKEN' => user.api_key }

        it 'deletes the consumer' do
          last_response.status.should == 200
          expect { consumer.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe 'when user does not have access' do
        before do
          consumer.update_attributes organization: FactoryGirl.create(:organization)
          delete "/consumers/#{consumer.id}", nil, 'HTTP_X_AUTH_TOKEN' => user.api_key
        end

        it 'rejects the request' do
          last_response.status.should == 401
          expect { consumer.reload }.to_not raise_error
        end
      end
    end

    describe 'when consumer does not exist' do
      let(:num_consumers) { Consumer.count }
      before { delete '/consumers/nonexistent', nil, 'HTTP_X_AUTH_TOKEN' => user.api_key }

      it 'returns 404' do
        last_response.status.should == 404
        Consumer.count.should == num_consumers
      end
    end
  end

end
