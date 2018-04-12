require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization, status: :joined
  end

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when params present" do
      it "get success" do
        get :show, params: {id: user.id}
        expect(response).to be_ok
      end
      it "get errors" do
        get :show, params: {id: 0}
        expect(flash[:danger]).to eq I18n.t("user_not_found")
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "GET #edit" do
    context "when params present" do
      it "get success" do
        get :edit, params: {id: user.id}
        expect(response).to be_ok
      end
      it "get errors" do
        get :edit, params: {id: 0}
        expect(flash[:danger]).to eq I18n.t("user_not_found")
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "PATCH #update" do
    context "when params present and user valid" do
      it "update success" do
        user_params = attributes_for(:user)
        patch :update, params: {id: user.id, user: user_params}
        expect(response).to redirect_to user_url(user)
        expect(flash[:success]).to eq I18n.t("update_user_success")
      end
      it "update errors with invalid user id" do
        user_params = attributes_for(:user)
        patch :update, params: {id: 0, user: user_params}
        expect(flash[:danger]).to eq I18n.t("user_not_found")
        expect(response).to redirect_to root_url
      end
    end

    context "when params present and invalid" do
      it "update errors with invalid params" do
        patch :update, params: {id: user.id, user: {full_name: "abc", email: "email_invalid"}}
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to user_url(user)
      end
    end
  end
end
