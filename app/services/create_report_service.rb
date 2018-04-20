class CreateReportService
  def initialize report_categories, static_report, club
    @report_categories = report_categories
    @static_report = static_report
    @club = club
  end

  def create_report
    events_service = LoadEventsService.new @report_categories, @static_report
    @hash_events = events_service.load_events_to_hash
    @report_detail = []
    @report_categories.each do |report_category|
      @events = @hash_events[report_category.id.to_s]
      report_detail @events, @report_detail, report_category
    end
    @report_detail
  end

  private
  def report_detail events, report_detail, report_category
    @report_detail = report_detail
      if events.present?
        if !report_category.member?
          events.each do |event|
            @report_detail << save_report(event, report_category) if save_report(event, report_category).present?
          end
        else
          @report_detail << report_member(events, report_category)
        end
      end
    return @report_detail
  end

  def save_report event, report_category
    if report_category.money?
      report_detail_new event, report_category
    else
      report_active event, report_category
    end
  end

  def money_detail_report event
    if event.get_money_member?
      event.expense * event.budgets.size
    else
      event.expense
    end
  end

  def report_member events, report_category
    ReportDetail.new(detail: save_report_member(events, report_category),
      statistic_report_id: @static_report.id, report_category_id: report_category.id,
      style: :member)
  end

  def save_report_member events, report_category
    detail = {};
    @club.user_clubs.each do |user_club|
      detail.merge!({user_club.user_id.to_s.to_sym => {employee_code: user_club.user.employee_code,
        name: "#{user_club.user.full_name}",
        size: LastMoney.count_event(user_club.user_id, events)}})
    end
    return detail.merge!(count_event: events.size)
  end

  def budgets_detail event, report_category
    detail = {}
    event.event_details.each do |event|
      detail.merge!({event.id.to_s.to_sym => {name: "#{event.description}", money: "#{event.money}",
        style: event.style, date: event.spent_at}})
    end
    return detail
  end

  def report_detail_new event, report_category
    if (event.activity_money? || event.money?) && event.event_details.present?
      ReportDetail.new(detail: budgets_detail(event, report_category),
        statistic_report_id: @static_report.id, report_category_id: report_category.id,
        style: :money, money: money_detail_report(event),
        first_money: event.amount, date_event: event.date_end, name_event: event.name,
        user_events: event.user_events.map(&:user_full_name))
    elsif !event.activity_money?
      report_active event, report_category
    end
  end

  def report_active event, report_category
    ReportDetail.new(detail: event.description,
      statistic_report_id: @static_report.id, report_category_id: report_category.id,
      style: style_report_detail(report_category), money: money_detail_report(event),
      first_money: event.amount, date_event: event.date_end, name_event: event.name,
      user_events: event.user_events.map(&:user_full_name))
  end

  def style_report_detail report_category
    if report_category.money?
      ReportDetail.styles[:money]
    elsif report_category.activity?
      ReportDetail.styles[:active]
    end
  end
end
