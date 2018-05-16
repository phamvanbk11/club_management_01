class SettingClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club

  def edit
    @club_types = @club.organization.club_types
  end

  def update
    if @club && @club.update_attributes(club_setting_params)
      flash.now[:success] = t ".update_success"
    elsif @club
      flash.now[:danger] = t ".update_errors"
    end
  end

  def show
    return unless @club
    @hide = params[:hide] == "true"
    frequency = FrequencyClub.new @club, params[:time] || Date.current.month,
      params[:year] || Date.current.year, params[:user_ids]
    @users = frequency.users_frequency_club
  end

  private

  def load_club
    @club = Club.find_by slug: params[:id]
    return if @club
    flash.now[:danger] = t ".not_found_club"
  end

  def club_setting_params
    params.require(:club).permit :frequency, :is_action_report, :club_type_id
  end
end
