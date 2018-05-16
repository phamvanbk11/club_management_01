require "rails_helper"

RSpec.describe SponsorsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club){create :club, organization: organization}
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true, status: :joined
  end
  let!(:album) do
    create :album, club: club
  end

  before do
    sign_in user
  end

  describe "GET #new" do
    it "get success" do
      get :new, params: {club_id: club.slug}
      expect(response).to render_template(:new)
    end
  end

  describe "GET #index" do
    it "get success" do
      get :index, xhr: true, params: {club_id: club.slug}
      expect(response).to be_ok
    end
  end

  describe "POST #create" do
    context "when params sponsor valid" do
      it "create success" do
        sponsor_params = FactoryBot.attributes_for(:sponsor, club_id: club.id, user_id: user.id)
        post :create, params: {club_id: club.slug, sponsor: sponsor_params}
        expect(flash[:success]).to eq I18n.t("sponsors.create_success")
      end
    end
    context "when params sponsor invalid" do
      it "create errors when params invalid" do
        post :create, params: {club_id: club.slug, sponsor: {sponsor: 1000}}
        expect(flash[:danger]).to be_present
      end
      it "create errors when params nil" do
        post :create, params: {club_id: club.slug, sponsor: {}}
        expect(flash[:danger]).to be_present
      end
      it "create errors invalid club slug" do
        sponsor_params = FactoryBot.attributes_for(:sponsor, club_id: club.id, user_id: user.id)
        post :create, params: {club_id: "club.slug", sponsor: sponsor_params}
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "PATCH #update" do
    let!(:sponsor){create :sponsor, club: club, user: user}
    context "when params sponsor valid" do
      it "update success" do
        sponsor_params = FactoryBot.attributes_for(:sponsor, club_id: club.id, user_id: user.id)
        patch :update, params: {club_id: club.slug, sponsor: sponsor_params, id: sponsor.id}
        expect(flash[:success]).to eq I18n.t("sponsors.update_success")
      end
    end
    context "when params sponsor invalid" do
      it "update errors when invalid params sponsor" do
        patch :update, params: {club_id: club.slug, sponsor: {sponsor: ""}, id: sponsor.id}
        expect(flash[:danger]).to be_present
      end
      it "update errors when invalid sponsor id" do
        patch :update, params: {club_id: club.slug, sponsor: {sponsor: ""}, id: 0}
        expect(flash[:danger]).to be_present
      end
    end
  end
  describe "DELETE #destroy" do
    let!(:sponsor){create :sponsor, club: club, user: user}
    it "delete success" do
      delete :destroy, xhr: true, params: {club_id: club.slug, id: sponsor.id}
      expect(flash[:success]).to eq I18n.t("event_notifications.success_process")
      expect(response).to be_ok
    end
    it "delete false" do
      allow_any_instance_of(Sponsor).to receive(:destroy).and_return false
      expect do
        delete :destroy, xhr: true, params: {club_id: club.slug, id: sponsor.id}
      end.to change(Club, :count).by 0
    end
  end
end
