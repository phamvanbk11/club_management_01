require "rails_helper"

RSpec.describe BudgetsController, type: :controller do
  let!(:user){create :user}
  let(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, is_admin: true
  end
  let!(:club){create :club}
  let!(:user_club) do
    create :user_club, user: user, club: club
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params present" do
      it "get success" do
        get :index, xhr: true, params: {club_id: club.id,
          date_search: {first_date: "2/8/2016", second_date: "8/8/2017"}}
        expect(response).to be_ok
      end
      it "get errors" do
        get :index, xhr: true, params: {club_id: 0,
          date_search: {first_date: "2/8/2016", second_date: "8/8/2017"}}
        expect(flash[:danger]).to eq I18n. t("cant_found_club")
      end
    end
  end
end
