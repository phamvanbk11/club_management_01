class LoadEventsService
  def initialize report_categories, report
    @club = report.club
    @report_categories = report_categories
    @report = report
    @year = report.year || Date.current.year
    @time = report.time || Date.current.month
  end

  def load_events_to_hash
    hash_events = {}
    time_range_setting = time_range_by_report
    @report_categories.obligatory.each do |category|
      hash_events.merge! get_hash_events_by_event_category_report_month(
        category.id.to_s, category.style_event, time_range_setting, category)
    end
    hash_events
  end

  def time_range_by_report
    day_report = @club.organization.organization_settings.find_by(key: Settings.key_date_report)&.value ||
      Settings.date_report_default
    if @report.id.present?
      if @report.monthly?
        ExtendDate.get_begin_and_end_of_cut_off(day_report, @report.time, @report.year)
      else
        ExtendDate.date_quarter(@report.time, @report.year, day_report)
      end
    else
      if @report.quarterly?
        ExtendDate.date_quarter(@time, @year, day_report)
      else
        ExtendDate.get_begin_and_end_of_cut_off(day_report, @time, @year)
      end
    end
  end

  private

  def get_hash_events_by_event_category_report_month id, event_category_ids, time_range, category
    if category.money?
      {id => @club.events.by_event(event_category_ids).where(date_end: time_range)
        .event_category_activity_money(Event.array_style_event_money_except_activity,
        Event.event_categories[:activity_money]), category: category}
    else
      {id => @club.events.by_event(event_category_ids).where(date_end: time_range)}
    end
  end
end
