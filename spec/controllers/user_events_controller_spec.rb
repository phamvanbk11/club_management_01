require "rails_helper"

RSpec.describe UserEventsController, type: :controller do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:club) do
    create :club, organization: organization
  end
  let!(:user_club) do
    create :user_club, user: user, club: club, status: :joined, is_manager: true
  end
  let!(:user_club) do
    create :user_club, user: user2, club: club, status: :joined, is_manager: false
  end
  let!(:event) do
    create :event, user: user, club: club
  end

  before do
    sign_in user
  end

  describe "POST #create" do
    context "with member join event" do
      it "create success" do
        params = {user_event: {event_id: event.id}}
        post :create, params: params
        expect(flash[:success]).to eq I18n.t("thanks_for_join")
        expect(response).to redirect_to club_event_path(club, event)
      end

      it "create errors" do
        params = {user_event: {event_id: 0}}
        post :create, params: params
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to root_path
      end
    end

    context "with manager import member join event" do
      it "create success" do
        params = {event_id: event.id, user_id: [user.id, user2.id]}
        post :create, params: params
        expect(flash[:success]).to eq I18n.t("user_events.success")
        expect(response).to redirect_to club_event_path(club, event)
      end

      it "create errors" do
        params = {event_id: 0}
        post :create, params: params
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user_event) do
      create :user_event, user: user, event: event
    end
    context "with member join event" do
      it "delete success" do
        expect do
          delete :destroy,xhr: true, params: {event_id: event.id}
        end.to change(UserEvent, :count).by -1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("user_events.success")
      end
      it "delete errors" do
        allow_any_instance_of(UserEvent).to receive(:destroy).and_return false
        expect do
          delete :destroy,xhr: true, params: {event_id: event.id}
        end.to change(UserEvent, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("user_events.error_in_process")
      end
    end

    context "with manager delete member join event" do
      it "delete success" do
        expect do
          delete :destroy,xhr: true, params: {event_id: event.id, member_id: user.id}
        end.to change(UserEvent, :count).by -1
        expect(response).to be_ok
        expect(flash[:success]).to eq I18n.t("user_events.success")
      end
      it "delete errors" do
        allow_any_instance_of(UserEvent).to receive(:destroy).and_return false
        expect do
          delete :destroy,xhr: true, params: {event_id: event.id, member_id: user.id}
        end.to change(UserEvent, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("user_events.error_in_process")
      end
      it "delete errors with invalid member id" do
        expect do
          delete :destroy,xhr: true, params: {event_id: event.id, member_id: 0}
        end.to change(UserEvent, :count).by 0
        expect(response).to be_ok
        expect(flash[:danger]).to eq I18n.t("user_events.cant_find_member")
      end
    end
  end
end
