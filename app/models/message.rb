class Message < ApplicationRecord
  acts_as_paranoid

  attr_accessor :owner_id
  belongs_to :user, ->{with_deleted}
  belongs_to :club

  after_create :send_message

  scope :newest, ->{order created_at: :desc}

  delegate :full_name, to: :user, prefix: :user

  private
  def send_message
    SendMessageJob.perform_now self, owner_id
  end
end
