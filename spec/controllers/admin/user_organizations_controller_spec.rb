require "rails_helper"

RSpec.describe Admin::UserOrganizationsController, type: :controller do
  let!(:admin){create :admin}
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization,
      status: :joined, is_admin: true
  end

  before do
    sign_in admin
  end

  describe "get #index" do
    context "with params id" do
      it "get success with params q nil" do
        get :index, xhr: true, params: {organization_id: organization.slug}
        expect(response).to be_ok
      end
    end
    context "with params nil" do
      it "get with params q present" do
        get :index, xhr: true, params: {organization_id: 0, full_name_or_email_cont: user.full_name}
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("admin_manage.org.not_find_org")
      end
    end
  end

  describe "patch #update" do
    context "with params present" do
      it "update success with params valid" do
        patch :update, xhr: true, params: {id: user_organization.id,
          organization_id: organization.slug, add_admin: true}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("admin_manage.member.success")
      end
      it "update errors with params invalid" do
        patch :update, xhr: true, params: {id: user_organization.id,
          organization_id: organization.slug, add_admin: "abcd"}
        expect(response).to be_ok
      end
    end
  end

  describe "delete #destroy" do
    context "with params present" do
      it "delete success with params valid" do
        delete :destroy, xhr: true, params: {id: user_organization.id,
          organization_id: organization.slug}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("admin_manage.member.success_destroy")
      end
      it "delete errors" do
        allow_any_instance_of(UserOrganization).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {organization_id: organization.slug, id: user_organization.id}
        end.to change(UserOrganization, :count).by 0
        expect(flash[:danger]).to eq I18n.t("admin_manage.member.errors")
      end
    end
  end
end
