require "rails_helper"

RSpec.describe ClubRequestsController, type: :controller do
  let!(:user){FactoryGirl.create :user}
  let!(:organization){FactoryGirl.create :organization}
  let!(:user_organization) do
    FactoryGirl.create :user_organization, user_id: user.id, organization_id: organization.id
  end

  before do
    sign_in user
  end

  before(:each) do
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  describe "GET #index" do
    before do
      user.club_requests
    end
    it "responds successfully" do
      get :index, params: {user_id: user.id, format: :js}
      expect(response).to be_ok
    end
  end

  describe "GET #new" do
    it "responds successfully" do
      get :new, params: {user_id: user.id}
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create new club request" do
        request_params = FactoryGirl.attributes_for(:club_request, organization_id: organization.id)
        expect do
          post :create, params: {club_request: request_params, user_id: user.id}
        end.to change(ClubRequest, :count).by 1
        expect(flash[:success]).to be_present
      end

      it "create fail with name nil" do
        request_params = FactoryGirl.attributes_for :club_request, name: nil
        expect do
          post :create, params: {club_request: request_params, user_id: user}
        end.to change(ClubRequest, :count).by 0
        expect(flash[:danger]).to be_present
      end
    end
  end
end
