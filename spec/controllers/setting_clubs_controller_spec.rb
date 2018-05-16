require "rails_helper"

RSpec.describe SettingClubsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: 1, is_manager: true
  end
  let!(:event) do
    create :event, club: club, user: user
  end

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when params club valid" do
      it "responds successfully" do
        get :show, xhr: true, params: {id: club.slug}
        expect(response).to be_success
      end
    end
    context "when params club invalid" do
      it "responds successfully" do
        get :show, xhr: true, params: {id: "club.slug"}
        expect(response).to be_success
        expect(flash[:danger]).to eq I18n.t("setting_clubs.not_found_club")
      end
    end
  end

  describe "GET #edit" do
    it "responds successfully" do
      get :edit, xhr: true, params: {id: club.slug}
      expect(response).to be_success
    end
  end

  describe "PATCH #update" do
    context "when params valid" do
      it "responds successfully" do
        patch :update, xhr: true, params: {id: club.slug, club: {
          frequency: 3, is_action_report: true, club_type_id: 1
        }}
        expect(response).to be_success
        expect(flash[:success]).to eq I18n.t("setting_clubs.update_success")
      end
    end
  end
end
