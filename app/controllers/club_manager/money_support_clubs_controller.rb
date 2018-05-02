class ClubManager::MoneySupportClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club

  def index
    @money_support_clubs = @club.money_support_clubs.page(params[:page]).per Settings.per_page
  end

  private

  def load_club
    @club = Club.find_by slug: params[:club_id]
    return if @club
    flash.now[:danger] = t ".not_found_club"
  end
end
