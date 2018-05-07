require "rails_helper"

RSpec.describe RangeSupportsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, is_admin: true,
      status: :joined
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    it "responds successfully" do
      get :index, xhr: true, params: {organization_id: organization.slug}
      expect(response).to be_ok
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create new range" do
        expect do
          post :create, xhr: true, params: {organization_id: organization.slug,
            range_support: attributes_for(:range_support)}
        end.to change(RangeSupport, :count).by 1
        expect(flash[:success]).to eq I18n.t("range_supports.create_success")
        expect(response).to be_ok
      end
      it "create new false" do
        expect do
          post :create, xhr: true, params: {organization_id: organization.slug, range_support: {value_from: 50}}
        end.to change(RangeSupport, :count).by 0
      end
    end
  end

  let!(:range_support) do
    create :range_support, organization: organization
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "update range" do
        patch :update, xhr: true, params: {id: range_support.id,
          organization_id: organization.slug,
          range_support: attributes_for(:range_support)}
        expect(flash[:success]).to eq I18n.t("range_supports.update_success")
        expect(response).to be_ok
      end
      it "update false with invalid id" do
        patch :update, xhr: true, params: {id: 15, organization_id: organization.slug, range_support: attributes_for(:range_support)}
        expect(flash[:danger]).to eq I18n.t("range_supports.not_found_range_support")
        expect(response).to be_ok
      end
    end
  end

  describe "delete #destroy" do
    context "with params present" do
      it "delete success with params valid" do
        delete :destroy, xhr: true, params: {organization_id: organization.slug,
          id: range_support.id}
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("range_supports.destroy_success")
      end
      it "delete errors" do
        allow_any_instance_of(RangeSupport).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {organization_id: organization.slug, id: range_support.id}
        end.to change(RangeSupport, :count).by 0
        expect(flash[:danger]).to eq I18n.t("range_supports.destroy_errors")
      end
    end
  end
end
