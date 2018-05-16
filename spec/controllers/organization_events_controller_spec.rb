require "rails_helper"

RSpec.describe OrganizationEventsController, type: :controller do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: 1, is_manager: true
  end
  let!(:event) do
    create :event, club: club, user: user
  end

  before do
    sign_in user
  end

  describe "GET #index" do
    context "when params q nil" do
      it "responds successfully" do
        get :index, xhr: true, params: {id: organization.slug}
        expect(response).to be_success
      end

      it "responds successfully with flash errors" do
        get :index, xhr: true, params: {id: "slug-org"}
        expect(response).to be_success
        expect(flash[:danger]).to eq I18n.t("organization_not_found")
      end
    end

    context "when params q present" do
      it "responds successfully" do
        get :index, xhr: true, params: {id: organization.slug, q: {name_cont: club.name}}
        expect(response).to be_success
      end
    end
  end
end
