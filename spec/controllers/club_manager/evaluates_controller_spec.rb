require "rails_helper"

RSpec.describe ClubManager::EvaluatesController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true
  end
  let!(:evaluate) do
    create :evaluate, user_id: user.id, club_id: club.id
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params present" do
      it "get success" do
        get :index, xhr: true, params: {club_id: club.slug}
        expect(response).to be_ok
      end
      it "get errors" do
        get :index, xhr: true, params: {club_id: "ac"}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.club_not_found")
      end
    end
    context "when params nil" do
      it "get errors" do
        get :index, xhr: true, params: {}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.club_not_found")
      end
    end
  end

  describe "GET #show" do
    context "when params present" do
      it "get success" do
        get :show, xhr: true, params: {club_id: club.slug, id: evaluate.id}
        expect(response).to be_ok
      end
      it "get errors" do
        get :show, xhr: true, params: {club_id: club.slug, id: 0}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.evaluate_not_found")
      end
    end
  end
end
