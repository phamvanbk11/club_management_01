require "rails_helper"

RSpec.describe AlbumsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club){create :club}
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true, status: :joined
  end
  let!(:album) do
    create :album, club: club
  end

  before do
    sign_in user
  end

  describe "GET #edit" do
    context "when params present" do
      it "get success" do
        get :edit, xhr: true, params: {club_id: club.slug, id: album.id}
        expect(response).to be_ok
      end
      it "get errors with failse club" do
        get :edit, xhr: true, params: {club_id: 0, id: album.id}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("flash_not_found.club")
      end
      it "get errors with failse album" do
        get :edit, xhr: true, params: {club_id: club.slug, id: 0}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("flash_not_found.album")
      end
    end
  end

  describe "GET #show" do
    context "when params present" do
      it "get success" do
        get :show, params: {club_id: club.slug, id: album.id}
        expect(response).to be_ok
      end
      it "get errors invalid club" do
        get :show, params: {club_id: 0, id: album.id}
        expect(flash[:danger]).to eq I18n.t("flash_not_found.club")
      end
      it "get errors invalid album" do
        get :show, params: {club_id: club.slug, id: 0}
        expect(flash[:danger]).to eq I18n.t("flash_not_found.album")
      end
    end
  end

  describe "POST #create" do
    context "when params valid" do
      it "create success" do
        post :create, xhr: true, params: {album: {name: "name album"}, club_id: club.slug}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("club_manager.album.success_create")
      end
      it "create errors" do
        post :create, xhr: true, params: {album: {name: "name"}, club_id: club.slug}
        expect(response).to be_ok
        expect(flash[:danger]).to eq ["Tên bộ sưu tập  quá ngắn (ít nhất 5 ký tự)"]
      end
    end
  end

  describe "PATCH #update" do
    context "when params valid" do
      it "update success" do
        patch :update, xhr: true, params: {album: {name: "name album"}, club_id: club.slug, id: album.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("club_manager.album.success_update")
      end
      it "update errors" do
        patch :update, xhr: true, params: {album: {name: "name"}, club_id: club.slug, id: album.id}
        expect(response).to be_ok
        expect(flash[:danger]).to eq ["Tên bộ sưu tập  quá ngắn (ít nhất 5 ký tự)"]
      end
    end
  end

  describe "GET #index" do
    context "when params present" do
      it "get success" do
        get :index, params: {club_id: club.slug}
        expect(response).to be_ok
      end
    end
  end

  describe "DELETE #destroy" do
    context "when params valid" do
      it "delete success" do
        expect do
          delete :destroy, xhr: true, params: {club_id: club.slug, id: album.id}
        end.to change(Album, :count).by -1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("success_process")
      end
      it "delete errors" do
        allow_any_instance_of(Album).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {club_id: club.slug, id: album.id}
        end.to change(Album, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("error_process")
      end
    end
  end
end
