class ReasonLeavesController < ApplicationController
  before_action :load_user_club, only: [:create, :destroy_user_club]

  def new
  end

  def create
    ActiveRecord::Base.transaction do
      destroy_user_club
      reason_leave = ReasonLeave.new reason_leave_params
      if reason_leave.save
        flash[:success] = t("success_leave")
      else
        flash_error reason_leave
      end
    end
    redirect_back fallback_location: root_path
  end

  private
  def reason_leave_params
    params.require(:reason_leave).permit(:club_id,
      :content).merge! user_id: current_user.id
  end

  def destroy_user_club
    flash_error @user_club unless @user_club.destroy
  end

  def load_user_club
    @user_club = current_user.user_clubs.find_by club_id: params[:reason_leave][:club_id]
    unless @user_club
      flash[:danger] = t("not_found_user_club")
      redirect_back fallback_location: root_path
    end
  end
end
