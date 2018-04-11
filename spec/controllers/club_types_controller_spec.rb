require "rails_helper"

RSpec.describe ClubTypesController, type: :controller do
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
        club_type_params = FactoryBot.attributes_for(:club_type)
        expect do
          post :create, xhr: true, params: {
            club_type: club_type_params, organization_id: organization.slug
          }
        end.to change(ClubType, :count).by 1
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
      it "create fails with invalid params" do
        expect do
          post :create, xhr: true, params: {
            club_type: {name: ""}, organization_id: organization.slug
          }
        end.to change(ClubType, :count).by 0
        expect(response).to be_ok
      end
    end
  end

  describe "Put #update" do
    let(:club_type) do
      create :club_type, organization: organization
    end
    context "when params present" do
      it "update success with valid params" do
        post :update, xhr: true, params: {
          name: "abcd", organization_id: organization.slug, id: club_type.id
        }
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
      it "update fail with name nil" do
        post :update, xhr: true, params: {
          name: "", organization_id: organization.slug, id: club_type.id
        }
        expect(response).to be_ok
      end
    end
  end

  describe "Delete #destroy" do
    let(:club_type) do
      create :club_type, organization: organization
    end
    context "when params present" do
      it "destroy success with valid params" do
        post :destroy, xhr: true, params: {organization_id: organization.slug,
          id: club_type.id}
        expect(response).to be_ok
        expect(flash[:success]).to be_present
      end
    end
  end
end
