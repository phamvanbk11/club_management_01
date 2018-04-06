require "rails_helper"

RSpec.describe SetActiveClubsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club){
    create :user_club, user: user, club: club, is_manager: true, status: :joined
  }

  before do
    sign_in user
  end

  describe "PATCH #update" do
    context "when params present" do
      it "update club not active" do
        patch :update, params: {id: club.slug, active: false}
        expect(flash[:success]).to eq I18n.t("activated_success")
      end
      it "update club active" do
        patch :update, params: {id: club.slug, active: true}
        expect(flash[:success]).to eq I18n.t("activated_success")
      end
    end
  end

  context "when params nil" do
    it "fails when invalid club" do
      patch :update, params: {id: 0}
      expect(flash[:danger]).to eq I18n.t("not_found")
    end
  end
end
