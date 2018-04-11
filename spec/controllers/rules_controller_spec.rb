require "rails_helper"

RSpec.describe RulesController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization,
      status: :joined, is_admin: true
  end

  before do
    sign_in user
  end

  describe "Post #create" do
    context "when params present" do
      it "create success with valid params" do
        attributes = {content: "abcs", points: 5}
        rule_params = FactoryBot.attributes_for(:rule, a: attributes)
        expect do
          post :create, xhr: true, params: {
            rule: rule_params, organization_id: organization.slug
          }
        end.to change(Rule, :count).by 1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("flash_rule.success")
      end
      it "create errors with invalid params" do
        rule_params = {name: ""}
        expect do
          post :create, xhr: true, params: {
            rule: rule_params, organization_id: organization.slug
          }
        end.to change(Rule, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "Get #index" do
    context "when params present" do
      it "get success with valid params org" do
        get :index, xhr: true, params: {
          organization_id: organization.slug}
        expect(response).to be_ok
      end
      it "get errors with invalid params org" do
        get :index, xhr: true, params: {
          organization_id: 1
        }
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("flash_rule.cant_find_org")
      end
    end
  end

  describe "Get #edit" do
    let(:rule) do
      create :rule, organization: organization
    end
    context "when params present" do
      it "get success with valid params" do
        get :edit, xhr: true, params: {
          organization_id: organization.slug, id: rule.id}
        expect(response).to be_ok
      end
      it "get errors with invalid params" do
        get :edit, xhr: true, params: {
          organization_id: organization.slug, id: 25
        }
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("flash_rule.cant_find_rule")
      end
    end
  end

  describe "put #update" do
    let(:rule) do
      create :rule, organization: organization
    end
    context "when params present" do
      it "get success with valid params" do
        put :update, xhr: true, params: {
          organization_id: organization.slug, id: rule.id, rule: {name: "tieuchi", note: "note"}}
        expect(response).to be_ok
      end
      it "get success with invalid params" do
        put :update, xhr: true, params: {
          organization_id: organization.slug, id: rule.id, rule: {name: "", note: "note"}}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("flash_rule.errors")
      end
    end
  end

  describe "delete #destroy" do
    let(:rule) do
      create :rule, organization: organization
    end
    context "when params present" do
      it "get success with valid params" do
        delete :destroy, xhr: true, params: {
          organization_id: organization.slug, id: rule.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("flash_rule.success")
      end
    end
  end
end
