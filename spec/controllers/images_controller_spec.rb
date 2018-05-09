require "rails_helper"

RSpec.describe ImagesController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, club: club, user: user, is_manager: true
  end
  let!(:album) do
    create :album, club: club
  end
  let(:image) do
    create :image, album: album
  end
  before do
    sign_in user
  end

  describe "POST #create" do
    context "with params present" do
      it "create new images" do
        expect do
          post :create, params: {club_id: club.id, album_id: album.id,
            id: album.id, images: {urls: [1, 2, 3, 4]}}
        end.to change(Image, :count).from(0).to(4)
        expect(flash[:success]).to be_present
      end
      it "create fail with params[:images][:urls] nil" do
        expect do
          post :create, params: {club_id: club.id, album_id: album.id,
            id: album.id, images: {urls: nil}}
        end.to change(Image, :count).by 0
        expect(flash[:danger]).to eq I18n.t("error_in_process")
      end
    end
  end
  describe "DELETE #destroy" do
    context "when params[:id] present" do
      before{delete :destroy, xhr: true, params: {club_id: club.id, album_id: album.id, id: image}}
      it{expect(response).to be_ok}
    end
    context "when params[:id] not present" do
      before{delete :destroy, xhr: true, params: {album_id: album.id, club_id: club.id, id: 1}}
      it{expect(flash[:danger]).to eq I18n.t("flash_not_found.image")}
    end
    context "when params[:album_id] not present" do
      before{delete :destroy, xhr: true, params: {album_id: 0, club_id: club.id, id: image}}
      it{expect(flash[:danger]).to eq I18n.t("flash_not_found.album")}
    end
  end
end
