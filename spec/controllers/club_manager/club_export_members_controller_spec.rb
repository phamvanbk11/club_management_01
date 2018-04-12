require "rails_helper"

RSpec.describe ClubManager::ClubExportMembersController, type: :controller do
  let!(:user){create :user}
  let!(:club){create :club}
  let!(:user_club) do
    create :user_club, user: user, club: club, status: "joined"
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params[:id] present" do
      before{get :index, xhr: true, format: :xlsx, params: {id: club.slug}}
      it{expect(response).to be_ok}
    end
  end
end
