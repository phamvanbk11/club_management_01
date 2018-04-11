class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, ->{with_deleted}, polymorphic: true
  belongs_to :container, polymorphic: true

  has_many :comments, as: :target, dependent: :destroy
  enum read: {un_read: 0, readed: 1}
  enum type_receive: {club_member: 1, club_manager: 2, organization_manager: 3}

  after_create :push_notify

  serialize :user_read, Array

  scope :of_user_clubs, ->(ar_club_id) do
    where "container_id IN (?) AND container_type = ? OR trackable_id IN (?) AND
      trackable_type = ?", ar_club_id, Settings.notification_club,
      ar_club_id, Settings.notification_club
  end
  scope :of_user_organizations, ->(organization_ids) do
    where "container_id IN (?) AND container_type = ?", organization_ids, Settings.notification_orgz
  end
  scope :oder_by_read, ->{order id: :desc}
  scope :notification_user, ->user_id{where.not owner_id: user_id}
  scope :type_receive, ->type{where type_receive: type}
  scope :activity_ids, ->ids{where id: ids}

  delegate :name, to: :container, prefix: :container, allow_nil: :true
  delegate :name, to: :trackable, prefix: :trackable, allow_nil: :true
  delegate :full_name, to: :owner, prefix: :owner, allow_nil: :true

  def report_month_key?
    self.key == Settings.remind_report_month
  end

  def report_quarter_key?
    self.key == Settings.remind_report_quarter
  end

  def report_month_trackable_style?
    self.trackable.style == Settings.monthly
  end

  def report_quarter_trackable_style?
    self.trackable.style == Settings.quarterly
  end

  private
  def push_notify
    NotificationBroadcastJob.perform_now self, lists_received if lists_received.present?
  end

  def lists_received
    if self.trackable_type == Settings.notification_report &&
      self.container_type == Settings.notification_club
      lists_received = self.container.user_clubs.manager.pluck(:user_id)
    elsif self.trackable_type == Settings.notification_report &&
      self.container_type == Settings.notification_orgz
      lists_received = self.container.user_organizations.are_admin.pluck(:user_id)
    else
      lists_received = self.container.users.try(:ids)
    end
    list_excep_me lists_received
  end

  def list_excep_me lists_received
    lists_received.delete(self.owner_id) if lists_received.present?
    lists_received
  end
end
