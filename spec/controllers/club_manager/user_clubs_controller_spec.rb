require "rails_helper"

RSpec.describe ClubManager::UserClubsController, type: :controller do
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

  before(:each) do
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  describe "PATCH #update" do
    context "when params[:club_id] present" do
      it "update success" do
        patch :update, params: {club_id: club.slug, ids: [user.id], roles: ["0"], id: club.id}
        expect(flash[:success]).to eq I18n.t("success_process")
      end
      it "update errors" do
        patch :update, params: {club_id: club.slug, ids: [user.id], roles: nil, id: club.id}
        expect(flash[:danger]).to eq I18n.t("cant_not_update")
      end
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create new user club" do
        expect do
          post :create, params: {user_ids: [user2.id],club_id: club.slug}
        end.to change(UserClub, :count).by 1
        expect(flash[:success]).to eq I18n.t("success_process")
      end

      it "create fail with user_id nil" do
        expect do
          post :create, params: {club_id: club.slug}
        end.to change(UserClub, :count).by 0
        expect(flash[:danger]).to eq I18n.t("error_in_process")
      end

      it "when params[:id] not present" do
        post :create, params: {club_id: 0}
        expect(flash[:danger]).to eq I18n.t("not_found_club")
      end
    end
  end

  describe "DELETE #destroy" do
    context "when params present" do
      it "delete success" do
        expect do
          delete :destroy, xhr: true, params: {club_id: club.slug, id: user_club.id}
        end.to change(UserClub, :count).by -1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("deleted_successfull")
      end
      it "delete errors" do
        allow_any_instance_of(UserClub).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {club_id: club.slug, id: user_club.id}
        end.to change(UserClub, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("error_process")
      end
    end
  end
end
