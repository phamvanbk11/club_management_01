class SettingClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club

  def edit; end

  def update
    if @club && @club.update_attributes(club_setting_params)
      flash.now[:success] = t ".update_success"
    elsif @club
      flash.now[:danger] = t ".update_errors"
    end
  end

  def show
    @hide = params[:hide] == "true"
    frequency = FrequencyClub.new @club, params[:time] || Date.current.month,
      params[:year] || Date.current.year
    @users = frequency.frequency_club_by_time
  end

  private

  def load_club
    @club = Club.find_by slug: params[:id]
    return if @club
    flash.now[:danger] = t ".not_found_club"
  end

  def club_setting_params
    params.require(:club).permit :frequency, :is_action_report
  end
end
