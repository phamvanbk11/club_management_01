class UserEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_event, only: [:create, :destroy]
  before_action :load_user_event, only: :destroy
  authorize_resource

  def create
    if params[:user_event]
      user_event = UserEvent.new user_event_params
      unless user_event.save
        flash_error user_event
        redirect_back fallback_location: club_event_path(@event.club, @event)
      end
      flash[:success] = t("thanks_for_join")
    elsif params[:user_id].is_a? Array
      import_member params[:user_id], @event.id
    end
    redirect_back fallback_location: club_event_path(@event.club, @event)
  end

  def destroy
    @club = @event.club
    if @user_event && @user_event.destroy
      flash.now[:success] = t ".success"
    elsif @user_event
      flash.now[:danger] = t ".error_in_process"
    end
    load_member_not_join
  end

  private
  def user_event_params
    params.require(:user_event).permit(:event_id).merge! user_id: current_user.id
  end

  def load_event
    if params[:user_event]
      @event = Event.find_by id: params[:user_event][:event_id]
    else
      @event = Event.find_by id: params[:event_id]
    end
    unless @event
      flash[:danger] = t("not_found_event")
      redirect_back fallback_location: root_path
    end
  end

  def import_member user_ids, event_id
    user_events = []
    user_ids.each do |user_id|
      user_event = UserEvent.new user_id: user_id, event_id: event_id
      user_events << user_event
    end
    UserEvent.import user_events
    flash[:sucess] = t ".success"
  end

  def load_user_event
    if params[:member_id]
      @user_event = @event.user_events.find_by user_id: params[:member_id]
    else
      @user_event = current_user.user_events.find_by event_id: params[:event_id]
    end
    return if @user_event
    flash.now[:danger] = t ".cant_find_member"
  end
end
