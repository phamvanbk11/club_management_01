require "rails_helper"

RSpec.describe FrequencyClub do
  let!(:user){create :user}
  let!(:user2){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization,
      status: :joined, is_admin: true
  end
  let!(:club) do
    create :club, organization: organization, frequency: 1
  end
  let!(:club2) do
    create :club, organization: organization, frequency: 0
  end
  let!(:user_club) do
    create :user_club, club: club, user: user
  end
  let!(:user_club2) do
    create :user_club, club: club2, user: user
  end
  let(:event) do
    create :event, club: club, user: user
  end
  let(:user_event) do
    create :user_event, event: event, user: user
  end

  describe "#users_frequency_club" do
    context "when frequency club > 0" do
      it "return []" do
        frequency_club = FrequencyClub.new club, 8, 2019, nil
        expect(frequency_club.users_frequency_club).to eq []
      end

      it "return [user]" do
        user_event
        frequency_club = FrequencyClub.new club, Date.today.month, Date.today.year, nil
        expect(frequency_club.users_frequency_club).to eq [user]
      end
    end
    context "when frequency = 0" do
      it "return [user]" do
        frequency_club = FrequencyClub.new club2, Date.today.month, Date.today.year, nil
        expect(frequency_club.users_frequency_club).to eq [user]
      end
    end
    context "when new with user_ids" do
      it "return [user, user2]" do
        frequency_club = FrequencyClub.new club2, Date.today.month, Date.today.year, [user.id, user2.id]
        expect(frequency_club.users_frequency_club).to eq [user, user2]
      end
    end
  end
end
