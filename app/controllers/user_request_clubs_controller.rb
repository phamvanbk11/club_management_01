class UserRequestClubsController < ApplicationController
  before_action :load_club, only: [:show, :edit]
  before_action :load_member, only: :update

  def show
    @infor_club = Support::ClubSupport.new(@club, params[:page], nil)
    @members_not_manager = @infor_club.members_not_manager.page(params[:page])
      .per Settings.page_member_not_manager
    respond_to do |format|
      format.js
    end
  end

  def update
    @request = @member.update_attributes status: params[:status]
    flash[:errors] = t("error_process") unless @request
    respond_to do |format|
      format.js
    end
  end

  private
  def load_club
    @club = Club.find_by slug: params[:id]
    unless @club
      flash[:danger] = t "not_found"
      redirect_to root_url
    end
  end

  def load_member
    @member = UserClub.find_by id: params[:id]
    unless @member
      flash[:danger] = t "club_manager.cant_fount"
      redirect_to root_url
    end
  end
end
