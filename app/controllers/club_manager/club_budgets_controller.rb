class ClubManager::ClubBudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  authorize_resource class: false, through: :club
  before_action :load_event
  before_action :load_budget, only: :destroy

  def create
    if params[:users].present? && @event
      ActiveRecord::Base.transaction do
        budgets = []
        params[:users].each do |user_id|
          budgets << @event.budgets.new(user_id: user_id)
        end
        Budget.import! budgets
        @club.calculate_get_budget(@event, params[:users].size)
        params_money = {expense: @event.expense * params[:users].size * Settings.negative}
        create_service_and_update_money params_money
        flash.now[:success] = t "success_process"
        load_member_done_and_yet
      end
    end
  rescue
    flash[:danger] = t "error_in_process"
  end

  def destroy
    if @budget_user && @budget_user.destroy
      @club.calculate_change_budget(@event)
      params_money = {expense: @event.expense}
      create_service_and_update_money params_money
      flash.now[:success] = t "success_process"
      load_member_done_and_yet
    elsif @budget_user
      flash.now[:danger] = t "error_process"
    end
  end

  private
  def load_event
    if @club
      @event = Event.find_by id: params[:event_id]
      return if @event
      flash.now[:danger] = t("event_not_found")
    end
  end

  def create_service_and_update_money params_money
    service_money = UpdateClubMoneyService.new @event, @event.club, params_money
    service_money.update_first_money_of_event_get_money_member
  end

  def load_club
    @club = Club.find_by id: params[:club_id]
    return if @club
    flash.now[:danger] = t "club_not_found"
  end

  def load_budget
    @budget_user = Budget.find_by event_id: params[:event_id],
      user_id: params[:id]
    return if @budget_user
    flash.now[:danger] = t("not_found_user_budget")
  end

  def load_member_done_and_yet
    @event_support = Support::EventSupport.new @event, @club
  end
end
