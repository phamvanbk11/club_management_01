require 'rails_helper'

RSpec.describe Sponsor, type: :model do
  context "associations" do
    it{is_expected.to belong_to :club}
    it{is_expected.to belong_to :user}
  end
end
