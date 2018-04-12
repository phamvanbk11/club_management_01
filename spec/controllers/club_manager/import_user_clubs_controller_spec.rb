require "rails_helper"

RSpec.describe ClubManager::ImportUserClubsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true
  end

  before do
    sign_in user
  end

  before(:each) do
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  describe "POST #create" do
    context "with file" do
      it "create fail with no file" do
        post :create, params: {file: nil, club_id: club.slug}
        expect(flash[:danger]).to eq I18n.t("import_file")
      end
      it "create with xlsx" do
        file = fixture_file_upload("abcd.xlsx", "application/vnd.ms-excel")
        post :create, params: {file: file, club_id: club.slug}
        expect(flash[:success]).to be_present
      end
    end
  end
end
