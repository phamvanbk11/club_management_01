class CaculatorMoneySupport
  def initialize club, size_member, point_evaluate
    @club = club
    @size_member = size_member
    @point_evaluate = point_evaluate
  end

  def caculator_money_support
    range_supports = @club.organization.range_supports
    range_point = load_range_support_by_point(range_supports).first
    range_member = load_range_support_by_size_member(range_supports).first
    if range_point && range_member
      @money_support = @club.organization.money_supports.select do |money_support|
                         money_support.arr_range == [range_member.id, range_point.id]
                       end&.first
      return @money_support&.money
    end
  end

  def load_range_support_by_point range_supports
    range = range_supports.range.evaluate_point.select do |range_support|
              @point_evaluate >= range_support.value_from &&
                @point_evaluate < range_support.value_to
            end
    return range if range.present?

    range = range_supports.less_than.evaluate_point.select do |range_support|
              @point_evaluate < range_support.value_from
            end
    return range if range.present?

    range = range_supports.more_than.evaluate_point.select do |range_support|
              @point_evaluate > range_support.value_from
            end
    return range if range.present?

    range = range_supports.less_than_or_equal.evaluate_point.select do |range_support|
              @point_evaluate <= range_support.value_from
            end
    return range if range.present?

    range_supports.more_than_or_equal.evaluate_point.select do |range_support|
      @point_evaluate >= range_support.value_from
    end
  end

  def load_range_support_by_size_member range_supports
    range = range_supports.range.member.select do |range_support|
              @size_member >= range_support.value_from &&
                @size_member < range_support.value_to
            end
    return range if range.present?

    range = range_supports.less_than.member.select do |range_support|
              @size_member < range_support.value_from
            end
    return range if range.present?

    range = range_supports.more_than.member.select do |range_support|
              @size_member > range_support.value_from
            end
    return range if range.present?

    range = range_supports.less_than_or_equal.member.select do |range_support|
              @size_member <= range_support.value_from
            end
    return range if range.present?

    range_supports.more_than_or_equal.member.select do |range_support|
      @size_member >= range_support.value_from
    end
  end
end
