require "rails_helper"

RSpec.describe EvaluatesController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, is_admin: true,
      status: :joined
  end
  let!(:rule) do
    create :rule, organization: organization
  end
  let!(:rule_detail) do
    create :rule_detail, rule: rule
  end
  let!(:rule_detail_2) do
    create :rule_detail, rule: rule
  end
  let!(:evaluate) do
    create :evaluate, user: user, club: club
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params present" do
      it "get success" do
        get :index, xhr: true, params: {club_id: club.slug}
        expect(response).to be_ok
      end
      it "get errors" do
        get :index, xhr: true, params: {club_id: "ac"}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.club_not_found")
      end
    end
  end

  describe "GET #show" do
    context "when params present" do
      it "get success" do
        get :show, xhr: true, params: {club_id: club.slug, id: evaluate.id}
        expect(response).to be_ok
      end
      it "get errors" do
        get :show, xhr: true, params: {club_id: club.slug, id: 0}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.evaluate_not_found")
      end
    end
  end

  describe "POST #create" do
    context "when params present" do
      it "create success" do
        params = {rule_detail_ids: [rule_detail.id, rule_detail_2.id], note: ["note1", "note_2"],
          time: 5, date: {year: 2018}, club_id: club.slug}
        expect do
          post :create, xhr: true, params: params
        end.to change(Evaluate, :count).by 1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("evaluates.success")
      end
      it "create errors" do
        params = {rule_detail_ids: [rule_detail.id, 0], note: ["note1", "note_2"],
          time: 5, date: {year: 2018}, club_id: club.slug}
        expect do
          post :create, xhr: true, params: params
        end.to change(Evaluate, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.error_process")
      end
    end
  end

  describe "PATCH #update" do
    context "when params present" do
      let(:evaluate) do
        create :evaluate, club: club
      end
      it "update success" do
        params = {rule_detail_ids: [rule_detail.id, rule_detail_2.id], note: ["note1", "asd"],
          time: 8, date: {year: 2018}, club_id: club.slug, id: evaluate.id}
        patch :update, xhr: true, params: params
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("evaluates.success")
      end
      it "update errors" do
        params = {rule_detail_ids: [rule_detail.id, 0], note: ["note1", "note_2"],
          time: 5, date: {year: 2018}, club_id: club.slug, id: evaluate.id}
        patch :update, xhr: true, params: params
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("evaluates.error_process")
      end
    end
  end

  describe "delete #destroy" do
    context "with params present" do
      let!(:evaluate) do
        create :evaluate, club: club
      end
      it "delete success" do
        expect do
          delete :destroy, xhr: true, params: {id: evaluate.id,
            club_id: club.slug}
        end.to change(Evaluate, :count).by -1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("evaluates.success")
      end
      it "delete errors" do
        allow_any_instance_of(Evaluate).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {club_id: club.slug, id: evaluate.id}
        end.to change(Evaluate, :count).by 0
        expect(flash[:danger]).to eq I18n.t("evaluates.error_process")
      end
    end
  end
end
