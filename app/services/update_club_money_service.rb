class UpdateClubMoneyService
  def initialize event, club, event_params
    @event = event
    @club = club
    @event_params = event_params
  end

  def update_event
    @event.update_attributes! @event_params
  end

  def plus_money_club
    @club.update_attributes! money: @club.money + @event_params[:expense].to_i
  end

  def money_change_when_update_event
    @club.update_attributes! money: @club.money.to_i - @event.expense.to_i + @event_params[:expense].to_i
  end

  def save_event_and_plus_money_club_in_activity_event
    @event.save!
    plus_money_club if (@event.activity_money? && @event_params[:expense].present?)
  end

  def update_event_and_money_club_in_activity_event
    money_change_when_update_event if @event.activity_money?
    @event.update_attributes! @event_params
  end

  def save_event_and_plus_money_club_in_money_event
    @event.save!
    plus_money_club if is_money_type_event?
  end

  def update_event_and_money_club_in_money_event
    case @event_params[:event_category]
    when Event.event_categories[:money], Event.event_categories[:subsidy],
      Event.event_categories[:donate]
      money_change_when_update_event
    when Event.event_categories[:get_money_member]
      update_money
    end
    @event.update_attributes! @event_params
  end

  def update_first_money_of_event
    return unless @event_params[:expense]
    money_change = @event.expense - @event_params[:expense].to_i
    import_update_money_events money_change
  end

  def update_first_money_of_event_get_money_member
    return unless @event_params[:expense]
    money_change = @event_params[:expense].to_i
    import_update_money_events money_change
  end

  private

  def is_money_type_event?
    Event.event_categories.except(:notification, :activity_money, :get_money_member)
      .keys.include? @event.event_category
  end

  def update_money
    if @event.get_money_member?
      @event.club.update_attributes! money: @event.club.money -
        (@event.budgets.size * @event.expense.to_i) +
        (@event.budgets.size * @event_params[:expense].to_i)
    end
  end

  def events_ids_money
    [Event.event_categories[:money], Event.event_categories[:get_money_member],
      Event.event_categories[:donate], Event.event_categories[:subsidy]]
  end

  def import_update_money_events money_change
    list_event_after_event_update = @club.events.more_id_event(@event.id)
      .event_category_activity_money(events_ids_money, Event.event_categories[:activity_money])
    if list_event_after_event_update
      events = []
      list_event_after_event_update.each do |event|
        event.amount -= money_change
        events << event
      end
      Event.import events, on_duplicate_key_update: [:amount]
    end
  end
end
