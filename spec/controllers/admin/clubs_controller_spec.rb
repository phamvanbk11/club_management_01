require "rails_helper"

RSpec.describe Admin::ClubsController, type: :controller do
  let(:admin){create :admin}
  let(:organization){create :organization}
  let(:club) do
    create :club, organization: organization
  end

  before do
    sign_in admin
  end

  describe "get #index" do
    context "with nil params" do
      it "get with params q nil" do
        get :index, xhr: true,params: {organization_id: organization}
        expect(response).to be_ok
      end
    end
    context "with params present" do
      it "get with params q present" do
        get :index, xhr: true, params: {organization_id: organization, name_cont: club.name}
        expect(response).to be_ok
      end
    end
    context "with params present" do
      it "get with params q present" do
        get :index, xhr: true, params: {organization_id: 0, name_cont: club.name}
        expect(flash[:danger]).to eq I18n.t("organization_not_found")
      end
    end
  end

  describe "get #show" do
    let!(:club) do
      create :club, organization: organization
    end
    context "with params present" do
      it "get success with params user_id valid" do
        get :show, params: {organization_id: organization, id: club.id}
        expect(response).to be_ok
      end
      it "get errors with params user_id invalid" do
        get :show, params: {organization_id: organization, id: 0}
        expect(flash[:danger]).to eq I18n.t("not_found")
      end
    end
  end

  describe "get #edit" do
    context "with params present" do
      it "get errors with params user_id invalid" do
        get :show, params: {organization_id: organization, id: 0}
        expect(flash[:danger]).to eq I18n.t("not_found")
      end
    end
  end

  describe "PATCH #update" do
    let! :club_params do
      {
        name: "Thanh tung",
        member: 13,
        content: "Da Nang",
      }
    end
    let!(:club) do
      create :club, organization: organization
    end
    context "when params[:id] not present" do
      before{patch :update, params: {organization_id: organization, id: club, club: club_params}}
      it{expect(flash[:success]).to eq I18n.t("club_manager.club.success_update")}
    end
    context "with params present" do
      it "get errors with params user_id invalid" do
        get :show, params: {organization_id: organization, id: 0}
        expect(flash[:danger]).to eq I18n.t("not_found")
      end
    end
    context "with params present" do
      it "get with params q present" do
        get :index, xhr: true, params: {organization_id: 0, name_cont: club.name}
        expect(flash[:danger]).to eq I18n.t("organization_not_found")
      end
    end
  end

  describe "delete #destroy" do
    context "with params present" do
      it "destroy success" do
        expect do
          delete :destroy, xhr: true, params: {organization_id: organization, id: club.id}
        end.to change(Club, :count).by 1
        expect(response).to be_ok
      end
    end
    context "delete faild" do
      it do
        allow_any_instance_of(Club).to receive(:destroy).and_return false
        expect do
          delete :destroy, xhr: true, params: {organization_id: organization, id: club.id}
        end.to change(Club, :count).by 1
      end
    end
  end
end
