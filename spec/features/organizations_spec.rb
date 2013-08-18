require_relative '../spec_helper'

describe 'Organizations' do

  before do
    @super_admin = FactoryGirl.create :super_admin
  end

  describe 'GET /organizations' do
    before do
      @orgs = Organization.all
      get '/organizations', nil, {'HTTP_X_AUTH_TOKEN' => @super_admin.api_key}
    end

    it 'should return all organizations' do
      last_response.status.should == 200
      orgs_data = JSON.parse(last_response.body)
      orgs_data.count.should == @orgs.count
    end

  end

  describe 'GET /organizations/:id' do

    describe 'when organization exists' do
      before do
        @org = FactoryGirl.create :organization
        get "/organizations/#{@org.id}", nil, {'HTTP_X_AUTH_TOKEN' => @super_admin.api_key}
      end

      it 'should return the org data' do
        last_response.status.should == 200
        org_data = JSON.parse(last_response.body)
        org_data['name'].should == @org.name
      end
    end

    describe 'when organization does not exist' do
      it 'should return 404' do
      end
    end

  end

  describe 'POST /organizations' do

    describe 'when valid data is provided' do
      before do
        @org = FactoryGirl.build(:organization)
        post '/organizations', @org.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
      end

      it 'should save the org in the db' do
        last_response.status.should == 201
      end
    end

    describe 'when invalid data is provided' do
      before do
        @org = FactoryGirl.build(:organization)
        @org.name = ''
        post '/organizations', @org_.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
      end

      it 'should not save the org in the db' do
        last_response.status.should == 400
      end
    end

  end

  describe 'PUT /organizations/:id' do
    before do
      @org = FactoryGirl.create(:organization)
      @new_org = {
        'name' => 'New organization'
      }
    end

    describe 'when valid data is provided' do
      before do
        put "/organizations/#{@org.id}", @new_org.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
      end

      it 'should update the organization' do
        last_response.status.should == 200
        returned_object = JSON.parse(last_response.body)
        returned_object['name'].should == @new_org['name']
        returned_object['id'].should == @org.id

        @org.reload
        @org.name.should == @new_org['name']
      end
    end

    describe 'when organization does not exist' do
      before do
        put "/organizations/nonexistent", @new_org.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
      end

      it 'should return 404' do
        last_response.status.should == 404
      end
    end

    describe 'when invalid data is provided' do
      before do
        @old_name = @org.name
        put "/organizations/#{@org.id}", {'name' => nil}.to_json, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key
      end

      it 'should return 400 bad request and not update the organization' do
        last_response.status.should == 400

        @org.reload
        @org.name.should == @old_name
      end
    end

  end

  describe 'DELETE /organizations/:id' do
    before do
      @org = FactoryGirl.create(:organization)
    end

    describe 'when organization exists' do
      before { delete "/organizations/#{@org.id}", nil, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key }

      it 'should delete the organization' do
        last_response.status.should == 200
        expect { Organization.find(@org.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'when organization does not exist' do
      before { delete "/organizations/nonexistent", nil, 'HTTP_X_AUTH_TOKEN' => @super_admin.api_key }

      it 'should return 404' do
        last_response.status.should == 404
      end
    end

  end

end
