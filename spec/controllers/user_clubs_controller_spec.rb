require "rails_helper"

RSpec.describe UserClubsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let(:user_club) do
    create :user_club, user: user, club: club, status: :joined, is_manager: true
  end

  before do
    sign_in user
  end

  describe "POST #create" do
    context "when params present" do
      it "create success" do
        post :create, xhr: true, params: {id: club.slug}
        expect(flash[:success]).to eq I18n.t("join_and_wait")
      end
    end
  end

  describe "GET #show" do
    context "when params present" do
      it "get success" do
        user_club
        get :show, xhr: true, params: {id: club.slug}
        expect(response).to be_ok
      end
      it "get errors" do
        get :show, xhr: true, params: {id: 0}
        expect(flash[:danger]).to eq I18n.t("not_found_club")
      end
    end
  end

  describe "DELETE #destroy" do
    context "when params valid" do
      it "delete errors when last manage" do
        user_club
        delete :destroy, xhr: true, params: {id: club.slug}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("user_club_not_remove")
      end
    end

    context "when params invalid" do
      before do
        sign_in user2
      end
      it "delete errors" do
        delete :destroy, xhr: true, params: {id: club.slug}
        expect(flash[:danger]).to eq I18n.t("not_found_user_club")
      end
    end

    context "when params valid and > 2 manager" do
      let!(:user_club2) do
        create :user_club, user: user2, club: club, status: :joined, is_manager: true
      end
      it "delete success" do
        user_club
        delete :destroy, xhr: true, params: {id: club.slug}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("see_you_next_time")
      end

      it "delete errors" do
        user_club
        allow_any_instance_of(UserClub).to receive(:destroy).and_return false
        delete :destroy, xhr: true, params: {id: club.slug}
        expect(response).to be_ok
      end
    end
  end
end
