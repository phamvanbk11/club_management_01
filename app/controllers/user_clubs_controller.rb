class UserClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  before_action :load_user_club, only: :destroy

  def create
    if @club
      user_club = @club.user_clubs.new user_id: current_user.id
      if user_club.save
        flash.now[:success] = t "join_and_wait"
      else
        flash.now[:danger] = t "error_for_join"
      end
    end
  end

  def show
    @user_clubs = @club.user_clubs.joined.includes(:user) if @club
  end

  def destroy
    if @user_club && is_last_manager?
      flash.now[:danger] = t "user_club_not_remove"
    elsif @user_club
      if @user_club.destroy
        flash.now[:success] = t "see_you_next_time"
      else
        flash_error_ajax @user_club
      end
    end
  end

  private
  def load_user_club
    if @club
      @user_club = @club.user_clubs.find_by user_id: current_user.id
      return if @user_club
      flash[:danger] = t "not_found_user_club"
    end
  end

  def is_last_manager?
    @user_club.is_manager && @club.user_clubs.manager.size == Settings.user_club.manager
  end

  def load_club
    @club = Club.find_by slug: params[:id]
    return if @club
    flash.now[:danger] = t("not_found_club")
  end
end
