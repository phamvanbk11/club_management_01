class ClubManager::UserClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  authorize_resource class: false, through: :club
  before_action :load_userclub, only: [:destroy]

  def update
    ActiveRecord::Base.transaction do
      user_club_update = []
      roles = params[:roles]
      ids = params[:ids]
      @members = @club.user_clubs.joined
      if @members.present? && ids.present? && roles.present?
        ids.each.with_index(Settings.user_club.number) do |id, index|
          member = @members.select{|member| member.id == id.to_i}.first
          if member && member.is_manager != get_boollean?(roles[index])
            member.is_manager = get_boollean?(roles[index])
            user_club_update << member
          end
        end
        UserClub.import! user_club_update, on_duplicate_key_update: [:is_manager]
        flash[:success] = t "success_process"
      else
        flash[:danger] = t "cant_not_update"
      end
      redirect_to club_path @club
    end
  rescue
    flash[:danger] = t "cant_not_update"
    redirect_to club_path @club
  end

  def create
    ActiveRecord::Base.transaction do
      user_clubs = []
      user_ids = params[:user_ids]
      if user_ids.present?
        user_ids.each do |user_id|
          user_clubs << UserClub.new(user_id: user_id, club_id: @club.id,
            is_manager: Settings.user_club.member, status: Settings.user_club.join)
        end
        UserClub.import user_clubs
        flash[:success] = t "success_process"
      else
        flash[:danger] = t "error_in_process"
      end
      redirect_to club_path @club
    end
  rescue
    flash[:danger] = t "error_in_process"
    redirect_to club_path @club
  end

  def destroy
    if @user_club && @user_club.destroy
      flash.now[:success] = t("deleted_successfull")
    else
      flash.now[:danger] = t("error_process")
    end
  end

  private
  def load_userclub
    if @club
      @user_club = UserClub.find_by id: params[:id]
      return if @user_club
      flash.now[:danger] = t "cant_found_request"
    end
  end

  def get_boollean? role
    role == Settings.num_boolean_true
  end
end
