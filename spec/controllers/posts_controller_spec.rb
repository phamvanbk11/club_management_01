require "rails_helper"

RSpec.describe PostsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: 1, is_manager: 1
  end
  let!(:event) do
    create :event, user: user, club: club
  end
  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params present" do
      it "get success with valid params" do
        get :index, xhr: true, params: {event_id: event.id}
        expect(response).to be_ok
      end

      it "get success with invalid params" do
        get :index, xhr: true, params: {event_id: event.id + 1}
        expect(response).to be_ok
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "GET #show" do
    let(:post) do
      create :post, user: user, target: event
    end

    it "show success with valid params" do
      get :show, params: {id: post.id}
      expect(response).to be_ok
    end

    it "show errors with invalid params" do
      get :show, params: {id: post.id + 1}
      expect(response).to redirect_to(root_path)
      expect(flash[:danger]).to be_present
    end
  end

  describe "POST #create" do
    it "create success with valid params" do
      request_params = FactoryGirl.attributes_for(:post, user_id: user.id,
        target_id: event.id, target_type: event.class.to_s)
      attribute = {url: "url/....", style: 1}
      post :create, params: {event_id: event.id, post: request_params, post_galleries_attributes: attribute}
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(club_event_path(event, club_id: club.slug))
    end

    it "create errors with invalid params" do
      request_params = {name: "", content: "", user_id: user.id,
        target_id: event.id, target_type: event.class.to_s}
      attribute = {url: "url/....", style: 1}
      post :create, params: {event_id: event.id, post: request_params, post_galleries_attributes: attribute}
      expect(flash[:danger]).to be_present
      expect(response).to redirect_to(club_event_path(event, club_id: club.slug))
    end
  end


  describe "PATCH #update" do
    let(:post) do
      create :post, user: user, target: event
    end

    it "update success with valid params" do
      patch :update, params: {id: post.id, post: {name: "abcd", content: "abcd"}}
      expect(flash[:success]).to be_present
    end

    it "update errors with invalid params" do
      request_params = {name: "", content: ""}
      patch :update, params: {id: post.id, post: request_params}
      expect(flash[:danger]).to be_present
    end
  end

  describe "delete #destroy" do
    let!(:post) do
      create :post, user: user, target: event
    end

    it "destroy success with valid params" do
      delete :destroy, params: {id: post.id, event_id: event.id}
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(club_event_path(event, club_id: club.slug))
    end
  end
end
