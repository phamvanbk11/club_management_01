require "rails_helper"

RSpec.describe StatisticReportsController, type: :controller do
  let!(:user){create :user}
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
  before do
    sign_in user
  end

  describe "GET #index" do
    context "with valid attributes" do
      it "create new statistic report" do
        get :index, xhr: true, params: {organization_slug: organization.slug}
        expect(response).to be_ok
      end

      it "create fail params" do
        get :index, xhr: true
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "PATCH #update" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "with valid status" do
      it "update success with approve params" do
        post :update, xhr: true, params: {organization_slug: organization.slug,
          id: statistic_report.id, status: 1}
        expect(flash[:success]).to be_present
        expect(response).to be_ok
      end

      it "update success with reject params" do
        post :update, xhr: true, params: {statistic_report: {reason_reject: "abcd"},
          organization_slug: organization.slug, id: statistic_report.id, status: 3}
        expect(flash[:success]).to be_present
        expect(response).to be_ok
      end
    end
  end

  describe "GET #show" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "with valid id report" do
      it "get success" do
        get :show, xhr: true, params: {id: statistic_report.id, organization_slug: organization.slug}
        expect(response).to be_ok
      end
    end
  end

  describe "GET #dit" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "when params present" do
      it "get success with params valid" do
        get :edit, xhr: true, params: {id: statistic_report.id, organization_slug: organization.slug}
        expect(response).to be_ok
      end

      it "get errors with params invalid" do
        get :edit, xhr: true, params: {id: statistic_report.id + 1, organization_slug: organization.slug}
        expect(response).to be_ok
        expect(flash[:danger]).to be_present
      end
    end
  end
end
