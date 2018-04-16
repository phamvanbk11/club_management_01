require "rails_helper"

RSpec.describe "organizations/show", type: :view do
  let!(:user){FactoryBot.create :user}
  let!(:organization){create :organization}
  before do
    sign_in user
  end
  it "displays the name organization" do
    assign(:organization, organization)
    assign(:q, Club.search)
    render
    expect(rendered).to include(organization.name)
  end
end
