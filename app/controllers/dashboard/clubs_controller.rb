class Dashboard::ClubsController < ApplicationController
  before_action :load_club
  before_action :manager_club, except: :show
  before_action :load_organization, only: [:show, :update]
  before_action :verify_manager_club
  def show
    @event = Event.new
    @new_album = Album.new
    @support = Support::ClubSupport.new(@club, params[:page], @organization)
  end

  def update
    @organizations = current_user.user_organizations.joined
    @club_update = @club.update_attributes club_params
    if @club_update
      create_acivity @club, Settings.update, @club, current_user,
        Activity.type_receives[:club_member]
      flash[:success] = t "club_manager.club.success_update"
    else
      flash_error @club
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def club_params
    params.require(:club).permit :name, :content, :goal, :logo, :rules,
      :rule_finance, :time_join, :image, :tag_list, :plan, :punishment, :member,
      :local, :activities_connect, time_activity: []
  end

  def load_club
    @club = Club.friendly.find params[:id]
    unless @club
      flash[:danger] = t "club_manager.cant_fount"
      redirect_to dashboard_path
    end
  end

  def manager_club
    correct_manager = manager_of_club(current_user).find_by club_id: @club.id
    unless correct_manager
      flash[:danger] = t "not_correct_manager"
      redirect_to dashboard_path
    end
  end

  def load_organization
    @organization = Organization.find_by id: @club.organization_id
    unless @organization
      flash[:danger] = t("not_found_organization")
      redirect_to request.referer
    end
  end

  def verify_manager_club
    @admin = @club.user_clubs.manager.find_by user_id: current_user
    unless @admin
      flash[:danger] = t "not_authorities_to_access"
      redirect_to dashboard_path
    end
  end
end
