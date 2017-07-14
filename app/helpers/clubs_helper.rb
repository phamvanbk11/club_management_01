module ClubsHelper
  def get_day_view days
    days.join("-")
  end

  def get_field_club field
    raw(field) if field.present?
  end

  def check_date days, day
    days.include? day
  end
end