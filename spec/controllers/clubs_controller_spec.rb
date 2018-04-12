require "rails_helper"

RSpec.describe ClubsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user,
      organization: organization, status: 1, is_admin: 1
  end
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, is_manager: true
  end

  before do
    sign_in user
  end

  describe "GET #new" do
    it "responds successfully" do
      get :new, xhr: true, params: {organization_id: organization.id}
      expect(response).to be_ok
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create new club" do
        expect do
          post :create, params: {organization_id: organization.slug,
            club: attributes_for(:club)}
        end.to change(Club, :count).by 1
        expect(flash[:success]).to eq I18n.t("success_create_club")
      end
      it "create new fail club" do
        expect do
          post :create, params: {organization_id: organization.slug}
        end.to change(Club, :count).by 0
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "PATCH #update" do
    context "with params present" do
      it "update club success" do
        patch :update, xhr: true, params: {organization_id: organization.slug, id: club.slug,
          club: {rule_finance: "abcde", plan: "plan"}}
        expect(flash[:success]).to eq I18n.t("club_manager.club.success_update")
      end
      it "update fail" do
        patch :update, xhr: true, params: {organization_id: organization.slug,id: club.slug,
          club: {goal: ""}}
        expect(flash[:danger]).to be_present
      end
    end
  end
end
