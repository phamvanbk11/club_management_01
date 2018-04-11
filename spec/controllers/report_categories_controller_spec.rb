require "rails_helper"

RSpec.describe ReportCategoriesController, type: :controller do
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
        report_category_params = FactoryBot.attributes_for(:report_category)
        expect do
          post :create, xhr: true, params: {
            report_category: report_category_params, organization_slug: organization.slug,
              style: 1
          }
        end.to change(ReportCategory, :count).by 1
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
      it "create fails with invalid params" do
        expect do
          post :create, xhr: true, params: {
            report_category: {name: ""}, organization_slug: organization.slug,
              style: 1
          }
        end.to change(ReportCategory, :count).by 0
        expect(response).to be_ok
      end
    end
  end

  describe "Put #update" do
    let(:report_category) do
      create :report_category, organization: organization
    end
    context "when params present" do
      it "update success with valid params" do
        post :update, xhr: true, params: {
          name: "abcd", status: 1, organization_slug: organization.slug, id: report_category.id,
            style: 1
        }
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
      it "update fail with name nil" do
        post :update, xhr: true, params: {
          name: "", status: 1, organization_slug: organization.slug, id: report_category.id,
            style: 1
        }
        expect(response).to be_ok
      end
    end
  end

  describe "Delete #destroy" do
    let(:report_category) do
      create :report_category, organization: organization
    end
    context "when params present" do
      it "destroy success with valid params" do
        post :destroy, xhr: true, params: {organization_slug: organization.slug,
          id: report_category.id}
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
      it "destroy success with valid params" do
        post :destroy, xhr: true, params: {organization_slug: organization.slug,
          id: report_category.id + 1}
        expect(response).to be_ok
        expect(flash[:danger]).to be_present
      end
    end
  end
end
