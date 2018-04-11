class Donate < ApplicationRecord
  acts_as_paranoid

  belongs_to :event
  belongs_to :user, ->{with_deleted}

  after_save :update_event, if: ->{self.accept?}

  enum status: {pending: 0, accept: 1, reject: 2}

  scope :newest, ->{order created_at: :desc}

  delegate :full_name, :email, to: :user, allow_nil: :true

  def self.expense_pending
    sum("expense")
  end

  private
  def update_event
    if self.event.present?
      params = {expense: self.event.expense + self.expense}
      service_money = UpdateClubMoneyService.new self.event, self.event.club, params
      service_money.update_first_money_of_event
      self.event.update_attributes expense: self.event.expense + self.expense
      Event.calculate_get_donate self, self.event
    end
  end
end
