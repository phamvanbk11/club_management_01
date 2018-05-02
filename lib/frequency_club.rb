class FrequencyClub
  def initialize club, time, year
    @club = club
    @time = time
    @year = year
  end

  def frequency_club_by_time
    event_ids = @club.events.activity_money.where(date_end: time_range).ids.to_s.delete('[] ')
    user_ids = @club.user_clubs.joined.pluck(:user_id).to_s.delete('[] ')
    members = DbStoredProcedure.fetch_db_records("call user_events('" +
      event_ids + "', '" + user_ids + "', #{@club.frequency})")
    User.done_by_ids members.pluck "user_id"
  end

  private

  def time_range
    day = @club.organization.organization_settings.find_by(key: Settings.key_date_report)&.value ||
      Settings.date_report_default
    ExtendDate.get_begin_and_end_of_cut_off(day, @time, @year)
  end
end
