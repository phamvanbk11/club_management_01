class Dashboard::ClubExportMembersController < ApplicationController
  before_action :load_club, only: :index
  def index
    @manager = @club.user_clubs.manager.newest
    @members = @club.user_clubs.are_member.newest
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers["Content-Disposition"] =
          "filename='#{t('list_member')}: #{@club.name}.xlsx'"
      end
    end
  end

  def create
  end

  private
  def load_club
    @club = Club.friendly.find params[:id]
    unless @club
      flash[:danger] = t "club_manager.cant_fount"
      redirect_to dashboard_path
    end
  end
end
