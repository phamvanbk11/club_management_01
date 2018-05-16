require "rails_helper"

RSpec.describe ClubManager::StatisticReportsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization, is_action_report: true
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true
  end
  let!(:organization_setting) do
    create :organization_setting, organization: organization, key: Settings.key_dealine_report
  end

  before do
    sign_in user
  end

  before(:each) do
    request.env["HTTP_REFERER"] = "where_i_came_from"
  end

  describe "get #new" do
    context "with params club" do
      it "get success with valid params" do
        get :new, params: {club_id: club.slug}
        expect(response).to be_ok
      end

      it "get errors with valid params" do
        get :new, params: {club_id: "abcd"}
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create new statistic report" do
        expect do
          post :create, xhr: true, params: {statistic_report:
            attributes_for(:statistic_report), date: {year: 2017}, quarter: 3, club_id: club.slug}
        end.to change(StatisticReport, :count).by 1
        expect(flash[:success]).to be_present
      end

      it "create fail with invalid report" do
        expect do
          post :create, xhr: true, params: {statistic_report: {style: 2},
            date: {year: 2017}, quarter: 3, club_id: club.slug}
        end.to change(StatisticReport, :count).by 0
        expect(flash[:danger]).to be_present
      end

      it "create fail with invalid club" do
        expect do
          post :create, xhr: true, params: {statistic_report: {style: 2},
            date: {year: 2017}, quarter: 3, club_id: "abcd"}
        end.to change(StatisticReport, :count).by 0
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "get #index" do
    context "with params" do
      it "get with params q nil" do
        get :index, xhr: true, params: {club_id: club.slug}
        expect(response).to be_ok
      end
      it "get with params q" do
        get :index, xhr: true, params: {club_id: club.slug, q: {style_eq: 1, time_eq: 1}}
        expect(response).to be_ok
      end
      it "get with params club fails" do
        get :index, xhr: true, params: {club_id: "abcd"}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("error_load_club")
      end
    end
  end

  describe "get #show" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "with params" do
      it "get with params true" do
        get :show, xhr: true, params: {club_id: club.slug, id: statistic_report.id}
        expect(response).to be_ok
      end
      it "get with params false" do
        get :show, xhr: true, params: {club_id: club.slug, id: statistic_report.id + 1}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("error_find_report")
      end
      it "get with params club fails" do
        get :show, xhr: true, params: {club_id: "abcd", id: statistic_report.id}
        expect(response).to be_ok
      end
    end
  end

  describe "put #update" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "with params" do
      it "update with params month present" do
        report_params = {item_report: "item_report", detail_report: "detail_report",
          plan_next_month: "plan_next_month", style: "1"}
        put :update, xhr: true, params: {statistic_report: report_params, month: "5",
          club_id: club.slug, id: statistic_report.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("update_report_success")
      end
      it "update with params quarter present" do
        report_params = {item_report: "item_report", detail_report: "detail_report",
          plan_next_month: "plan_next_month", style: "2"}
        put :update, xhr: true, params: {statistic_report: report_params, quarter: "4",
          club_id: club.slug, id: statistic_report.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("update_report_success")
      end
      it "update with params id invalid" do
        report_params = {item_report: "", detail_report: "",
          plan_next_month: "plan_next_month", style: "1"}
        put :update, xhr: true, params: {statistic_report: report_params, month: "5",
          club_id: club.slug, id: statistic_report.id + 1}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("error_find_report")
      end
      it "update with params invalid" do
        report_params = {item_report: "", detail_report: "",
          plan_next_month: "", style: "1"}
        put :update, xhr: true, params: {statistic_report: report_params, month: "5",
          club_id: club.slug, id: statistic_report.id}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("club_manager.statistic_reports.error_process")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:statistic_report) do
      create :statistic_report, club: club, user: user
    end
    context "when params present" do
      it "destroy success with valid id" do
        post :destroy, xhr: true, params: {club_id: club.slug, id: statistic_report.id}
        expect(flash[:success]).to eq I18n.t("success_process")
        expect(response).to be_ok
      end
      it "destroy success with invalid id" do
        post :destroy, xhr: true, params: {club_id: club.slug, id: statistic_report.id + 1}
        expect(flash[:danger]).to eq I18n.t("error_find_report")
        expect(response).to be_ok
      end
      it "destroy success with invalid id club" do
        post :destroy, xhr: true, params: {club_id: "abcd", id: statistic_report.id}
        expect(flash[:danger]).to eq I18n.t("error_load_club")
        expect(response).to be_ok
      end
    end
  end
end
