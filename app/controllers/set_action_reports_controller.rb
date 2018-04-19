class SetActionReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  authorize_resource class: false, through: :club

  def update
    if @club.update_attribute(:is_action_report, params[:is_action_report] == Settings.string_true)
      if params[:is_action_report] == Settings.string_true
        flash[:success] = t ".success_permit"
      else
        flash[:success] = t ".success_un_permit"
      end
    else
      flash[:danger] = t ".errors"
    end
    redirect_to @club
  end

  private
  def load_club
    @club = Club.find_by slug: params[:club_id]
    return if @club
    flash[:danger] = t ".cant_find_club"
    redirect_back fallback_location: root_path
  end
end
