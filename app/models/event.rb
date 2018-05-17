class Event < ApplicationRecord
  attr_accessor :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h
  CROP_IMAGE = [:image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h]

  acts_as_paranoid
  serialize :description

  has_many :news, dependent: :destroy
  has_many :user_events, dependent: :destroy
  has_many :users, through: :user_events
  has_many :comments, as: :target, dependent: :destroy
  has_many :posts, as: :target, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :notifications, as: :target
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :donates, dependent: :destroy
  has_many :albums, dependent: :destroy
  has_many :event_details, dependent: :destroy

  accepts_nested_attributes_for :event_details, allow_destroy: true,
    reject_if: proc {|attributes| attributes[:description].blank?}

  belongs_to :club
  belongs_to :user, ->{with_deleted}
  belongs_to :organization

  after_destroy :update_money
  mount_uploader :image, ImageEventUploader

  validates :name, presence: true, length: {minimum: Settings.min_name}
  validates :expense, length: {maximum: Settings.max_exspene}
  validates :location, length: {maximum: Settings.max_location}
  validates :date_end, presence: true
  validates :date_start, presence: true
  validate :end_date_is_after_start_date

  scope :top_like, ->{order num_like: :desc}
  scope :of_month_payment, ->month_payment{where month_of_payment: month_payment}
  scope :newest, ->{order created_at: :desc}
  scope :periodic, ->{where event_category: Settings.periodic_category}
  scope :by_current_year, ->{where "year(date_end) = ?", Time.zone.now.year}
  scope :by_quarter, ->months{where("month(date_end) in (?)", months)}
  scope :by_event, ->event_category{where event_category: event_category}
  scope :by_years, ->years{where "year(date_end) = ?", years}
  scope :without_notification, ->category_notification do
    where.not event_category: category_notification
  end
  scope :by_months, ->months{where("month(date_end) in (?)", months)}
  scope :by_created_at, ->(first_date, end_date) do
    where("DATE(created_at) BETWEEN DATE(?) AND DATE(?)", first_date, end_date)
  end
  scope :more_id_event, ->id{where "id > ?", id}
  scope :in_categories, ->ids{where event_category: ids}
  scope :status_public, ->is_public{where is_public: is_public}
  scope :events_auto_create, ->is_auto_create{where is_auto_create: is_auto_create}
  scope :event_category_activity_money, ->ids, activity_money_id do
    where "case event_category
    when ? then exists (SELECT * FROM event_details WHERE events.id = event_id)
    else event_category in (?)
    end", activity_money_id, ids
  end
  scope :event_public, ->{where is_public: true}
  scope :in_clubs, ->club_ids{where club_id: club_ids}

  enum status: {inprocess: 0, finished: 1}
  enum event_category: {notification: 0, activity_money: 2,
    money: 3, get_money_member: 4, donate: 5, subsidy: 6}

  delegate :full_name, :avatar, to: :user, prefix: :user
  delegate :name, :logo, :slug, to: :club, prefix: :club

  accepts_nested_attributes_for :albums

  attr_accessor :size_budgets

  def self.group_by_quarter
    quarters = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
    array = Array.new
    quarters.each_with_index do |_quarter, index|
      list_events = self.by_quarter quarters[index]
      array.push list_events
    end
    array
  end

  def cost_expense total
    self.update_attributes expense: self.expense.to_i + self.amount.to_i * total
  end

  def by_user? user
    user.id == self.user_id
  end

  def notification?
    self.event_category == Settings.event_notification
  end

  class << self
    def calculate_get_donate donate, event
      event.club.update_attributes money: donate.expense.to_i + event.club.money.to_i
    end

    def money_event_keys
      Event.event_categories.except(:money, :get_money_member, :donate, :subsidy).keys
    end

    def array_style_event_money
      [Event.event_categories[:activity_money], Event.event_categories[:money],
        Event.event_categories[:get_money_member],
        Event.event_categories[:donate], Event.event_categories[:subsidy]]
    end

    def array_style_event_activity
      [Event.event_categories[:activity_money]]
    end

    def array_style_event_member
      [Event.event_categories[:activity_money]]
    end

    def array_style_event_money_except_activity
      [Event.event_categories[:money], Event.event_categories[:get_money_member],
        Event.event_categories[:donate], Event.event_categories[:subsidy]]
    end
  end

  def set_attr_crop_image x, y, h, w
    self.image_crop_x = x
    self.image_crop_y = y
    self.image_crop_h = h
    self.image_crop_w = w
  end

  def update_money
    if in_type_money_event?
      update_money_club_and_more_event self.expense
    elsif self.get_money_member?
      update_money_club_and_more_event(self.expense * self.size_budgets)
    end
  end

  def get_money_by_style style
    details_group = self.event_details.group_by(&:style)
    count_money_details details_group, style
  end

  def is_in_club? club
    self.club == club
  end

  private

  def count_money_details details_group, style
    count = Settings.default_money
    details = details_group[EventDetail.styles.key(style)] if details_group
    if details
      details.each do |detail|
        count += detail.money
      end
    end
    count
  end

  def in_type_money_event?
    self.money? || self.activity_money? || self.subsidy? || self.donate?
  end

  private

  def end_date_is_after_start_date
    return if date_end.blank? || date_start.blank?
    if date_end < date_start
      errors.add(:date_end, I18n.t("date_end_errors"))
    end
  end

  def update_money_club_and_more_event money_change
    self.club.update_attributes money: self.club.money - money_change
    list_event_after_event_update = self.club.events
      .event_category_activity_money(Event.array_style_event_money_except_activity,
      Event.event_categories[:activity_money]).more_id_event self.id
    events = []
    list_event_after_event_update.each do |event|
      if event.amount
        event.amount -= money_change
        events << event
      end
    end
    Event.import events, on_duplicate_key_update: [:amount]
  end
end
