require "rails_helper"

RSpec.describe ClubManager::ExportHistoryBudgetsController, type: :controller do
  let(:user){create :user}
  let(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, is_admin: true
  end
  let(:club){create :club}
  let!(:user_club) do
    create :user_club, user: user, club: club
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when paramsid valid" do
      before{get :index, params: {club_id: club.id}}
      it{expect(flash[:danger]).to be_present}
    end
    context "when params id invalid" do
      before{get :index, params: {club_id: club.id + 1}}
      it{expect(flash[:danger]).to eq I18n.t("cant_found_club")}
    end
  end
end
