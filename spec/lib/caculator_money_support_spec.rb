require "rails_helper"

RSpec.describe CaculatorMoneySupport do
  let!(:user){create :user}
  let!(:organization){create :organization}
  let!(:user_organization) do
    create :user_organization, user: user, organization: organization,
      status: :joined, is_admin: true
  end
  let!(:club) do
    create :club, organization: organization, frequency: 1
  end
  let!(:user_club) do
    create :user_club, club: club, user: user
  end
  let(:event) do
    create :event, club: club, user: user
  end
  let(:user_event) do
    create :user_event, event: event, user: user
  end

  let(:point_range) do
    create :range_support, organization: organization, value_from: 1,
      value_to: 20, style: :evaluate_point, operator: :range
  end
  let(:member_range) do
    create :range_support, organization: organization, value_from: 1,
      value_to: 20, style: :member, operator: :range
  end
  let(:point_lessthan) do
    create :range_support, organization: organization, value_from: 10,
      style: :evaluate_point, operator: :less_than
  end
  let(:member_lessthan) do
    create :range_support, organization: organization, value_from: 10,
      style: :member, operator: :less_than
  end
  let(:point_morethan) do
    create :range_support, organization: organization, value_from: 20,
      style: :evaluate_point, operator: :more_than
  end
  let(:member_morethan) do
    create :range_support, organization: organization, value_from: 20,
      style: :member, operator: :more_than
  end
  let(:point_lessthan_or_equal) do
    create :range_support, organization: organization, value_from: 20,
      style: :evaluate_point, operator: :less_than_or_equal
  end
  let(:member_lessthan_or_equal) do
    create :range_support, organization: organization, value_from: 20,
      style: :member, operator: :less_than_or_equal
  end
  let(:point_morethan_or_equal) do
    create :range_support, organization: organization, value_from: 20,
      style: :evaluate_point, operator: :more_than_or_equal
  end
  let(:member_morethan_or_equal) do
    create :range_support, organization: organization, value_from: 20,
      style: :member, operator: :more_than_or_equal
  end

  let(:money_support_range) do
    create :money_support, organization: organization,
      money: 100000, arr_range: [member_range.id, point_range.id]
  end
  let(:money_support_lessthan) do
    create :money_support, organization: organization,
      money: 200000, arr_range: [member_lessthan.id, point_lessthan.id]
  end
  let(:money_support_morethan) do
    create :money_support, organization: organization,
      money: 300000, arr_range: [member_morethan.id, point_morethan.id]
  end
  let(:money_support_lessthan_or_equal) do
    create :money_support, organization: organization,
      money: 400000, arr_range: [member_lessthan_or_equal.id, point_lessthan_or_equal.id]
  end
  let(:money_support_morethan_or_equal) do
    create :money_support, organization: organization,
      money: 500000, arr_range: [member_morethan_or_equal.id, point_morethan_or_equal.id]
  end

  describe "#caculator_money_support" do
    context "when money support blank" do
      it "return 0 VND" do
        caculator = CaculatorMoneySupport.new club, 1, 1
        expect(caculator.caculator_money_support).to eq 0
      end
    end
    context "when size member and point present with operator range" do
      it "return 0 VND" do
        money_support_range
        caculator = CaculatorMoneySupport.new club, 1, 100
        expect(caculator.caculator_money_support).to eq 0
      end
      it "return 100000" do
        money_support_range
        caculator = CaculatorMoneySupport.new club, 10, 10
        expect(caculator.caculator_money_support).to eq money_support_range.money
      end
    end

    context "when size member and point present with operator lessthan" do
      it "return 0 VND" do
        money_support_lessthan
        caculator = CaculatorMoneySupport.new club, 1, 100
        expect(caculator.caculator_money_support).to eq 0
      end
      it "return 200000" do
        money_support_lessthan
        caculator = CaculatorMoneySupport.new club, 9, 9
        expect(caculator.caculator_money_support).to eq money_support_lessthan.money
      end
    end

    context "when size member and point present with operator morethan" do
      it "return 0 VND" do
        money_support_morethan
        caculator = CaculatorMoneySupport.new club, 1, 100
        expect(caculator.caculator_money_support).to eq 0
      end
      it "return 300000" do
        money_support_morethan
        caculator = CaculatorMoneySupport.new club, 25, 21
        expect(caculator.caculator_money_support).to eq money_support_morethan.money
      end
    end

    context "when size member and point present with operator lessthan or equal" do
      it "return 0 VND" do
        money_support_lessthan_or_equal
        caculator = CaculatorMoneySupport.new club, 1, 100
        expect(caculator.caculator_money_support).to eq 0
      end
      it "return 400000" do
        money_support_lessthan_or_equal
        caculator = CaculatorMoneySupport.new club, 20, 19
        expect(caculator.caculator_money_support).to eq money_support_lessthan_or_equal.money
      end
    end

    context "when size member and point present with operator morethan or equal" do
      it "return 0 VND" do
        money_support_morethan_or_equal
        caculator = CaculatorMoneySupport.new club, 1, 100
        expect(caculator.caculator_money_support).to eq 0
      end
      it "return 500000" do
        money_support_morethan_or_equal
        caculator = CaculatorMoneySupport.new club, 20, 20
        expect(caculator.caculator_money_support).to eq money_support_morethan_or_equal.money
      end
    end
  end
end
