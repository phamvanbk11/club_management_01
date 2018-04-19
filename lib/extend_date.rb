class ExtendDate
  class << self
    def get_begin_and_end_of_cut_off day, month, year
      month, year = month_year_by_cutoff_day day, month, year
      m_end_of_month = Date.new(year.to_i, month.to_i).end_of_month.mday
      if day.to_i < m_end_of_month.to_i
        if month.to_i == 1
          month_cut_off_jan day, month, year
        else
          month_cut_off_not_jan day, month, year
        end
      else
        day_cut_off_more_today day, month, year, m_end_of_month
      end
    end

    def month_cut_off_jan day, month, year
      date_begin_12 = Date.new(year.to_i - 1, 12)
                      .end_of_month.strftime("%d").to_i
      begin_of_month = if day.to_i < date_begin_12.to_i
                         Date.new(year.to_i - 1, 12, day.to_i + 1)
                       else
                         Date.new(year.to_i - 1, 12, date_begin_12.to_i)
                       end
      end_of_month = Date.new(year.to_i, month.to_i, day.to_i)
      begin_of_month..end_of_month
    end

    def month_cut_off_not_jan day, month, year
      begin_of_month = get_begin_of_month_from_date_back_month day, month, year
      end_of_month = Date.new(year.to_i, month.to_i, day.to_i)
      begin_of_month..end_of_month
    end

    def day_cut_off_more_today day, month, year, date
      if month.to_i == 1
        begin_of_month = Date.new(year.to_i, month.to_i, 1)
        end_of_month = Date.new(year.to_i, month.to_i, date.to_i)
      else
        begin_of_month = get_begin_of_month_from_date_back_month day, month, year
        end_of_month = Date.new(year.to_i, month.to_i, date.to_i)
      end
      begin_of_month..end_of_month
    end

    def get_begin_of_month_from_date_back_month day, month, year
      date_back_month = Date.new(year.to_i, month.to_i - 1)
                        .end_of_month.strftime("%d").to_i
      begin_of_month = if day.to_i < date_back_month.to_i
                         Date.new(year.to_i, month.to_i - 1, day.to_i + 1)
                       else
                         Date.new(year.to_i, month.to_i, 1)
                       end
    end

    def mday_beetween_of_month date
      ((date.beginning_of_month.mday + date.end_of_month.mday) / 2).ceil
    end

    def month_year_by_cutoff_day cutoff_day, month, year
      date = Date.new(year.to_i, month.to_i)
      if cutoff_day < mday_beetween_of_month(date)
        month = date.next_month.month
        year = date.next_year.year if month == 1
      end
      [month, year]
    end

    def date_quarter quarter, year, day
      case quarter
      when 1
        range_quarter 12, 3, day, year
      when 2
        range_quarter 3, 6, day, year
      when 3
        range_quarter 6, 9, day, year
      else
        range_quarter 9, 12, day, year
      end
    end

    def range_quarter month_start, month_end, day, year
      if month_start == 12
        date_start = get_date_with_check_end_month(day, month_start, year - 1) + 1.day
        date_end = get_date_with_check_end_month(day, month_end, year)
      else
        date_start = get_date_with_check_end_month(day, month_start, year) + 1.day
        date_end = get_date_with_check_end_month(day, month_end, year)
      end
      date_start..date_end
    end

    def get_date_with_check_end_month day, month, year
      m_end_of_month = Date.new(year.to_i, month.to_i).end_of_month.mday
      if day > m_end_of_month
        Date.new(year.to_i, month.to_i, m_end_of_month)
      else
        Date.new(year.to_i, month.to_i, day)
      end
    end
  end
end
