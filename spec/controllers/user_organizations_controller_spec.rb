require "rails_helper"

RSpec.describe UserOrganizationsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}

  before do
    sign_in user
  end

  describe "POST #create" do
    context "when params present" do
      it "create success" do
        expect do
          post :create, params: {id: organization.id}
        end.to change(UserOrganization, :count).by 1
        expect(flash[:success]).to eq I18n.t("success_create_user_organization")
        expect(response).to redirect_to organizations_path
      end

      it "create errors" do
        expect do
          post :create, params: {id: 0}
        end.to change(UserOrganization, :count).by 0
        expect(flash[:danger]).to eq I18n.t("organization_not_found")
        expect(response).to redirect_to organizations_path
      end
    end
  end

  describe "GET #index" do
    context "when params present" do
      it "get success when valid user_id" do
        get :index, params: {user_id: user.id}
        expect(response).to render_template(:index)
      end

      it "get errors when invalid user_id" do
        get :index, params: {user_id: 0}
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "when params present" do
      let!(:user_organization) do
        create :user_organization, user: user, organization: organization, status: :joined, is_admin: true
      end
      let(:user_organization2) do
        create :user_organization, user: user2, organization: organization, status: :joined, is_admin: true
      end
      it "Destroy errors when one user manager organization" do
        expect do
          delete :destroy, params: {id: organization.id}
        end.to change(UserOrganization, :count).by 0
        expect(flash[:danger]).to eq I18n.t("user_organization_not_remove")
        expect(response).to redirect_to organization_path(organization)
      end
      it "destroy success when present other user manager organization" do
        delete :destroy, params: {id: organization.id, user_organization_id: user_organization2.id}
        expect(flash[:success]).to eq I18n.t("cancel_success")
        expect(response).to redirect_to organization_path(organization)
      end
      it "destroy failse" do
        allow_any_instance_of(UserOrganization).to receive(:destroy).and_return false
        delete :destroy, params: {id: organization.id, user_organization_id: user_organization2.id}
        expect(flash[:danger]).to eq I18n.t("cancel_error")
        expect(response).to redirect_to organization_path(organization)
      end
    end
  end
end
