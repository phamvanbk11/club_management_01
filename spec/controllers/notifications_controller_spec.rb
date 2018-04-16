require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: 1, is_manager: true
  end
  let!(:user_club_mem) do
    create :user_club, user: user2, club: club, status: 1, is_manager: false
  end
  let!(:event) do
    create :event, club: club, user: user
  end
  let!(:activity) do
    FactoryBot.create :activity, trackable_type: "Club", container_id: club.id,
    owner_type: "User", container_type: "Club", owner_id: user.id, trackable_id: club.id, type_receive: :club_member
  end
  before do
    sign_in user2
  end

  describe "GET #index" do
    context "when show all index" do
      before do
        get :index
      end
      it{expect(response).to be_ok}
    end
    context "when not user not joined club" do
      before do
        get :index
      end
      it{expect(response).to be_ok}
    end
  end

  describe "GET #update" do
    context "when params present" do
      it "update success" do
        patch :update, xhr: true, params: {id: 0}
        expect(response).to be_ok
      end
    end
  end
end
