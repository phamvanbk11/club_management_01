class ClubManager::ExportHistoryBudgetsController < ApplicationController
  before_action :load_club, only: :index
  def index
    if params[:first_date].present? && params[:second_date].present?
      @events = @club.events.newest.event_category_activity_money(Event.array_style_event_money_except_activity,
        Event.event_categories[:activity_money]).by_created_at(params[:first_date], params[:second_date])
    else
      @events = @club.events.newest.event_category_activity_money(Event.array_style_event_money_except_activity,
        Event.event_categories[:activity_money])
    end
    if @events.blank?
      flash[:danger] = t "events_blank"
      redirect_to @club
    end
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers["Content-Disposition"] =
          "filename='#{t('history_budget')}:#{@club.name}.xlsx'"
      end
    end
  end

  private
  def load_club
    @club = Club.find_by id: params[:club_id]
    return if @club
    flash[:danger] = t "cant_found_club"
    redirect_to root_path
  end
end
