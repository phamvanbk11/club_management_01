class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club, only: [:create]

  def create
    ActiveRecord::Base.transaction do
      @club.ratings.create! user_id: current_user.id, star: params[:rating]
      rating_executed
      flash.now[:success] = t "you_raiting_club"
    end
  rescue
    flash.now[:danger] = t "you_raiting_club_errors"
  end

  private
  def rating_executed
    @club.update_attributes rating: Rating.avg_rate(params[:rating], @club)
  end

  def load_club
    @club = Club.find_by id: params[:club_id]
    return if @club
    flash.now[:danger] = t "not_found_club"
  end
end
