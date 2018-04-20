class ReportDetail < ApplicationRecord
  acts_as_paranoid

  serialize :detail
  serialize :user_events, Array

  belongs_to :statistic_report, required: true
  belongs_to :report_category, required: true

  enum style: {money: 1, active: 2, member: 3, other: 4}

  scope :load_detail_budgets, ->{where.not style: :other}
  scope :load_date_report, ->{where date_event: nil}
  scope :by_report_id, ->ids{where statistic_report_id: ids}

  delegate :name, to: :report_category, prefix: :report_category, allow_nil: :true
end
