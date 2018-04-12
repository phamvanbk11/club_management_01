require "rails_helper"

RSpec.describe ClubRequestOrganizationsController, type: :controller do
  let(:user){create :user}
  let(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, is_admin: true
  end
  let!(:club_request) do
    create :club_request, user: user, organization: organization
  end

  before do
    sign_in user
  end

  describe "PATCH #update" do
    context "when params[:id] and status present" do
      before{patch :update, xhr: true, params: {id: club_request.id, status: 1, organization_id: organization.slug}}
      it{expect(flash[:success]).to eq I18n.t("success_process")}
    end
    context "when params[:id] and status present" do
      before{patch :update, xhr: true, params: {id: club_request.id, status: 2, organization_id: organization.slug}}
      it{expect(flash[:success]).to eq I18n.t("success_process")}
    end
    context "update failed " do
      before do
        allow_any_instance_of(ClubRequest).to receive(:save).and_return false
        patch :update, xhr: true, params: {id: club_request.id, status: 1, organization_id: organization.slug}
      end
      it{expect(flash[:danger]).to eq I18n.t("error_process")}
    end
  end

  describe "GET #index" do
    context "when params present" do
      before{get :index, xhr: true, params: {organization_id: organization.slug}}
      it{expect(response).to be_ok}
    end
    context "when params not present" do
      before{get :index, xhr: true, params: {organization_id: 0}}
      it{expect(flash[:danger]).to eq I18n.t("organization_not_found")}
    end
  end

  describe "GET #edit" do
    context "when params[:id] present" do
      before{get :edit, xhr: true, params: {id: club_request, organization_id: organization.slug}}
      it{expect(response).to be_ok}
    end
    context "when params[:id] not present" do
      before{get :edit, xhr: true, params: {id: 0, organization_id: organization.slug}}
      it{expect(flash[:danger]).to eq I18n.t("not_found_request")}
    end
  end
end
