require "rails_helper"

RSpec.describe WarningReportsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, status: :joined, is_admin: true
  end
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: 1, is_manager: 1
  end
  let(:warning_report) do
    create :warning_report, club: club
  end
  before do
    sign_in user
  end

  describe "GET #index" do
    context "with valid attributes" do
      it "get success" do
        get :index
        expect(response).to be_ok
      end
    end
  end

  describe "POST #create" do
    context "when params present" do
      it "create success" do
        post :create, xhr: true, params: {club_id: club.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("warning_reports.messenger_report_success")
      end
    end
  end

  describe "GET #edit" do
    context "with user have manager" do
      it "get success" do
        get :edit, xhr: true, params: {id: warning_report.id}
        expect(response).to be_ok
      end
    end
    context "with users no club manager" do
      before do
        sign_in user2
      end
      it "get errors" do
        get :edit, xhr: true, params: {id: 0}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("no_notification")
      end
    end
  end
end
