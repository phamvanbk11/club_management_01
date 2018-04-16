require "rails_helper"

RSpec.describe RatingsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: :joined, is_manager: true
  end

  before do
    sign_in user
  end

  describe "POST #create" do
    context "when params present" do
      it "create success" do
        post :create, xhr: true, params: {rating: 4, club_id: club.id}
        expect(flash[:success]).to eq I18n.t("you_raiting_club")
        expect(response).to be_ok
      end
      it "create errors" do
        post :create, xhr: true, params: {rating: 3, club_id: 0}
        expect(flash[:danger]).to eq I18n.t("you_raiting_club_errors")
        expect(response).to be_ok
      end
    end
  end
end
