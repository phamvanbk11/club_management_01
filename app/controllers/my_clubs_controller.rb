class MyClubsController < ApplicationController
  before_action :authenticate_user!

  def index
    clubs = Club.active.of_organizations(current_user.organizations).of_user_clubs(
      current_user.user_clubs.joined
    )
    @q = clubs.search(params[:q])
    @clubs = @q.result.includes(:organization).newest.page(params[:page]).per Settings.club_per_page
    @organizations = Organization.by_user_organizations(
      current_user.user_organizations.joined
    )
    @club_types = ClubType.includes(:organization)
    respond_to do |format|
      format.html
      format.js
    end
  end
end
