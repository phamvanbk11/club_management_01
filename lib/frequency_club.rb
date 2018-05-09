class FrequencyClub
  def initialize club, time, year, user_ids
    @club = club
    @time = time
    @year = year
    @user_ids = user_ids
  end

  def users_frequency_club
    if @user_ids.nil?
      get_users_by_frequency
    else
      User.done_by_ids @user_ids
    end
  end

  private

  def get_users_by_frequency
    if @club.frequency <= Settings.default_frequency
      user_ids = @club.user_clubs.users_join_before_time(time_range.last).pluck(:user_id)
      User.done_by_ids user_ids
    else
      users_frequency_more_than_zero
    end
  end

  def users_frequency_more_than_zero
    event_ids = @club.events.activity_money.where(date_end: time_range).ids.to_s.delete('[] ')
    user_ids = @club.user_clubs.joined.pluck(:user_id)
    members = DbStoredProcedure.fetch_db_records("call user_events('" +
      event_ids + "', '" + user_ids.to_s.delete('[] ') + "', #{@club.frequency})")
    User.done_by_ids members.pluck "user_id"
  end

  def time_range
    day = @club.organization.organization_settings.find_by(key: Settings.key_date_report)&.value ||
      Settings.date_report_default
    ExtendDate.get_begin_and_end_of_cut_off(day, @time, @year)
  end
end
