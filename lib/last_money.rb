class LastMoney
  def initialize events
    @events = events
  end

  def surplus surplus
    @events.each do |event|
      surplus += LastMoney.last_money event
    end
    surplus
  end

  class << self
    def last_money event
      expense = event.expense.to_i
      if event.get_money_member?
        expense * event.budgets.size
      else
        expense
      end
    end

    def last_money_detail detail
      if detail.pay_money?
        detail.first_money - detail.money
      elsif detail.get_money?
        detail.first_money + detail.money
      else
        Settings.default_value_return
      end
    end

    def count_event user_id, events
      UserEvent.by_user(user_id).by_events(events.ids).size
    end
  end
end
